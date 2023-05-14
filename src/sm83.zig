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

const SM83 = struct {
    bus: Bus,

    //
    // General purpose registers
    //

    a: u8 = 0,
    f: u8 = 0,
    b: u8 = 0,
    c: u8 = 0,
    d: u8 = 0,
    e: u8 = 0,
    h: u8 = 0,
    l: u8 = 0,

    /// Flags register
    ///
    /// See also:
    ///
    /// - `flag` method
    /// - `set_flag` method
    flags: u8 = 0,

    /// Stack pointer
    sp: u16 = 0,

    /// Program counter
    pc: u16 = 0,

    //
    // Internals
    //
    cyclesLeft: u8 = 0,

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

    pub fn flag(self: SM83, comptime mask: Flag) bool {
        return (self.flags & @enumToInt(mask)) != 0;
    }

    pub fn set_flag(self: *SM83, comptime mask: Flag, val: bool) void {
        self.flags = if (val) self.flags | @enumToInt(mask) else self.flags & ~@enumToInt(mask);
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

        // TODO: Initialize hardware registers (on the bus) based on this table:
        //
        // https://gbdev.io/pandocs/Power_Up_Sequence.html#hardware-registers
    }

    pub fn cycle(self: *SM83) void {
        // We are not (yet) implementing a "cycle accurate" emulator, so we
        // essentially just do all our execution at once, once our cycle counter
        // has reached 0.
        if (self.cyclesLeft == 0) {
            const opcode = self.opcode_at(self.pc);
            self.pc += 1;

            // Set the cycle counter to the first cycle count; for some
            // instructions like conditional jumps, the number of cycles
            // actually depends on the result of the condition, so we use `var`
            // here to allow these instructions to override the result as
            // needed.
            var nextCyclesLeft = opcode.cycles[0];

            switch (opcode.mnemonic) {
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
                .LD => {
                    const to = opcode.operands[0];
                    const from = opcode.operands[1];
                    // FIXME: We should use something like `.double == true` instead
                    if (from.bytes == 2) {
                        const data = self.read_operand_u16(&from);
                        self.write_operand_u16(data, &to);
                    } else {
                        const data = self.read_operand_u8(&from);
                        self.write_operand_u8(data, &to);
                    }
                },
                else => {
                    panic("{s} not implemented!", .{opcode.mnemonic.string()});
                },
            }

            self.pc += opcode.bytes - 1;

            // TODO: Handle flags

            self.cyclesLeft = nextCyclesLeft;
        }

        self.cyclesLeft -= 1;
    }

    pub fn read_operand_u8(self: *const SM83, operand: *const Operand) u8 {
        switch (operand.name) {
            .A => {
                return self.a;
            },
            .B => {
                return self.b;
            },
            .C => {
                return self.c;
            },
            .D => {
                return self.d;
            },
            .E => {
                return self.e;
            },
            .H => {
                return self.h;
            },
            .L => {
                return self.l;
            },
            .BC => {
                // FIXME: Perhaps we should have `Operand` and `Operand16`
                // structs instead so the type checker can help us deal with
                // this tediousness
                if (operand.immediate) {
                    @panic("Cannot get BC as 16-bit immediate value");
                }

                return self.bus.read(self.bc());
            },
            else => {
                panic("read_operand_u8 for .{s} not implemented!", .{operand.name.string()});
            },
        }
    }

    pub fn write_operand_u8(self: *SM83, data: u8, operand: *const Operand) void {
        switch (operand.name) {
            .A => {
                self.a = data;
            },
            .B => {
                self.b = data;
            },
            .C => {
                self.c = data;
            },
            .D => {
                self.d = data;
            },
            .E => {
                self.e = data;
            },
            .H => {
                self.h = data;
            },
            .L => {
                self.l = data;
            },

            .BC => {
                if (operand.immediate) {
                    panic("Cannot write 8 bit value to BC directly", .{});
                }

                self.bus.write(self.bc(), data);
            },

            else => {
                panic("write_operand_u8 for .{s} not implemented!", .{operand.name.string()});
            },
        }
    }

    pub fn read_operand_u16(self: *const SM83, operand: *const Operand) u16 {
        switch (operand.name) {
            .d16 => {
                return self.bus.read_16(self.pc);
            },
            else => {
                panic("read_operand_u16 for .{s} not implemented!", .{operand.name.string()});
            },
        }
    }

    pub fn write_operand_u16(self: *SM83, data: u16, operand: *const Operand) void {
        switch (operand.name) {
            .BC => {
                self.set_bc(data);
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
};

// const SM83Trace = struct {
//     opcode: *const Opcode,
//     data: []const u8,
//     pub fn print(self: *const SM83Trace) void {
//         std.debug.print("{s}", .{self.opcode.string()});
//     }
// };

const expect = std.testing.expect;
test "16 bit registers" {
    const bus_ = try Bus.init(std.testing.allocator, Rom{
        ._raw_data = try std.testing.allocator.alloc(u8, 1),
        .allocator = std.testing.allocator,
    });
    defer bus_.deinit();
    defer bus_.rom.deinit();

    try expect((SM83{ .bus = bus_, .a = 0xAA, .f = 0xBB }).af() == 0xAABB);
    try expect((SM83{ .bus = bus_, .b = 0xAA, .c = 0xBB }).bc() == 0xAABB);
    try expect((SM83{ .bus = bus_, .d = 0xAA, .e = 0xBB }).de() == 0xAABB);
    try expect((SM83{ .bus = bus_, .h = 0xAA, .l = 0xBB }).hl() == 0xAABB);

    var cpu = SM83{ .bus = bus_ };
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
    const bus_ = try Bus.init(std.testing.allocator, Rom{
        ._raw_data = try std.testing.allocator.alloc(u8, 1),
        .allocator = std.testing.allocator,
    });
    defer bus_.deinit();
    defer bus_.rom.deinit();
    var cpu = SM83{ .bus = bus_ };

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
    const bus_ = try Bus.init(std.testing.allocator, Rom{
        ._raw_data = try std.testing.allocator.alloc(u8, 1),
        .allocator = std.testing.allocator,
    });
    defer bus_.deinit();
    defer bus_.rom.deinit();

    var cpu = SM83{ .bus = bus_ };
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
    const bus_ = try Bus.init(std.testing.allocator, Rom{ ._raw_data = raw_data, .allocator = std.testing.allocator });
    defer bus_.deinit();
    defer bus_.rom.deinit();
    const sm83 = SM83{ .bus = bus_ };

    var opcode = sm83.opcode_at(0x0000);
    try expect(opcode.mnemonic == .NOP);

    opcode = sm83.opcode_at(0x0001);
    try expect(opcode.mnemonic == .RLC);

    opcode = sm83.opcode_at(0x0003);
    try expect(opcode.mnemonic == .LD);
    try expect(opcode.operands[0].name == .B);
    try expect(opcode.operands[1].name == .D);
}

test "basic cycle (LD)" {
    const raw_data = try std.testing.allocator.alloc(u8, 10);

    const bus_ = try Bus.init(std.testing.allocator, Rom{ ._raw_data = raw_data, .allocator = std.testing.allocator });
    defer bus_.deinit();
    defer bus_.rom.deinit();
    var sm83 = SM83{ .bus = bus_ };

    // LD BC, $1234
    raw_data[0x0000] = 0x01;
    raw_data[0x0001] = 0x34;
    raw_data[0x0002] = 0x12;
    var i: usize = 0;
    while (i < 8) : (i += 1) sm83.cycle();
    try expect(sm83.bc() == 0x1234);
    try expect(sm83.pc == 0x0003);

    // LD (BC), A
    // We write 0x42 to the start of RAM:
    raw_data[0x0003] = 0x02;
    sm83.a = 0x42;
    sm83.set_bc(0xC000);

    i = 0;
    while (i < 8) : (i += 1) sm83.cycle();
    try expect(sm83.bus.read(0xC000) == 0x42);
    try expect(sm83.pc == 0x0004);
}

test "basic cycle (INC)" {
    const raw_data = try std.testing.allocator.alloc(u8, 10);
    // INC A
    raw_data[0x0000] = 0x3C;
    // INC B
    raw_data[0x0001] = 0x04;
    // INC C
    raw_data[0x0002] = 0x0C;
    // INC D
    raw_data[0x0003] = 0x14;
    // INC E
    raw_data[0x0004] = 0x1C;
    // INC H
    raw_data[0x0005] = 0x24;
    // INC L
    raw_data[0x0006] = 0x2C;

    const bus_ = try Bus.init(std.testing.allocator, Rom{ ._raw_data = raw_data, .allocator = std.testing.allocator });
    defer bus_.deinit();
    defer bus_.rom.deinit();
    var sm83 = SM83{ .bus = bus_ };

    var i: usize = 0;
    while (i < 4) : (i += 1) sm83.cycle();
    try expect(sm83.a == 0x01);

    i = 0;
    while (i < 4) : (i += 1) sm83.cycle();
    try expect(sm83.b == 0x01);

    i = 0;
    while (i < 4) : (i += 1) sm83.cycle();
    try expect(sm83.c == 0x01);

    i = 0;
    while (i < 4) : (i += 1) sm83.cycle();
    try expect(sm83.d == 0x01);

    i = 0;
    while (i < 4) : (i += 1) sm83.cycle();
    try expect(sm83.e == 0x01);

    i = 0;
    while (i < 4) : (i += 1) sm83.cycle();
    try expect(sm83.h == 0x01);

    i = 0;
    while (i < 4) : (i += 1) sm83.cycle();
    try expect(sm83.l == 0x01);
}
