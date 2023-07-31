//! DMG System-on-a-Chip implementation.
//!
//! References I've found helpful:
//!
//! - gekkio's guide: https://gekkio.fi/files/gb-docs/gbctr.pdf
//! - Description of opcodes: https://gb-archive.github.io/salvage/decoding_gbz80_opcodes/Decoding%20Gamboy%20Z80%20Opcodes.html
//! - Opcode matrix: https://gbdev.io/gb-opcodes/optables/
//! - Opcode JSON (useful for codegen): https://gbdev.io/gb-opcodes/Opcodes.json
const std = @import("std");

// No gods, no kings, only bus
const Bus = @import("./bus.zig").Bus;
const PPU = @import("./ppu.zig").PPU;

const rom = @import("./rom.zig");
const Rom = rom.Rom;
const hardware_registers = @import("./hardware-registers.zig");
const hardware_register_string = hardware_registers.hardware_register_string;

const opcodes = @import("./opcodes.zig");
const Opcode = opcodes.Opcode;
const Operand = opcodes.Operand;

const Flag = enum(u8) {
    zero = 0b1 << 7,
    subtract = 0b1 << 6,
    halfCarry = 0b1 << 5,
    carry = 0b1 << 4,
};

const Interrupt = enum(u8) {
    timer = 0b0000_0100,
};

const DMG_CPU_HZ: u32 = 4_194_304;

const INT_FLAG_VBLANK: u8 = 0b1 << 0;
const INT_FLAG_STAT: u8 = 0b1 << 1;
const INT_FLAG_TIMER: u8 = 0b1 << 2;
const INT_FLAG_SERIAL: u8 = 0b1 << 3;
const INT_FLAG_JOYPAD: u8 = 0b1 << 4;

const INT_VEC_VBLANK: u16 = 0x0040;
const INT_VEC_STAT: u16 = 0x0048;
const INT_VEC_TIMER: u16 = 0x0050;
const INT_VEC_SERIAL: u16 = 0x0058;
const INT_VEC_JOYPAD: u16 = 0x0060;

pub const CPU = struct {
    bus: *Bus = undefined,

    //
    // General purpose registers
    //

    a: u8 = 0,
    /// Flags register
    ///
    /// See also:
    ///
    /// - `flag` method
    /// - `set_flag` method
    f: u8 = 0,
    b: u8 = 0,
    c: u8 = 0,
    d: u8 = 0,
    e: u8 = 0,
    h: u8 = 0,
    l: u8 = 0,

    /// Stack pointer
    sp: u16 = 0,

    /// Program counter
    pc: u16 = 0,

    /// Used to support the `DI` instruction.
    ///
    /// From the "Game Boy CPU Manual":
    ///
    /// > This instruction disables interrupts but not immediately. Interrupts
    /// > are disabled after instruction after DI is executed.
    disableInterruptsAfterNextInstruction: bool = false,
    enableInterruptsAfterNextInstruction: bool = false,
    interruptMasterEnable: bool = false,
    halted: bool = false,
    prev_ppu_mode: u2 = undefined,

    allocator: std.mem.Allocator,

    hardwareRegisters: []u8 = undefined,
    bootROM: *const [256:0]u8 = @embedFile("./dmg_boot.bin"),

    //
    // Internals
    //

    /// How many cycles until the next instruction?
    cyclesLeft: u8 = 0,

    /// Increments once per cycle. Useful for timer simulation.
    ticks: u32 = 0,
    cycleRate: u32 = DMG_CPU_HZ,
    debugLastPC: u16 = 0x0000,

    callsites: std.ArrayList(Callsite),

    pub fn init(allocator: std.mem.Allocator, bus: *Bus) !CPU {
        var ref = CPU{
            .bus = bus,
            .allocator = allocator,
            .hardwareRegisters = try allocator.alloc(u8, 256),
            .callsites = std.ArrayList(Callsite).init(allocator),
        };
        var i: usize = 0;
        while (i < 256) : (i += 1) {
            ref.hardwareRegisters[i] = 0x00;
        }
        return ref;
    }

    pub fn deinit(self: *const CPU) void {
        self.allocator.free(self.hardwareRegisters);
        self.callsites.deinit();
    }

    pub fn panic(self: *const CPU, comptime format_: []const u8, args: anytype) noreturn {
        std.debug.print("LAST PC @ PANIC: ${X:0>4}\n", .{self.debugLastPC});
        std.debug.print("CPU STATE @ PANIC:\n{}\n", .{self});
        std.debug.panic(format_, args);
    }

    pub fn boot_rom_enabled(self: *const CPU) bool {
        // Should this be != 0x01?
        return self.hardwareRegisters[0x50] == 0x00;
    }

    pub fn boot_rom_read(self: *const CPU, addr: u8) u8 {
        // std.debug.print("boot rom read ${X:0>4} = ${X:0>2}\n", .{ addr, self.bootROM[addr] });
        return self.bootROM[addr];
    }

    pub fn read_hw_register(self: *const CPU, addr: u8) u8 {
        return switch (addr) {
            // Interrupt Flag; upper 3 bits should always be 1s:
            0x0F => 0b1110_0000 | self.hardwareRegisters[addr],
            // LCD control
            0x40 => self.bus.ppu.lcdc,
            0x41 => {
                // I'm making the LCD mode part of the PPU, and always reading
                // it here to determine the appropriate mode flags.
                //
                // I'm doing the same to compare LCY with LY.
                //
                // It's unclear if this is actually how the hardware works, or
                // if the LCD/PPU sets the values at the start of a cycle, or if
                // the CPU just sets this flag every cycle or whatever, but this
                // keeps things simple for now.
                const stat = (self.hardwareRegisters[0x41] & 0b1111_1100) | self.bus.ppu.mode;
                const ly = self.read_hw_register(0x44);
                const lcy = self.read_hw_register(0x45);
                if (lcy == ly) {
                    return stat & 0b1111_1011;
                }
                return stat | 0b0000_0100;
            },
            0x42 => self.bus.ppu.scy,
            0x43 => self.bus.ppu.scx,
            0x44 => self.bus.ppu.ly,
            0x4A => self.bus.ppu.wy,
            0x4B => self.bus.ppu.wx_plus_7,

            // HACK: This hardware register is used by CGB to do stuff we don't
            // support yet. We need to hard-code this to $FF for now. Not sure
            // if this should be readable/writable at all.
            0x4D => 0xFF,
            else => self.hardwareRegisters[addr],
        };
    }

    pub fn write_hw_register(self: *CPU, addr: u8, data: u8) void {
        switch (addr) {
            0x00 => {},
            // LCD control
            0x40 => {
                self.bus.ppu.lcdc = data;
            },
            // LY Coordinate is read-only on the bus
            0x44 => {},
            // Writing any value to DIV register resets it to $00
            0x04 => {
                self.hardwareRegisters[addr] = 0x00;
            },
            else => {
                self.hardwareRegisters[addr] = data;
            },
        }
    }

    //
    // 16-bit register methods
    //
    // Would be nice to generate these, or use unions to achieve it somehow...
    //
    // i.e. I would much rather be able to do this:
    //
    // ```
    // test "read 16 bit registers" {
    //     var cpu = CPU {};
    //     cpu.a = 0xAA;
    //     cpu.f = 0xFF;
    //     try expect(cpu.af == 0xAAFF);
    // }
    //
    // test "write 16 bit registers" {
    //     var cpu = CPU {};
    //     cpu.af = 0xAAFF;
    //     try expect(cpu.a == 0xAA);
    //     try expect(cpu.f == 0xFF);
    // }
    // ```
    //

    pub fn af(self: CPU) u16 {
        return @as(u16, self.a) << 8 | @as(u16, self.f);
    }
    pub fn set_af(self: *CPU, val: u16) void {
        self.a = @truncate(u8, (val & 0xFF00) >> 8);
        // Note: We ignore lower nibble on F:
        self.f = @truncate(u8, val & 0xF0);
    }

    pub fn bc(self: CPU) u16 {
        return @as(u16, self.b) << 8 | @as(u16, self.c);
    }
    pub fn set_bc(self: *CPU, val: u16) void {
        self.b = @truncate(u8, (val & 0xFF00) >> 8);
        self.c = @truncate(u8, val & 0xFF);
    }

    pub fn de(self: CPU) u16 {
        return @as(u16, self.d) << 8 | @as(u16, self.e);
    }
    pub fn set_de(self: *CPU, val: u16) void {
        self.d = @truncate(u8, (val & 0xFF00) >> 8);
        self.e = @truncate(u8, val & 0xFF);
    }

    pub fn hl(self: CPU) u16 {
        return @as(u16, self.h) << 8 | @as(u16, self.l);
    }
    pub fn set_hl(self: *CPU, val: u16) void {
        self.h = @truncate(u8, (val & 0xFF00) >> 8);
        self.l = @truncate(u8, val & 0xFF);
    }

    //
    // Flag methods
    //

    pub fn flag(self: *const CPU, comptime mask: Flag) bool {
        return (self.f & @enumToInt(mask)) != 0;
    }

    pub fn set_flag(self: *CPU, comptime mask: Flag, val: bool) void {
        self.f = if (val) self.f | @enumToInt(mask) else self.f & ~@enumToInt(mask);
    }

    /// Basic bootup simulation.
    ///
    /// This skips the boot ROM sequence and jumps straight to $0100, the ROM's
    /// entrypoint.
    ///
    /// Guide here: https://gbdev.io/pandocs/Power_Up_Sequence.html#cpu-registers
    ///
    /// This behavior follows the entry for `DMG` model.
    pub fn boot(self: *CPU) void {
        self.a = 0x01;
        self.set_flag(Flag.zero, true);
        self.set_flag(Flag.subtract, false);
        self.set_flag(Flag.halfCarry, true);
        self.set_flag(Flag.carry, true);
        self.b = 0x00;
        self.c = 0x13;
        self.d = 0x00;
        self.e = 0xD8;
        self.h = 0x01;
        self.l = 0x4D;

        // Skip the boot rom
        self.pc = 0x0100;
        self.sp = 0xFFFE;
        hardware_registers.simulate_dmg_boot(self.hardwareRegisters);
    }

    fn statInterruptLine(self: *const CPU) bool {
        const stat = self.read_hw_register(0x41);

        // HBlank
        if ((stat & (1 << 0) != 0) and (stat & (1 << 3) != 0)) {
            return true;
        }

        // VBlank
        if ((stat & (1 << 1) != 0) and (stat & (1 << 4) != 0)) {
            return true;
        }

        // OAM
        if ((stat & (1 << 2) != 0) and (stat & (1 << 5) != 0)) {
            return true;
        }

        // LCY == LY
        if ((stat & (1 << 3) != 0) and (stat & (1 << 6) != 0)) {
            return true;
        }

        return false;
    }

    pub fn cycle(self: *CPU) bool {
        var stepped: bool = false;

        // Only for debugging:
        self.debugLastPC = self.pc;

        // Need to temporarily store previous STAT register value so we can
        // detect a rising edge on the interrupt line.
        const prev_stat_interrupt_line = self.statInterruptLine();

        // We are not (yet) implementing a "cycle accurate" emulator, so we
        // essentially just do all our execution at once, once our cycle counter
        // has reached 0.
        if (!self.halted and self.cyclesLeft == 0) {
            stepped = true;
            const previous_pc = self.pc;

            const opcode = self.opcode_at(self.pc);
            if (opcode.prefixed) {
                self.pc +%= 2;
            } else {
                self.pc +%= 1;
            }

            // Set the cycle counter to the first cycle count; for some
            // instructions like conditional jumps, the number of cycles
            // actually depends on the result of the condition, so we use `var`
            // here to allow these instructions to override the result as
            // needed.
            var nextCyclesLeft = opcode.cycles[0];

            switch (opcode.mnemonic) {
                .NOP => {},
                .JP => {
                    var condition = true;
                    var addr_opcode_index: u3 = 0;
                    switch (opcode.operands.len) {
                        1 => {},
                        2 => {
                            condition = switch (opcode.operands[0].name) {
                                .Z => self.flag(Flag.zero),
                                .NZ => !self.flag(Flag.zero),
                                .C => self.flag(Flag.carry),
                                .NC => !self.flag(Flag.carry),
                                else => {
                                    self.panic("Unsupported JP condition: {s}", .{opcode.operands[0].name.string()});
                                },
                            };
                            addr_opcode_index = 1;
                        },
                        else => {
                            self.panic("JP with {d} opcodes not supported!", .{opcode.operands.len});
                        },
                    }

                    const addr = self.read_operand_u16(&opcode.operands[addr_opcode_index]);
                    if (condition) {
                        self.pc = addr;
                    } else {
                        nextCyclesLeft = opcode.cycles[1];
                    }
                },
                .JR => {
                    const offset = @bitCast(i8, @truncate(u8, self.read_operand_u8(&opcode.operands[opcode.operands.len - 1])));

                    const condition = if (opcode.operands.len == 1) true else switch (opcode.operands[0].name) {
                        .Z => self.flag(Flag.zero),
                        .NZ => !self.flag(Flag.zero),
                        .C => self.flag(Flag.carry),
                        .NC => !self.flag(Flag.carry),
                        else => {
                            self.panic("Unsupported JR condition: {s}", .{opcode.operands[0].name.string()});
                        },
                    };

                    if (condition) {
                        // There *must* be a better way to do this in zig:
                        const new_addr: u16 = if (offset > 0)
                            self.pc +% @intCast(u16, offset)
                        else
                            self.pc -% @intCast(u16, -offset);
                        self.pc = new_addr;
                    }
                },
                .PUSH => {
                    const data = self.read_operand_u16(&opcode.operands[0]);
                    self.sp -%= 2;
                    self.bus.write_16(self.sp, data);
                },
                .POP => {
                    const data = self.bus.read_16(self.sp);
                    self.sp +%= 2;
                    self.write_operand_u16(data, &opcode.operands[0]);
                },
                .CALL => {
                    const condition = switch (opcode.operands[0].name) {
                        .NZ => !self.flag(Flag.zero),
                        .Z => self.flag(Flag.zero),
                        .NC => !self.flag(Flag.carry),
                        .C => self.flag(Flag.carry),
                        .a16 => true,
                        else => {
                            self.panic("Condition .{s} not implemented for CALL", .{opcode.operands[0].name.string()});
                        },
                    };
                    const next_instruction_addr = self.pc +% opcode.bytes -% 1;
                    const addr = self.read_operand_u16(&opcode.operands[opcode.operands.len - 1]);

                    if (condition) {
                        // Push address of next instruction onto stack
                        // std.debug.print("next_instruction_addr = ${x:0>4}\n", .{next_instruction_addr});
                        self.sp -%= 2;
                        self.bus.write_16(self.sp, next_instruction_addr);
                        self.callsites.append(Callsite{ .addr = previous_pc }) catch @panic("alloc fail");
                        // Jump to the address specified by the call
                        self.pc = addr;
                    } else {
                        nextCyclesLeft = opcode.cycles[1];
                    }
                },
                .RET, .RETI => {
                    const condition = switch (opcode.operands.len) {
                        0 => true,
                        else => switch (opcode.operands[0].name) {
                            .Z => self.flag(Flag.zero),
                            .NZ => !self.flag(Flag.zero),
                            .C => self.flag(Flag.carry),
                            .NC => !self.flag(Flag.carry),
                            else => {
                                self.panic("Condition .{s} not implemented for RET", .{opcode.operands[0].name.string()});
                            },
                        },
                    };

                    if (condition) {
                        // Pop two bytes from stack & jump to that address.
                        const addr = self.bus.read_16(self.sp);
                        self.sp +%= 2;
                        self.pc = addr;
                        if (self.callsites.items.len > 0) {
                            _ = self.callsites.pop();
                        }
                        if (opcode.mnemonic == .RETI) {
                            self.interruptMasterEnable = true;
                        }
                    } else {
                        nextCyclesLeft = opcode.cycles[1];
                    }
                },
                .RST => {
                    self.callsites.append(Callsite{ .addr = previous_pc }) catch @panic("alloc fail");
                    // Push present address onto stack.
                    self.sp -%= 2;
                    self.bus.write_16(self.sp, self.pc);

                    // Jump to address $0000 + n
                    const offset = self.read_operand_u8(&opcode.operands[0]);
                    self.pc = 0x0000 + @intCast(u16, offset);
                },
                .CP => {
                    // Compare A with n. This is basically an A - n subtraction
                    // instruction but the results are thrown away.
                    const n = self.read_operand_u8(&opcode.operands[0]);
                    const val = self.a;
                    const result = val -% n;
                    self.set_flag(Flag.zero, result == 0);
                    self.set_flag(Flag.subtract, true);
                    self.set_flag(Flag.halfCarry, (val & 0xF) < (n & 0xF));
                    self.set_flag(Flag.carry, val < n);
                },
                .INC, .DEC => {
                    if (opcode.operands.len > 1) {
                        @panic("Unexpected number of operands for INC");
                    }
                    const param = opcode.operands[0];
                    switch (param.name) {
                        .A, .B, .C, .D, .E, .H, .L => {
                            const val = self.read_operand_u8(&param);
                            const result = if (opcode.mnemonic == .INC) val +% 1 else val -% 1;
                            self.write_operand_u8(result, &param);
                            self.set_flag(Flag.zero, result == 0);
                            self.set_flag(Flag.subtract, opcode.mnemonic == .DEC);
                            const half_carry = if (opcode.mnemonic == .INC) (result & 0x0F) == 0 else (result & 0x0F) == 0x0F;
                            self.set_flag(Flag.halfCarry, half_carry);
                        },
                        .BC, .DE, .HL, .SP => {
                            if (!param.immediate) {
                                const val = self.read_operand_u8(&param);
                                const result = if (opcode.mnemonic == .INC) val +% 1 else val -% 1;
                                self.write_operand_u8(result, &param);
                                self.set_flag(Flag.zero, result == 0);
                                self.set_flag(Flag.subtract, opcode.mnemonic == .DEC);
                                const half_carry = if (opcode.mnemonic == .INC) (result & 0x0F) == 0 else (result & 0x0F) == 0x0F;
                                self.set_flag(Flag.halfCarry, half_carry);
                            } else {
                                const val = self.read_operand_u16(&param);
                                const result = if (opcode.mnemonic == .INC) val +% 1 else val -% 1;
                                self.write_operand_u16(result, &param);
                            }
                        },
                        else => {
                            self.panic("Unexpected INC/DEC param: {s}", .{param.name.string()});
                        },
                    }
                },
                .LD, .LDH => {
                    if (opcode.operands.len == 3) {
                        // Special case: LD HL, SP + r8
                        const to = opcode.operands[0];
                        const val = self.sp;
                        const n = self.read_operand_u8(&opcode.operands[2]);
                        const offset = @bitCast(i8, @truncate(u8, n));

                        // There *must* be a better way to do this in zig:
                        const data: u16 = if (offset > 0)
                            self.sp +% @intCast(u16, offset)
                        else
                            self.sp -% @intCast(u16, -offset);

                        self.write_operand_u16(data, &to);

                        self.set_flag(.zero, false);
                        self.set_flag(.subtract, false);
                        self.set_flag(.halfCarry, (@intCast(i32, val & 0x000F) + @intCast(i32, n & 0x0F)) > 0x0F);
                        self.set_flag(.carry, (@intCast(i32, val & 0x00FF) + @intCast(i32, n)) > 0xFF);
                    } else {
                        const to = opcode.operands[0];
                        const from = opcode.operands[1];
                        if (from.immediate and (from.bytes == 2 or from.name == .SP or from.name == .HL)) {
                            const data = self.read_operand_u16(&from);
                            self.write_operand_u16(data, &to);
                        } else {
                            const data = self.read_operand_u8(&from);
                            self.write_operand_u8(data, &to);
                        }
                    }
                },
                .AND => {
                    const operand = opcode.operands[0];
                    const data = self.read_operand_u8(&operand);
                    self.a = self.a & data;
                    self.f = 0;
                    self.set_flag(Flag.zero, self.a == 0);
                    self.set_flag(Flag.subtract, false);
                    self.set_flag(Flag.halfCarry, true);
                    self.set_flag(Flag.carry, false);
                },
                .OR => {
                    const operand = opcode.operands[0];
                    const data = self.read_operand_u8(&operand);
                    self.a = self.a | data;
                    self.f = 0;
                    self.set_flag(Flag.zero, self.a == 0);
                    self.set_flag(Flag.subtract, false);
                    self.set_flag(Flag.halfCarry, false);
                    self.set_flag(Flag.carry, false);
                },
                .XOR => {
                    const operand = opcode.operands[0];
                    const data = self.read_operand_u8(&operand);
                    self.a = self.a ^ data;
                    self.f = 0;
                    self.set_flag(Flag.zero, self.a == 0);
                },
                .CPL => {
                    self.a = ~self.a;
                    self.set_flag(Flag.subtract, true);
                    self.set_flag(Flag.halfCarry, true);
                },

                .DI => {
                    self.disableInterruptsAfterNextInstruction = true;
                },
                .EI => {
                    self.enableInterruptsAfterNextInstruction = true;
                },
                .HALT => {
                    self.halted = true;
                    // std.debug.print("HALT\n", .{});
                },

                .ADD => {
                    const to = opcode.operands[0];
                    const from = opcode.operands[1];

                    if (to.name == .SP) {
                        const val = self.read_operand_u16(&to);
                        const n = self.read_operand_u8(&from);
                        const offset = @bitCast(i8, n);

                        // There *must* be a better way to do this in zig:
                        const result: u16 = if (offset > 0)
                            val +% @intCast(u16, offset)
                        else
                            val -% @intCast(u16, -offset);

                        self.write_operand_u16(result, &to);
                        self.set_flag(Flag.zero, false);
                        self.set_flag(Flag.subtract, false);
                        self.set_flag(Flag.halfCarry, ((val & 0x000F) + (n & 0x000F)) > 0x000F);
                        self.set_flag(Flag.carry, ((val & 0x00FF) + (n & 0x00FF)) > 0x00FF);
                    } else {
                        if (to.is_double() and from.is_double()) {
                            const val = self.read_operand_u16(&to);
                            const n = self.read_operand_u16(&from);
                            const result = val +% n;
                            self.write_operand_u16(result, &to);
                            self.set_flag(Flag.subtract, false);
                            self.set_flag(Flag.halfCarry, ((val & 0x0FFF) + (n & 0x0FFF)) > 0x0FFF);
                            self.set_flag(Flag.carry, (@intCast(u32, val) + @intCast(u32, n)) > 0xFFFF);
                        } else {
                            const val = self.read_operand_u8(&to);
                            const n = self.read_operand_u8(&from);
                            const result = val +% n;
                            self.write_operand_u8(result, &to);
                            self.set_flag(Flag.zero, result == 0);
                            self.set_flag(Flag.subtract, false);
                            self.set_flag(Flag.halfCarry, ((val & 0x0F) + (n & 0x0F)) > 0x0F);
                            self.set_flag(Flag.carry, (@intCast(u16, val) + @intCast(u16, n)) > 0xFF);
                        }
                    }
                },
                .ADC => {
                    const to = opcode.operands[0];
                    const from = opcode.operands[1];
                    const val = self.read_operand_u8(&to);
                    const n = self.read_operand_u8(&from);
                    var result = val +% n;
                    var delta: u8 = 0;
                    if (self.flag(Flag.carry)) {
                        delta = 1;
                        result +%= delta;
                    }
                    self.write_operand_u8(result, &to);
                    self.set_flag(Flag.zero, result == 0);
                    self.set_flag(Flag.subtract, false);
                    self.set_flag(Flag.halfCarry, ((val & 0x0F) + (n & 0x0F) + delta) > 0x0F);
                    self.set_flag(Flag.carry, (@intCast(u16, val) + @intCast(u16, n) + @intCast(u16, delta)) > 0xFF);
                },
                .SUB => {
                    const n = self.read_operand_u8(&opcode.operands[0]);
                    const val = self.a;
                    const result = val -% n;
                    self.a = result;
                    self.set_flag(Flag.zero, result == 0);
                    self.set_flag(Flag.subtract, true);
                    self.set_flag(Flag.halfCarry, (val & 0xF) < (n & 0xF));
                    self.set_flag(Flag.carry, val < n);
                },
                .SBC => {
                    const to = opcode.operands[0];
                    const from = opcode.operands[1];
                    const val = self.read_operand_u8(&to);
                    const n = self.read_operand_u8(&from);
                    var result = val -% n;
                    var delta: u8 = 0;
                    if (self.flag(Flag.carry)) {
                        delta = 1;
                        result -%= delta;
                    }
                    self.write_operand_u8(result, &to);
                    self.set_flag(Flag.zero, result == 0);
                    self.set_flag(Flag.subtract, true);
                    self.set_flag(Flag.halfCarry, (val & 0xF) < ((n & 0xF) + delta));
                    self.set_flag(Flag.carry, @intCast(u16, val) < (@intCast(u16, n) + @intCast(u16, delta)));
                },

                // https://ehaskins.com/2018-01-30%20Z80%20DAA/
                .DAA => {
                    var correction: u8 = 0x00;
                    var set_carry: bool = false;

                    if (self.flag(.halfCarry) or (!self.flag(.subtract) and ((self.a & 0x0F) > 0x09))) {
                        correction |= 0x06;
                    }

                    if (self.flag(.carry) or (!self.flag(.subtract) and (self.a > 0x99))) {
                        correction |= 0x60;
                        set_carry = true;
                    }

                    self.a = if (self.flag(.subtract)) self.a -% correction else self.a +% correction;

                    self.set_flag(.zero, self.a == 0);
                    self.set_flag(.halfCarry, false);
                    self.set_flag(.carry, set_carry);
                },
                .CCF => {
                    self.set_flag(.subtract, false);
                    self.set_flag(.halfCarry, false);
                    self.set_flag(.carry, !self.flag(.carry));
                },
                .SCF => {
                    self.set_flag(.subtract, false);
                    self.set_flag(.halfCarry, false);
                    self.set_flag(.carry, true);
                },
                .BIT => {
                    // Test bit `b` in register `r`
                    const bit = opcode.operands[0];
                    const mask: u8 = switch (bit.name) {
                        ._0 => 0b0000_0001,
                        ._1 => 0b0000_0010,
                        ._2 => 0b0000_0100,
                        ._3 => 0b0000_1000,
                        ._4 => 0b0001_0000,
                        ._5 => 0b0010_0000,
                        ._6 => 0b0100_0000,
                        ._7 => 0b1000_0000,
                        else => {
                            self.panic("Unexpected bit operand for BIT operation: {s}", .{bit.name.string()});
                        },
                    };
                    const register = opcode.operands[1];
                    const is_bit_set = 0 != mask & switch (register.name) {
                        .A => self.a,
                        .B => self.b,
                        .C => self.c,
                        .D => self.d,
                        .E => self.e,
                        .H => self.h,
                        .L => self.l,
                        .HL => self.bus.read(self.hl()),
                        else => {
                            self.panic("Unexpected register operand for RES operation: {s}", .{register.name.string()});
                        },
                    };

                    self.set_flag(Flag.zero, !is_bit_set);
                    self.set_flag(Flag.subtract, false);
                    self.set_flag(Flag.halfCarry, true);
                },
                .RES, .SET => {
                    // Set/Reset bit `b` in register `r`
                    const register = opcode.operands[0];
                    const bit = opcode.operands[1];

                    const mask: u8 = switch (bit.name) {
                        ._0 => 0b0000_0001,
                        ._1 => 0b0000_0010,
                        ._2 => 0b0000_0100,
                        ._3 => 0b0000_1000,
                        ._4 => 0b0001_0000,
                        ._5 => 0b0010_0000,
                        ._6 => 0b0100_0000,
                        ._7 => 0b1000_0000,
                        else => {
                            self.panic("Unexpected bit operand for {s} operation: {s}", .{ opcode.mnemonic.string(), bit.name.string() });
                        },
                    };

                    const val = self.read_operand_u8(&register);
                    var result: u8 = val;
                    if (opcode.mnemonic == .RES) {
                        result = val & (~mask);
                    } else {
                        result = val | mask;
                    }

                    self.write_operand_u8(result, &register);
                },
                .SWAP => {
                    const val = self.read_operand_u8(&opcode.operands[0]);
                    const result = (val >> 4 | val << 4);
                    self.write_operand_u8(result, &opcode.operands[0]);
                    self.set_flag(.zero, result == 0);
                    self.set_flag(.subtract, false);
                    self.set_flag(.halfCarry, false);
                    self.set_flag(.carry, false);
                },
                .RR => {
                    const val = self.read_operand_u8(&opcode.operands[0]);
                    const carry: u8 = if (self.flag(Flag.carry)) 0b1000_0000 else 0;
                    const result = val >> 1 | carry;
                    self.write_operand_u8(result, &opcode.operands[0]);
                    self.set_flag(Flag.zero, result == 0);
                    self.set_flag(Flag.subtract, false);
                    self.set_flag(Flag.halfCarry, false);
                    self.set_flag(Flag.carry, (val & 1) != 0);
                },
                .RL => {
                    const val = self.read_operand_u8(&opcode.operands[0]);
                    const carry: u8 = if (self.flag(Flag.carry)) 1 else 0;
                    const result = val << 1 | carry;
                    self.write_operand_u8(result, &opcode.operands[0]);
                    self.set_flag(Flag.zero, result == 0);
                    self.set_flag(Flag.subtract, false);
                    self.set_flag(Flag.halfCarry, false);
                    self.set_flag(Flag.carry, (val & 0b1000_0000) != 0);
                },
                .SLA => {
                    const val = self.read_operand_u8(&opcode.operands[0]);
                    const result = (val << 1) & 0b1111_1110;
                    self.write_operand_u8(result, &opcode.operands[0]);
                    self.set_flag(Flag.zero, result == 0);
                    self.set_flag(Flag.subtract, false);
                    self.set_flag(Flag.halfCarry, false);
                    self.set_flag(Flag.carry, (val & 0b1000_0000) != 0);
                },
                .SRA => {
                    const val = self.read_operand_u8(&opcode.operands[0]);
                    const result = (val >> 1) | (val & 0b1000_0000);
                    self.write_operand_u8(result, &opcode.operands[0]);
                    self.set_flag(Flag.zero, result == 0);
                    self.set_flag(Flag.subtract, false);
                    self.set_flag(Flag.halfCarry, false);
                    self.set_flag(Flag.carry, (val & 0b0000_0001) != 0);
                },
                .SRL => {
                    const val = self.read_operand_u8(&opcode.operands[0]);
                    const result = (val >> 1) & 0b0111_1111;
                    self.write_operand_u8(result, &opcode.operands[0]);
                    self.set_flag(Flag.zero, result == 0);
                    self.set_flag(Flag.subtract, false);
                    self.set_flag(Flag.halfCarry, false);
                    self.set_flag(Flag.carry, (val & 1) != 0);
                },
                .RRA => {
                    const val = self.a;
                    const carry: u8 = if (self.flag(Flag.carry)) 0b1000_0000 else 0;
                    const result = val >> 1 | carry;
                    self.a = result;
                    self.set_flag(Flag.zero, false);
                    self.set_flag(Flag.subtract, false);
                    self.set_flag(Flag.halfCarry, false);
                    self.set_flag(Flag.carry, (val & 1) != 0);
                },
                .RLA => {
                    const val = self.a;
                    const carry: u8 = if (self.flag(Flag.carry)) 1 else 0;
                    const result = val << 1 | carry;
                    self.a = result;
                    self.set_flag(Flag.zero, false);
                    self.set_flag(Flag.subtract, false);
                    self.set_flag(Flag.halfCarry, false);
                    self.set_flag(Flag.carry, (val & 0b1000_0000) != 0);
                },
                .RLCA => {
                    const val = self.a;
                    const result = val << 1 | (val >> 7);
                    self.a = result;
                    self.set_flag(Flag.zero, false);
                    self.set_flag(Flag.subtract, false);
                    self.set_flag(Flag.halfCarry, false);
                    self.set_flag(Flag.carry, (val & 0b1000_0000) != 0);
                },
                .RRCA => {
                    const val = self.a;
                    const result = val >> 1 | (val << 7);
                    self.a = result;
                    self.set_flag(Flag.zero, false);
                    self.set_flag(Flag.subtract, false);
                    self.set_flag(Flag.halfCarry, false);
                    self.set_flag(Flag.carry, (val & 1) != 0);
                },
                .RLC => {
                    const val = self.read_operand_u8(&opcode.operands[0]);
                    const result = val << 1 | (val >> 7);
                    self.write_operand_u8(result, &opcode.operands[0]);
                    self.set_flag(Flag.zero, result == 0);
                    self.set_flag(Flag.subtract, false);
                    self.set_flag(Flag.halfCarry, false);
                    self.set_flag(Flag.carry, (val & 0b1000_0000) != 0);
                },
                .RRC => {
                    const val = self.read_operand_u8(&opcode.operands[0]);
                    const result = val >> 1 | (val << 7);
                    self.write_operand_u8(result, &opcode.operands[0]);
                    self.set_flag(Flag.zero, result == 0);
                    self.set_flag(Flag.subtract, false);
                    self.set_flag(Flag.halfCarry, false);
                    self.set_flag(Flag.carry, (val & 1) != 0);
                },
                .STOP => {
                    self.panic("STOP not implemented", .{});
                },
                .ILLEGAL_D3, .ILLEGAL_DB, .ILLEGAL_DD, .ILLEGAL_E3, .ILLEGAL_E4, .ILLEGAL_EB, .ILLEGAL_EC, .ILLEGAL_ED, .ILLEGAL_F4, .ILLEGAL_FC, .ILLEGAL_FD => {
                    self.panic("{s} opcode not implemented", .{opcode.mnemonic.string()});
                },
                .PREFIX => {
                    self.panic("PREFIX opcode should not be reachable", .{});
                },
            }

            self.cyclesLeft = nextCyclesLeft;

            if (self.disableInterruptsAfterNextInstruction and opcode.mnemonic != .DI) {
                // std.debug.print("Interrupts disabled!\n", .{});
                self.interruptMasterEnable = false;
                self.disableInterruptsAfterNextInstruction = false;
            }
            if (self.enableInterruptsAfterNextInstruction and opcode.mnemonic != .EI) {
                // std.debug.print("Interrupts enabled!\n", .{});
                self.interruptMasterEnable = true;
                self.enableInterruptsAfterNextInstruction = false;
            }
        }

        if (!self.halted) {
            self.cyclesLeft -= 1;
        }

        //
        // TIMERS
        //
        const timersTicked = (self.ticks % 4) == 0;

        // The DIV register (FF04) increments at a rate of 1/4th the CPU cycle
        // rate, so we can simply check if the current tick is a 4th-tick.
        if (timersTicked) {
            self.hardwareRegisters[0x04] +%= 1;
        }

        const tac: u8 = self.hardwareRegisters[0x07];
        const timerEnabled: bool = tac & 0b0000_0100 != 0;
        if (timerEnabled) {
            const timerCycleDivisor: u32 = switch (@truncate(u2, tac)) {
                0 => 1024,
                1 => 16,
                2 => 64,
                3 => 256,
            };

            if ((self.ticks % timerCycleDivisor) == 0) {
                self.hardwareRegisters[0x05] +%= 1;
                // When the value overflows (exceeds $FF) it is reset to the
                // value specified in TMA (FF06) and an interrupt is requested.
                if (self.hardwareRegisters[0x05] == 0x00) {
                    self.hardwareRegisters[0x05] = self.hardwareRegisters[0x06];
                    self.hardwareRegisters[0x0F] |= INT_FLAG_TIMER;
                }
            }
        }

        //
        // STAT (LCD status)
        //
        if (!prev_stat_interrupt_line and self.statInterruptLine()) {
            self.hardwareRegisters[0x0F] |= INT_FLAG_STAT;
        }

        //
        // VBLANK
        //
        if (self.prev_ppu_mode != 1 and self.bus.ppu.mode == 1) {
            self.hardwareRegisters[0x0F] |= INT_FLAG_VBLANK;
        }
        self.prev_ppu_mode = self.bus.ppu.mode;

        //
        // HANDLE INTERRUPTS
        //

        // As soon as an interrupt is pending, we un-halt the CPU
        if (self.halted and ((self.hardwareRegisters[0x0F]) != 0x00)) {
            self.halted = false;
        }

        const interruptHandled = self.maybe_interrupt(INT_FLAG_VBLANK, INT_VEC_VBLANK) or
            self.maybe_interrupt(INT_FLAG_STAT, INT_VEC_STAT) or
            self.maybe_interrupt(INT_FLAG_TIMER, INT_VEC_TIMER) or
            self.maybe_interrupt(INT_FLAG_SERIAL, INT_VEC_SERIAL) or
            self.maybe_interrupt(INT_FLAG_JOYPAD, INT_VEC_JOYPAD);

        //
        // DONE
        //

        self.ticks +%= 1;

        return stepped or (self.halted and timersTicked) or interruptHandled;
    }

    pub fn step(self: *CPU) void {
        var loops: u64 = 0;
        while (!self.cycle()) {
            if (loops > 1000) {
                self.panic("Excess loops in cpu.step!", .{});
            }
            loops += 1;
        }
    }

    fn maybe_interrupt(self: *CPU, interruptFlag: u8, interruptVector: u16) bool {
        if (self.interruptMasterEnable and
            (self.hardwareRegisters[0xFF] & interruptFlag) != 0 and
            (self.hardwareRegisters[0x0F] & interruptFlag) != 0)
        {
            self.interruptMasterEnable = false;
            self.sp -%= 2;
            self.hardwareRegisters[0x0F] &= ~interruptFlag;
            self.bus.write_16(self.sp, self.pc);
            self.callsites.append(Callsite{ .addr = self.pc }) catch @panic("alloc fail");
            self.pc = interruptVector;
            // std.debug.print("INTERRUPT: {X:0>2} {X:0>4}\n", .{ interruptFlag, interruptVector });
            return true;
        }

        return false;
    }

    pub fn read_operand_u8_safe(self: *const CPU, operand: *const Operand) u8 {
        return switch (operand.name) {
            .A => self.a,
            .B => self.b,
            .C => if (operand.immediate) self.c else self.bus.read(0xFF00 +% @as(u16, self.c)),
            .D => self.d,
            .E => self.e,
            .H => self.h,
            .L => self.l,
            .BC, .DE, .HL, .SP => {
                // FIXME: Perhaps we should have `Operand` and `Operand16`
                // structs instead so the type checker can help us deal with
                // this tediousness
                if (operand.immediate) {
                    self.panic("Cannot get {s} as 8-bit immediate value", .{operand.name.string()});
                }
                const addr = switch (operand.name) {
                    .BC => self.bc(),
                    .DE => self.de(),
                    .SP => self.sp,
                    .HL => blk: {
                        // wtf is this, zig?
                        break :blk self.hl();
                    },
                    else => @panic("Should not be able to reach this"),
                };

                return self.bus.read(addr);
            },
            .d8, .r8 => self.bus.read(self.pc),
            .a8 => {
                const offset = self.bus.read(self.pc);
                return self.bus.read(0xFF00 +% @as(u16, offset));
            },
            .a16, .d16 => {
                if (operand.immediate) {
                    self.panic("Cannot read 16-bit immediate value for d16/a16 (CPU: {})", .{self});
                }
                const addr = self.bus.read_16(self.pc);
                return self.bus.read(addr);
            },

            ._00H => 0x00,
            ._08H => 0x08,
            ._10H => 0x10,
            ._18H => 0x18,
            ._20H => 0x20,
            ._28H => 0x28,
            ._30H => 0x30,
            ._38H => 0x38,

            else => {
                self.panic("read_operand_u8 for .{s} not implemented!", .{operand.name.string()});
            },
        };
    }

    pub fn read_operand_u8(self: *CPU, operand: *const Operand) u8 {
        const result = self.read_operand_u8_safe(operand);
        switch (operand.name) {
            .A, .B, .C, .D, .E, .H, .L, .AF, .BC, .DE, .SP, ._00H, ._08H, ._10H, ._18H, ._20H, ._28H, ._30H, ._38H => {},
            .HL => {
                if (operand.decrement) {
                    self.set_hl(self.hl() -% 1);
                }
                if (operand.increment) {
                    self.set_hl(self.hl() +% 1);
                }
            },
            .d8, .r8, .a8 => self.pc +%= 1,
            .a16, .d16 => self.pc +%= 2,
            else => {
                self.panic("read_operand_u8 for .{s} not implemented!", .{operand.name.string()});
            },
        }
        return result;
    }

    pub fn write_operand_u8(self: *CPU, data: u8, operand: *const Operand) void {
        switch (operand.name) {
            .A => self.a = data,
            .B => self.b = data,
            .C => {
                if (operand.immediate) {
                    self.c = data;
                } else {
                    self.bus.write(0xFF00 +% @as(u16, self.c), data);
                }
            },
            .D => self.d = data,
            .E => self.e = data,
            .H => self.h = data,
            .L => self.l = data,

            .BC => {
                if (operand.immediate) {
                    self.panic("Cannot write 8 bit immediate value to .{s}", .{operand.name.string()});
                }
                self.bus.write(self.bc(), data);
            },
            .DE => {
                if (operand.immediate) {
                    self.panic("Cannot write 8 bit immediate value to .{s}", .{operand.name.string()});
                }
                self.bus.write(self.de(), data);
            },

            .HL => {
                if (operand.immediate) {
                    self.panic("Cannot write 8 bit immediate value to .{s}", .{operand.name.string()});
                }
                self.bus.write(self.hl(), data);
                if (operand.decrement) {
                    self.set_hl(self.hl() -% 1);
                }
                if (operand.increment) {
                    self.set_hl(self.hl() +% 1);
                }
            },

            .a16 => {
                if (operand.immediate) {
                    self.panic("Cannot write 8 bit immediate value to .{s}", .{operand.name.string()});
                }
                const addr = self.bus.read_16(self.pc);
                self.pc +%= 2;
                self.bus.write(addr, data);
            },

            .a8 => {
                const addr = 0xFF00 + @as(u16, self.bus.read(self.pc));
                self.pc +%= 1;
                self.bus.write(addr, data);
            },

            else => {
                self.panic("write_operand_u8 for .{s} not implemented!", .{operand.name.string()});
            },
        }
    }

    pub fn read_operand_u16_safe(self: *const CPU, operand: *const Operand) u16 {
        return switch (operand.name) {
            .d16, .a16 => (if (operand.immediate)
                self.bus.read_16(self.pc)
            else
                self.bus.read_16(self.bus.read_16(self.pc))),
            .AF => self.af(),
            .BC => self.bc(),
            .DE => self.de(),
            .HL => self.hl(),
            .SP => self.sp,
            else => {
                self.panic("read_operand_u16_safe for .{s} not implemented!", .{operand.name.string()});
            },
        };
    }

    pub fn read_operand_u16(self: *CPU, operand: *const Operand) u16 {
        const result = self.read_operand_u16_safe(operand);
        switch (operand.name) {
            .d16, .a16 => self.pc +%= 2,
            .AF, .BC, .DE, .HL, .SP => {},
            else => {
                self.panic("read_operand_u16 for .{s} not implemented!", .{operand.name.string()});
            },
        }
        return result;
    }

    pub fn write_operand_u16(self: *CPU, data: u16, operand: *const Operand) void {
        switch (operand.name) {
            .d16, .a16 => {
                const addr = self.bus.read_16(self.pc);
                self.pc +%= 2;
                self.bus.write_16(addr, data);
            },
            .AF => {
                self.set_af(data);
            },
            .BC => {
                self.set_bc(data);
            },
            .DE => {
                self.set_de(data);
            },
            .HL => {
                self.set_hl(data);
            },
            .SP => {
                self.sp = data;
            },
            else => {
                self.panic("write_operand_u16 for .{s} not implemented!", .{operand.name.string()});
            },
        }
    }

    pub fn opcode_at(self: *const CPU, addr: u16) Opcode {
        const op = self.bus.read(addr);
        if (op == 0xCB) {
            const prefixed_op = self.bus.read(addr + 1);
            return opcodes.PREFIXED[prefixed_op];
        } else {
            return opcodes.UNPREFIXED[op];
        }
    }

    pub fn disassemble(self: *const CPU, count: u16) Disassembly {
        return Disassembly{ .cpu = self, .count = count };
    }

    pub fn registers(self: *const CPU) Registers {
        return Registers{ .cpu = self };
    }

    pub fn backtrace(self: *const CPU) Backtrace {
        return Backtrace{ .cpu = self };
    }

    pub fn format(self: *const CPU, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        // A: 00 F: 00 B: 00 C: 00 D: 00 E: 00 H: 00 L: 00 SP: 0000 PC: 00:0000 (31 FE FF AF)
        const fmt = "A: {X:0>2} F: {X:0>2} B: {X:0>2} C: {X:0>2} D: {X:0>2} E: {X:0>2} H: {X:0>2} L: {X:0>2} SP: {X:0>4} PC: 00:{X:0>4} ({X:0>2} {X:0>2} {X:0>2} {X:0>2})";
        return writer.print(fmt, .{
            self.a,
            self.f,
            self.b,
            self.c,
            self.d,
            self.e,
            self.h,
            self.l,

            self.sp,
            self.pc,

            self.bus.read(self.pc +% 0),
            self.bus.read(self.pc +% 1),
            self.bus.read(self.pc +% 2),
            self.bus.read(self.pc +% 3),
        });
    }
};

const Callsite = struct {
    bank: u8 = 0, // Need to get this from the rom's mapper, presumably
    addr: u16,
    pub fn format(self: *const Callsite, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        return writer.print("${x:0>2}:${x:0>4}", .{ self.bank, self.addr });
    }
};

const Backtrace = struct {
    cpu: *const CPU,
    pub fn format(self: *const Backtrace, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.print("  1. {}\n", .{Callsite{ .bank = 0, .addr = self.cpu.pc }});
        const len: usize = self.cpu.callsites.items.len;
        var i: usize = 1;
        while (i <= len) : (i += 1) {
            const callsite = self.cpu.callsites.items[len - i];
            try writer.print("{d: >3}. {}\n", .{ i + 1, callsite });
        }
        try writer.print("\n", .{});
    }
};

const Registers = struct {
    cpu: *const CPU,
    pub fn format(self: *const Registers, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        const fmt = (
            \\AF  = ${x:0>4} ({s}{s}{s}{s})
            \\BC  = ${x:0>4}
            \\DE  = ${x:0>4}
            \\HL  = ${x:0>4}
            \\SP  = ${x:0>4}
            \\PC  = ${x:0>4}
            \\IME = Disabled
        );

        try writer.print(fmt, .{
            self.cpu.af(),
            if (self.cpu.flag(.carry)) "C" else "-",
            if (self.cpu.flag(.halfCarry)) "H" else "-",
            if (self.cpu.flag(.subtract)) "N" else "-",
            if (self.cpu.flag(.zero)) "Z" else "-",
            self.cpu.bc(),
            self.cpu.de(),
            self.cpu.hl(),
            self.cpu.sp,
            self.cpu.pc,
        });
    }
};

const Disassembly = struct {
    cpu: *const CPU,
    count: u16,
    pub fn format(self: *const Disassembly, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        self.cpu.bus.rom.__HACK__PRINTING_DEBUG_INFO = true;
        var addr = self.cpu.pc;
        var i: u16 = 0;
        while (i < self.count) : (i += 1) {
            if (addr == self.cpu.pc) {
                try writer.print("  ->", .{});
            } else {
                try writer.print("    ", .{});
            }
            const opcode = self.cpu.opcode_at(addr);

            // For opcode debugging, uncomment this line and comment out the one after it:
            // try writer.print("{x:0>4}: ({X:0>2}) {s}", .{ addr, self.cpu.bus.read(addr), opcode.mnemonic.string() });
            try writer.print("{x:0>4}: {s}", .{ addr, opcode.mnemonic.string() });

            if (opcode.prefixed) {
                addr += 2;
            } else {
                addr += 1;
            }

            var j: u3 = 0;

            // For use with "; =$XX" comment suffixes
            var comment_val: u8 = 0;

            while (j < opcode.operands.len) : (j += 1) {
                const operand = opcode.operands[j];
                const next_addr = addr + operand.bytes;

                // HACKS: Omit certain implied operands (chiefly A register in 0th operand position)
                if (j == 0 and operand.bytes == 0 and switch (opcode.mnemonic) {
                    .ADD, .ADC, .SBC => true,
                    else => false,
                }) {
                    addr = next_addr;
                    continue;
                }

                if (operand.bytes == 2) {
                    try writer.print(" {}", .{OperandValue(u16){ .operand = &operand, .val = self.cpu.bus.read_16(addr), .addr = next_addr }});
                } else if (operand.bytes == 1) {
                    const op = OperandValue(u8){ .operand = &operand, .val = self.cpu.bus.read(addr), .addr = next_addr };
                    if (operand.name == .a8) {
                        comment_val = op.val;
                    }
                    try writer.print(" {}", .{op});
                } else if (operand.immediate) {
                    try writer.print(" {s}", .{operand.name.string()});
                } else {
                    try writer.print(" [{s}]", .{operand.name.string()});
                }

                if (j < opcode.operands.len - 1) {
                    try writer.print(",", .{});
                }
                addr = next_addr;
            }

            if (opcode.mnemonic == .LDH) {
                try writer.print(" ; =${x:0>2}", .{comment_val});
            }

            try writer.print("\n", .{});
        }
        self.cpu.bus.rom.__HACK__PRINTING_DEBUG_INFO = false;
    }
};

fn OperandValue(comptime T: type) type {
    return struct {
        operand: *const Operand,
        val: T,
        addr: u16,
        const U8_IMM_FMT = "${x:0>2}";
        const U8_FMT = "[${x:0>2}]";
        const I8_IMM_FMT = "{}";
        const U16_IMM_FMT = "${x:0>4}";
        const U16_FMT = "[${x:0>4}]";
        pub fn format(self: *const OperandValue(T), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            return switch (self.operand.name) {
                .a8 => {
                    if (self.operand.immediate) {
                        return writer.print(U8_IMM_FMT, .{self.val});
                    }

                    const hw_reg_str = hardware_register_string(@truncate(u8, self.val));
                    if (hw_reg_str.len > 0) {
                        return writer.print("[{s} & $FF]", .{hw_reg_str});
                    } else {
                        return writer.print("[$FF00 + ${x:0>2}]", .{self.val});
                    }
                },
                .d8 => {
                    if (self.operand.immediate) {
                        return writer.print(U8_IMM_FMT, .{self.val});
                    } else {
                        return writer.print(U8_FMT, .{self.val});
                    }
                },
                .r8 => {
                    const offset = @bitCast(i8, @truncate(u8, self.val));

                    // There *must* be a better way to do this in zig:
                    const new_addr: u16 = if (offset > 0)
                        self.addr +% @intCast(u16, offset)
                    else
                        self.addr -% @intCast(u16, -offset);

                    return writer.print(U16_IMM_FMT, .{new_addr});
                },

                .a16, .d16 => {
                    if (self.operand.immediate) {
                        return writer.print(U16_IMM_FMT, .{self.val});
                    } else {
                        return writer.print(U16_FMT, .{self.val});
                    }
                },
                else => self.operand.format(fmt, options, writer),
            };
        }
    };
}

const expect = std.testing.expect;
// test "16 bit registers" {
//     var ppu = try PPU.init(std.testing.allocator);
//     var bus_ = try Bus.init(std.testing.allocator, &Rom{
//         ._raw_data = try std.testing.allocator.alloc(u8, 1),
//         .allocator = std.testing.allocator,
//     }, &ppu);
//     defer bus_.deinit();
//     defer bus_.rom.deinit();

//     try expect((CPU{ .allocator = std.testing.allocator, .callsites = std.ArrayList(Callsite).init(std.testing.allocator), .bus = &bus_, .a = 0xAA, .f = 0xBB }).af() == 0xAABB);
//     try expect((CPU{ .allocator = std.testing.allocator, .callsites = std.ArrayList(Callsite).init(std.testing.allocator), .bus = &bus_, .b = 0xAA, .c = 0xBB }).bc() == 0xAABB);
//     try expect((CPU{ .allocator = std.testing.allocator, .callsites = std.ArrayList(Callsite).init(std.testing.allocator), .bus = &bus_, .d = 0xAA, .e = 0xBB }).de() == 0xAABB);
//     try expect((CPU{ .allocator = std.testing.allocator, .callsites = std.ArrayList(Callsite).init(std.testing.allocator), .bus = &bus_, .h = 0xAA, .l = 0xBB }).hl() == 0xAABB);

//     var cpu = CPU{
//         .allocator = std.testing.allocator,
//         .bus = &bus_,
//         .callsites = std.ArrayList(Callsite).init(std.testing.allocator),
//     };
//     bus_.cpu = &cpu;
//     cpu.set_af(0xAABB);
//     try expect(cpu.a == 0xAA);
//     try expect(cpu.f == 0xB0);
//     cpu.set_bc(0xAABB);
//     try expect(cpu.b == 0xAA);
//     try expect(cpu.c == 0xBB);
//     cpu.set_de(0xAABB);
//     try expect(cpu.d == 0xAA);
//     try expect(cpu.e == 0xBB);
//     cpu.set_hl(0xAABB);
//     try expect(cpu.h == 0xAA);
//     try expect(cpu.l == 0xBB);
// }

// test "flags" {
//     var bus_ = try Bus.init(std.testing.allocator, &Rom{
//         ._raw_data = try std.testing.allocator.alloc(u8, 1),
//         .allocator = std.testing.allocator,
//     });
//     defer bus_.deinit();
//     defer bus_.rom.deinit();
//     var cpu = CPU{ .allocator = std.testing.allocator, .bus = &bus_ };
//     bus_.cpu = &cpu;

//     try expect(cpu.flag(Flag.zero) == false);
//     try expect(cpu.flag(Flag.subtract) == false);
//     try expect(cpu.flag(Flag.halfCarry) == false);
//     try expect(cpu.flag(Flag.carry) == false);

//     cpu.set_flag(Flag.zero, true);
//     try expect(cpu.flag(Flag.zero) == true);
//     try expect(cpu.flag(Flag.subtract) == false);
//     try expect(cpu.flag(Flag.halfCarry) == false);
//     try expect(cpu.flag(Flag.carry) == false);
//     cpu.set_flag(Flag.zero, false);
//     try expect(cpu.flag(Flag.zero) == false);
//     try expect(cpu.flag(Flag.subtract) == false);
//     try expect(cpu.flag(Flag.halfCarry) == false);
//     try expect(cpu.flag(Flag.carry) == false);

//     cpu.set_flag(Flag.subtract, true);
//     try expect(cpu.flag(Flag.zero) == false);
//     try expect(cpu.flag(Flag.subtract) == true);
//     try expect(cpu.flag(Flag.halfCarry) == false);
//     try expect(cpu.flag(Flag.carry) == false);
//     cpu.set_flag(Flag.subtract, false);
//     try expect(cpu.flag(Flag.zero) == false);
//     try expect(cpu.flag(Flag.subtract) == false);
//     try expect(cpu.flag(Flag.halfCarry) == false);
//     try expect(cpu.flag(Flag.carry) == false);

//     cpu.set_flag(Flag.halfCarry, true);
//     try expect(cpu.flag(Flag.zero) == false);
//     try expect(cpu.flag(Flag.subtract) == false);
//     try expect(cpu.flag(Flag.halfCarry) == true);
//     try expect(cpu.flag(Flag.carry) == false);
//     cpu.set_flag(Flag.halfCarry, false);
//     try expect(cpu.flag(Flag.zero) == false);
//     try expect(cpu.flag(Flag.subtract) == false);
//     try expect(cpu.flag(Flag.halfCarry) == false);
//     try expect(cpu.flag(Flag.carry) == false);

//     cpu.set_flag(Flag.carry, true);
//     try expect(cpu.flag(Flag.zero) == false);
//     try expect(cpu.flag(Flag.subtract) == false);
//     try expect(cpu.flag(Flag.halfCarry) == false);
//     try expect(cpu.flag(Flag.carry) == true);
//     cpu.set_flag(Flag.carry, false);
//     try expect(cpu.flag(Flag.zero) == false);
//     try expect(cpu.flag(Flag.subtract) == false);
//     try expect(cpu.flag(Flag.halfCarry) == false);
//     try expect(cpu.flag(Flag.carry) == false);
// }

// test "boot" {
//     var bus_ = try Bus.init(std.testing.allocator, &Rom{
//         ._raw_data = try std.testing.allocator.alloc(u8, 1),
//         .allocator = std.testing.allocator,
//     });
//     defer bus_.deinit();
//     defer bus_.rom.deinit();

//     var cpu = CPU{ .allocator = std.testing.allocator, .bus = &bus_ };
//     bus_.cpu = &cpu;
//     cpu.boot();
//     try expect(cpu.a == 0x01);
//     try expect(cpu.flag(Flag.zero) == true);
//     try expect(cpu.flag(Flag.subtract) == false);
//     try expect(cpu.flag(Flag.halfCarry) == true);
//     try expect(cpu.flag(Flag.carry) == true);
//     try expect(cpu.b == 0x00);
//     try expect(cpu.c == 0x13);
//     try expect(cpu.d == 0x00);
//     try expect(cpu.e == 0xD8);
//     try expect(cpu.h == 0x01);
//     try expect(cpu.l == 0x4D);
//     try expect(cpu.pc == 0x0100);
//     try expect(cpu.sp == 0xFFFE);
// }

// test "CPU::opcode" {
//     const raw_data = try std.testing.allocator.alloc(u8, 4);
//     // NOP
//     raw_data[0x0000] = 0x00;

//     // CB RLC
//     raw_data[0x0001] = 0xCB;
//     raw_data[0x0002] = 0x00;

//     // LD B, D
//     raw_data[0x0003] = 0x42;
//     var bus_ = try Bus.init(std.testing.allocator, &Rom{ ._raw_data = raw_data, .allocator = std.testing.allocator });
//     defer bus_.deinit();
//     defer bus_.rom.deinit();
//     var cpu = CPU{ .allocator = std.testing.allocator, .bus = &bus_ };
//     bus_.cpu = &cpu;

//     // HACK: Disable boot ROM:
//     cpu.hardwareRegisters[0x50] = 0x01;

//     var opcode = cpu.opcode_at(0x0000);
//     try expect(opcode.mnemonic == .NOP);

//     opcode = cpu.opcode_at(0x0001);
//     try expect(opcode.mnemonic == .RLC);

//     opcode = cpu.opcode_at(0x0003);
//     try expect(opcode.mnemonic == .LD);
//     try expect(opcode.operands[0].name == .B);
//     try expect(opcode.operands[1].name == .D);
// }
