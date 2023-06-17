//! Sharp SM83 CPU emulator implementation
//!
//! References I've found helpful:
//!
//! - gekkio's guide: https://gekkio.fi/files/gb-docs/gbctr.pdf
//! - Description of opcodes: https://gb-archive.github.io/salvage/decoding_gbz80_opcodes/Decoding%20Gamboy%20Z80%20Opcodes.html
//! - Opcode matrix: https://gbdev.io/gb-opcodes/optables/
//! - Opcode JSON (useful for codegen): https://gbdev.io/gb-opcodes/Opcodes.json
const std = @import("std");

// No gods, no kings, only bus
const bus = @import("./bus.zig");
const Bus = bus.Bus;

const rom = @import("./rom.zig");
const Rom = rom.Rom;
const hardware_registers = @import("./sm83-hardware-registers.zig");
const hardware_register_string = hardware_registers.hardware_register_string;

const opcodes = @import("./sm83-opcodes.zig");
const Opcode = opcodes.Opcode;
const Operand = opcodes.Operand;

const panic = std.debug.panic;

const Flag = enum(u8) {
    zero = 0b1 << 7,
    subtract = 0b1 << 6,
    halfCarry = 0b1 << 5,
    carry = 0b1 << 4,
};

pub const SM83 = struct {
    bus: *Bus,

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

    //
    // Internals
    //
    cyclesLeft: u8 = 0,

    /// Used to support the `DI` instruction.
    ///
    /// From the "Game Boy CPU Manual":
    ///
    /// > This instruction disables interrupts but not immediately. Interrupts
    /// > are disabled after instruction after DI is executed.
    disableInterruptsAfterNextInstruction: bool = false,
    enableInterruptsAfterNextInstruction: bool = false,

    hardwareRegisters: [256]u8 = [_]u8{0} ** 256,

    pub fn read_hw_register(self: *const SM83, addr: u8) u8 {
        // std.debug.print("read_hw_register(0x{x:0>2}) = 0x{x:0>2}\n", .{ addr, self.hardwareRegisters[addr] });
        return self.hardwareRegisters[addr];
    }

    pub fn write_hw_register(self: *SM83, addr: u8, data: u8) void {
        // std.debug.print("write_hw_register(0x{x:0>2}, 0x{x:0>2})\n", .{ addr, data });
        self.hardwareRegisters[addr] = data;
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
    //     var cpu = SM83 {};
    //     cpu.a = 0xAA;
    //     cpu.f = 0xFF;
    //     try expect(cpu.af == 0xAAFF);
    // }
    //
    // test "write 16 bit registers" {
    //     var cpu = SM83 {};
    //     cpu.af = 0xAAFF;
    //     try expect(cpu.a == 0xAA);
    //     try expect(cpu.f == 0xFF);
    // }
    // ```
    //

    pub fn af(self: SM83) u16 {
        return @as(u16, self.a) << 8 | @as(u16, self.f);
    }
    pub fn set_af(self: *SM83, val: u16) void {
        self.a = @truncate(u8, (val & 0xFF00) >> 8);
        self.f = @truncate(u8, val & 0xFF);
    }

    pub fn bc(self: SM83) u16 {
        return @as(u16, self.b) << 8 | @as(u16, self.c);
    }
    pub fn set_bc(self: *SM83, val: u16) void {
        self.b = @truncate(u8, (val & 0xFF00) >> 8);
        self.c = @truncate(u8, val & 0xFF);
    }

    pub fn de(self: SM83) u16 {
        return @as(u16, self.d) << 8 | @as(u16, self.e);
    }
    pub fn set_de(self: *SM83, val: u16) void {
        self.d = @truncate(u8, (val & 0xFF00) >> 8);
        self.e = @truncate(u8, val & 0xFF);
    }

    pub fn hl(self: SM83) u16 {
        return @as(u16, self.h) << 8 | @as(u16, self.l);
    }
    pub fn set_hl(self: *SM83, val: u16) void {
        self.h = @truncate(u8, (val & 0xFF00) >> 8);
        self.l = @truncate(u8, val & 0xFF);
    }

    //
    // Flag methods
    //

    pub fn flag(self: *const SM83, comptime mask: Flag) bool {
        return (self.f & @enumToInt(mask)) != 0;
    }

    pub fn set_flag(self: *SM83, comptime mask: Flag, val: bool) void {
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
    pub fn boot(self: *SM83) void {
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

        self.pc = 0x0100;
        self.sp = 0xFFFE;

        hardware_registers.dmg_reset(&self.hardwareRegisters);

        // HACK: Initialize rLCD to 0x80; LCD & PPU enabled, all other flags unset
        self.hardwareRegisters[0x40] = 0x80;

        // HACK: Initialize rLY to 0x91 (145), first vblank row of pixels.
        self.hardwareRegisters[0x44] = 0x91;
    }

    pub fn cycle(self: *SM83) bool {
        const stepped = self.cyclesLeft == 0;
        // We are not (yet) implementing a "cycle accurate" emulator, so we
        // essentially just do all our execution at once, once our cycle counter
        // has reached 0.
        if (self.cyclesLeft == 0) {
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
                    switch (opcode.operands.len) {
                        1 => {
                            const addr = self.read_operand_u16(&opcode.operands[0]);
                            self.pc = addr;
                        },
                        // 2 => {},
                        else => {
                            panic("JP with {d} opcodes not supported!", .{opcode.operands.len});
                        },
                    }
                },
                .JR => {
                    const offset = self.read_operand_u8(&opcode.operands[opcode.operands.len - 1]);
                    const condition = if (opcode.operands.len == 1) true else switch (opcode.operands[0].name) {
                        .Z => self.flag(Flag.zero),
                        .NZ => !self.flag(Flag.zero),
                        .C => self.flag(Flag.carry),
                        .NC => !self.flag(Flag.carry),
                        else => {
                            panic("Unsupported JR condition: {s}", .{opcode.operands[0].name.string()});
                        },
                    };

                    if (condition) {
                        self.pc +%= offset;
                    }
                },
                .CALL => {
                    // Push address of next instruction onto stack
                    const next_instruction_addr = self.pc +% opcode.bytes -% 1;
                    // std.debug.print("next_instruction_addr = ${x:0>4}\n", .{next_instruction_addr});
                    self.sp -%= 2;
                    self.bus.write_16(self.sp, next_instruction_addr);
                    // Jump to the address specified by the call
                    self.pc = self.read_operand_u16(&opcode.operands[0]);
                },
                .RET => {
                    switch (opcode.operands.len) {
                        0 => {
                            // Pop two bytes from stack & jump to that address.
                            const addr = self.bus.read_16(self.sp);
                            self.sp +%= 2;
                            self.pc = addr;
                        },
                        else => {
                            @panic("RET with nonzero operand not implemented!");
                        },
                    }
                },
                .RST => {
                    // Push present address onto stack.
                    self.bus.write_16(self.sp, self.pc);
                    self.sp -%= 2;

                    // Jump to address $0000 + n
                    const offset = self.read_operand_u8(&opcode.operands[0]);
                    self.pc = 0x0000 + @intCast(u16, offset);
                },
                .CP => {
                    // Compare A with n. This is basically an A - n subtraction
                    // instruction but the results are thrown away.
                    const n = self.read_operand_u8(&opcode.operands[0]);
                    const result = self.a -% n;
                    self.set_flag(Flag.zero, result == 0);
                    self.set_flag(Flag.subtract, true);
                    self.set_flag(Flag.halfCarry, self.a & 8 == 0 and n & 8 == 8);
                    self.set_flag(Flag.carry, self.a < n);
                },
                .INC => {
                    if (opcode.operands.len > 1) {
                        @panic("Unexpected number of operands for INC");
                    }
                    const param = opcode.operands[0];
                    if (param.bytes == 2) {
                        @panic("16 bit INC not implemented");
                    } else {
                        const data = self.read_operand_u8(&param);
                        self.write_operand_u8(data + 1, &param);
                    }
                },
                .LD, .LDH => {
                    const to = opcode.operands[0];
                    const from = opcode.operands[1];
                    if (from.immediate and from.bytes == 2) {
                        const data = self.read_operand_u16(&from);
                        self.write_operand_u16(data, &to);
                    } else {
                        const data = self.read_operand_u8(&from);
                        self.write_operand_u8(data, &to);
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
                .XOR => {
                    const operand = opcode.operands[0];
                    const data = self.read_operand_u8(&operand);
                    self.a = self.a ^ data;
                    self.f = 0;
                    self.set_flag(Flag.zero, self.a == 0);
                },
                .DI => {
                    self.disableInterruptsAfterNextInstruction = true;
                },
                .EI => {
                    self.enableInterruptsAfterNextInstruction = true;
                },

                .ADD => {
                    const to = opcode.operands[0];
                    const from = opcode.operands[1];
                    const val = self.read_operand_u8(&to);
                    const n = self.read_operand_u8(&from);
                    const result = val +% n;
                    self.write_operand_u8(result, &to);
                    self.set_flag(Flag.zero, result == 0);
                    self.set_flag(Flag.subtract, true);
                    self.set_flag(Flag.halfCarry, val & 8 == 0 and n & 8 == 8);
                    self.set_flag(Flag.carry, val < n);
                },

                .RES => {
                    // Reset bit `b` in register `r`
                    const bit = opcode.operands[1];
                    const mask: u8 = switch (bit.name) {
                        ._0 => 0b1111_1110,
                        ._1 => 0b1111_1101,
                        ._2 => 0b1111_1111,
                        ._3 => 0b1111_0111,
                        ._4 => 0b1110_1111,
                        ._5 => 0b1101_1111,
                        ._6 => 0b1011_1111,
                        ._7 => 0b0111_1111,
                        else => {
                            panic("Unexpected bit operand for RES operation: {s}", .{bit.name.string()});
                        },
                    };
                    const register = opcode.operands[0];
                    switch (register.name) {
                        .A => self.a &= mask,
                        .B => self.b &= mask,
                        .C => self.c &= mask,
                        .D => self.d &= mask,
                        .E => self.e &= mask,
                        .H => self.h &= mask,
                        .L => self.l &= mask,
                        .HL => {
                            // I assume we are meant to reset the bit of the
                            // byte at the address contained in the `hl`
                            // register:
                            const addr = self.hl();
                            const val = self.bus.read(addr) & mask;
                            self.bus.write(addr, val);
                        },
                        else => {
                            panic("Unexpected register operand for RES operation: {s}", .{register.name.string()});
                        },
                    }
                },
                else => {
                    panic("{s} not implemented!", .{opcode.mnemonic.string()});
                },
            }

            self.cyclesLeft = nextCyclesLeft;

            if (self.disableInterruptsAfterNextInstruction and opcode.mnemonic != .DI) {
                self.hardwareRegisters[0xFF] = 0x0F & 0b0000;
            }
            if (self.enableInterruptsAfterNextInstruction and opcode.mnemonic != .EI) {
                self.hardwareRegisters[0xFF] = 0x0F & 0b1111;
            }
        }

        self.cyclesLeft -= 1;
        return stepped;
    }

    pub fn step(self: *SM83) void {
        while (!self.cycle()) {}
    }

    pub fn read_operand_u8_safe(self: *const SM83, operand: *const Operand) u8 {
        return switch (operand.name) {
            .A => self.a,
            .B => self.b,
            .C => if (operand.immediate) self.c else self.bus.read(0xFF00 +% @as(u16, self.c)),
            .D => self.d,
            .E => self.e,
            .H => self.h,
            .L => self.l,
            .BC => {
                // FIXME: Perhaps we should have `Operand` and `Operand16`
                // structs instead so the type checker can help us deal with
                // this tediousness
                if (operand.immediate) {
                    @panic("Cannot get BC as 8-bit immediate value");
                }

                return self.bus.read(self.bc());
            },
            .d8, .r8 => self.bus.read(self.pc),
            .a8 => {
                const offset = self.bus.read(self.pc);
                return self.bus.read(0xFF00 +% @as(u16, offset));
            },
            .d16 => {
                if (!operand.immediate) {
                    @panic("Cannot read 16-bit immediate value for d16");
                }
                const addr = self.bus.read_16(self.pc);
                return self.bus.read(addr);
            },

            ._08H => 0x08,
            ._10H => 0x10,
            ._18H => 0x18,
            ._20H => 0x20,
            ._28H => 0x28,
            ._30H => 0x30,
            ._38H => 0x38,

            else => {
                panic("read_operand_u8 for .{s} not implemented!", .{operand.name.string()});
            },
        };
    }

    pub fn read_operand_u8(self: *SM83, operand: *const Operand) u8 {
        const result = self.read_operand_u8_safe(operand);
        switch (operand.name) {
            .A, .B, .C, .D, .E, .H, .L, .BC, ._08H, ._10H, ._18H, ._20H, ._28H, ._30H, ._38H => {},
            .d8, .r8, .a8 => self.pc +%= 1,
            .d16 => self.pc +%= 2,
            else => {
                panic("read_operand_u8 for .{s} not implemented!", .{operand.name.string()});
            },
        }
        return result;
    }

    pub fn write_operand_u8(self: *SM83, data: u8, operand: *const Operand) void {
        switch (operand.name) {
            .A => self.a = data,
            .B => self.b = data,
            .C => self.c = data,
            .D => self.d = data,
            .E => self.e = data,
            .H => self.h = data,
            .L => self.l = data,

            .BC => {
                if (operand.immediate) {
                    panic("Cannot write 8 bit immediate value to .{s}", .{operand.name.string()});
                }
                self.bus.write(self.bc(), data);
            },

            .a16 => {
                if (operand.immediate) {
                    panic("Cannot write 8 bit immediate value to .{s}", .{operand.name.string()});
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
                panic("write_operand_u8 for .{s} not implemented!", .{operand.name.string()});
            },
        }
    }

    pub fn read_operand_u16_safe(self: *const SM83, operand: *const Operand) u16 {
        return switch (operand.name) {
            .d16, .a16 => if (operand.immediate)
                self.bus.read_16(self.pc)
            else
                self.bus.read_16(self.bus.read_16(self.pc)),
            else => {
                panic("read_operand_u16_safe for .{s} not implemented!", .{operand.name.string()});
            },
        };
    }

    pub fn read_operand_u16(self: *SM83, operand: *const Operand) u16 {
        const result = self.read_operand_u16_safe(operand);
        switch (operand.name) {
            .d16, .a16 => self.pc +%= 2,
            else => {
                panic("read_operand_u16 for .{s} not implemented!", .{operand.name.string()});
            },
        }
        return result;
    }

    pub fn write_operand_u16(self: *SM83, data: u16, operand: *const Operand) void {
        switch (operand.name) {
            .d16, .a16 => {
                const addr = self.read_operand_u16(operand);
                self.bus.write_16(addr, data);
            },
            .BC => {
                self.set_bc(data);
            },
            .SP => {
                self.sp = data;
            },
            else => {
                panic("write_operand_u16 for .{s} not implemented!", .{operand.name.string()});
            },
        }
    }

    pub fn opcode_at(self: *const SM83, addr: u16) Opcode {
        const op = self.bus.read(addr);
        if (op == 0xCB) {
            const prefixed_op = self.bus.read(addr + 1);
            return opcodes.PREFIXED[prefixed_op];
        } else {
            return opcodes.UNPREFIXED[op];
        }
    }

    pub fn disassemble(self: *const SM83, count: u16) Disassembly {
        return Disassembly{ .cpu = self, .count = count };
    }

    pub fn registers(self: *const SM83) Registers {
        return Registers{ .cpu = self };
    }
};

const Registers = struct {
    cpu: *const SM83,
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
    cpu: *const SM83,
    count: u16,
    pub fn format(self: *const Disassembly, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
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

                    const hw_reg_str = hardware_register_string(0xFF00 + @as(u16, self.val));
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
test "16 bit registers" {
    var bus_ = try Bus.init(std.testing.allocator, Rom{
        ._raw_data = try std.testing.allocator.alloc(u8, 1),
        .allocator = std.testing.allocator,
    });
    defer bus_.deinit();
    defer bus_.rom.deinit();

    try expect((SM83{ .bus = &bus_, .a = 0xAA, .f = 0xBB }).af() == 0xAABB);
    try expect((SM83{ .bus = &bus_, .b = 0xAA, .c = 0xBB }).bc() == 0xAABB);
    try expect((SM83{ .bus = &bus_, .d = 0xAA, .e = 0xBB }).de() == 0xAABB);
    try expect((SM83{ .bus = &bus_, .h = 0xAA, .l = 0xBB }).hl() == 0xAABB);

    var cpu = SM83{ .bus = &bus_ };
    bus_.cpu = &cpu;
    cpu.set_af(0xAABB);
    try expect(cpu.a == 0xAA);
    try expect(cpu.f == 0xBB);
    cpu.set_bc(0xAABB);
    try expect(cpu.b == 0xAA);
    try expect(cpu.c == 0xBB);
    cpu.set_de(0xAABB);
    try expect(cpu.d == 0xAA);
    try expect(cpu.e == 0xBB);
    cpu.set_hl(0xAABB);
    try expect(cpu.h == 0xAA);
    try expect(cpu.l == 0xBB);
}

test "flags" {
    var bus_ = try Bus.init(std.testing.allocator, Rom{
        ._raw_data = try std.testing.allocator.alloc(u8, 1),
        .allocator = std.testing.allocator,
    });
    defer bus_.deinit();
    defer bus_.rom.deinit();
    var cpu = SM83{ .bus = &bus_ };
    bus_.cpu = &cpu;

    try expect(cpu.flag(Flag.zero) == false);
    try expect(cpu.flag(Flag.subtract) == false);
    try expect(cpu.flag(Flag.halfCarry) == false);
    try expect(cpu.flag(Flag.carry) == false);

    cpu.set_flag(Flag.zero, true);
    try expect(cpu.flag(Flag.zero) == true);
    try expect(cpu.flag(Flag.subtract) == false);
    try expect(cpu.flag(Flag.halfCarry) == false);
    try expect(cpu.flag(Flag.carry) == false);
    cpu.set_flag(Flag.zero, false);
    try expect(cpu.flag(Flag.zero) == false);
    try expect(cpu.flag(Flag.subtract) == false);
    try expect(cpu.flag(Flag.halfCarry) == false);
    try expect(cpu.flag(Flag.carry) == false);

    cpu.set_flag(Flag.subtract, true);
    try expect(cpu.flag(Flag.zero) == false);
    try expect(cpu.flag(Flag.subtract) == true);
    try expect(cpu.flag(Flag.halfCarry) == false);
    try expect(cpu.flag(Flag.carry) == false);
    cpu.set_flag(Flag.subtract, false);
    try expect(cpu.flag(Flag.zero) == false);
    try expect(cpu.flag(Flag.subtract) == false);
    try expect(cpu.flag(Flag.halfCarry) == false);
    try expect(cpu.flag(Flag.carry) == false);

    cpu.set_flag(Flag.halfCarry, true);
    try expect(cpu.flag(Flag.zero) == false);
    try expect(cpu.flag(Flag.subtract) == false);
    try expect(cpu.flag(Flag.halfCarry) == true);
    try expect(cpu.flag(Flag.carry) == false);
    cpu.set_flag(Flag.halfCarry, false);
    try expect(cpu.flag(Flag.zero) == false);
    try expect(cpu.flag(Flag.subtract) == false);
    try expect(cpu.flag(Flag.halfCarry) == false);
    try expect(cpu.flag(Flag.carry) == false);

    cpu.set_flag(Flag.carry, true);
    try expect(cpu.flag(Flag.zero) == false);
    try expect(cpu.flag(Flag.subtract) == false);
    try expect(cpu.flag(Flag.halfCarry) == false);
    try expect(cpu.flag(Flag.carry) == true);
    cpu.set_flag(Flag.carry, false);
    try expect(cpu.flag(Flag.zero) == false);
    try expect(cpu.flag(Flag.subtract) == false);
    try expect(cpu.flag(Flag.halfCarry) == false);
    try expect(cpu.flag(Flag.carry) == false);
}

test "boot" {
    var bus_ = try Bus.init(std.testing.allocator, Rom{
        ._raw_data = try std.testing.allocator.alloc(u8, 1),
        .allocator = std.testing.allocator,
    });
    defer bus_.deinit();
    defer bus_.rom.deinit();

    var cpu = SM83{ .bus = &bus_ };
    bus_.cpu = &cpu;
    cpu.boot();
    try expect(cpu.a == 0x01);
    try expect(cpu.flag(Flag.zero) == true);
    try expect(cpu.flag(Flag.subtract) == false);
    try expect(cpu.flag(Flag.halfCarry) == true);
    try expect(cpu.flag(Flag.carry) == true);
    try expect(cpu.b == 0x00);
    try expect(cpu.c == 0x13);
    try expect(cpu.d == 0x00);
    try expect(cpu.e == 0xD8);
    try expect(cpu.h == 0x01);
    try expect(cpu.l == 0x4D);
    try expect(cpu.pc == 0x0100);
    try expect(cpu.sp == 0xFFFE);
}

test "SM83::opcode" {
    const raw_data = try std.testing.allocator.alloc(u8, 4);
    // NOP
    raw_data[0x0000] = 0x00;

    // CB RLC
    raw_data[0x0001] = 0xCB;
    raw_data[0x0002] = 0x00;

    // LD B, D
    raw_data[0x0003] = 0x42;
    var bus_ = try Bus.init(std.testing.allocator, Rom{ ._raw_data = raw_data, .allocator = std.testing.allocator });
    defer bus_.deinit();
    defer bus_.rom.deinit();
    var cpu = SM83{ .bus = &bus_ };
    bus_.cpu = &cpu;

    var opcode = cpu.opcode_at(0x0000);
    try expect(opcode.mnemonic == .NOP);

    opcode = cpu.opcode_at(0x0001);
    try expect(opcode.mnemonic == .RLC);

    opcode = cpu.opcode_at(0x0003);
    try expect(opcode.mnemonic == .LD);
    try expect(opcode.operands[0].name == .B);
    try expect(opcode.operands[1].name == .D);
}
