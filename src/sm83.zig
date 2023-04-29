//! Sharp SM83 CPU emulator implementation
//!
//! References I've found helpful:
//!
//! - gekkio's guide: https://gekkio.fi/files/gb-docs/gbctr.pdf
//! - Description of opcodes: https://gb-archive.github.io/salvage/decoding_gbz80_opcodes/Decoding%20Gamboy%20Z80%20Opcodes.html
//! - Opcode matrix: https://gbdev.io/gb-opcodes/optables/
//! - Opcode JSON (useful for codegen): https://gbdev.io/gb-opcodes/Opcodes.json

// No gods, no kings, only bus
const bus = @import("./bus.zig");
const Bus = bus.Bus;

const rom = @import("./rom.zig");
const Rom = rom.Rom;

const opcodes = @import("./sm83-opcodes.zig");

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
        if (self.cyclesLeft != 0) {
            self.cyclesLeft -= 1;
        }

        const op = self.bus.read(self.pc);
        if (op == 0xCB) {
            // Handle prefixes
        } else {
            // Handle normal instructions
        }
    }
};

const std = @import("std");
const expect = std.testing.expect;
test "16 bit registers" {
    const bus_ = Bus{
        .rom = Rom{
            ._raw_data = try std.testing.allocator.alloc(u8, 1),
            .allocator = std.testing.allocator,
        },
    };

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
    const bus_ = Bus{
        .rom = Rom{
            ._raw_data = try std.testing.allocator.alloc(u8, 1),
            .allocator = std.testing.allocator,
        },
    };
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
    const bus_ = Bus{
        .rom = Rom{
            ._raw_data = try std.testing.allocator.alloc(u8, 1),
            .allocator = std.testing.allocator,
        },
    };

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
