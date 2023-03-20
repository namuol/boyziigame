//! Sharp SM83 CPU emulator implementation
//!
//! Reference: https://gekkio.fi/files/gb-docs/gbctr.pdf

const FLAG_ZERO_POS: usize = 7;
const FLAG_SUBTRACT_POS: usize = 6;
const FLAG_HALF_CARRY_POS: usize = 5;
const FLAG_CARRY_POS: usize = 4;

const FLAG_ZERO_MASK: u8 = 0b1 << FLAG_ZERO_POS;
const FLAG_SUBTRACT_MASK: u8 = 0b1 << FLAG_SUBTRACT_POS;
const FLAG_HALF_CARRY_MASK: u8 = 0b1 << FLAG_HALF_CARRY_POS;
const FLAG_CARRY_MASK: u8 = 0b1 << FLAG_CARRY_POS;

const SM83 = struct {
    a: u8 = 0,
    b: u8 = 0,
    c: u8 = 0,
    d: u8 = 0,
    e: u8 = 0,
    f: u8 = 0,
    h: u8 = 0,
    l: u8 = 0,

    flags: u8 = 0,

    sp: u16 = 0,
    pc: u16 = 0,

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

    pub fn flag_zero(self: SM83) bool {
        return (self.flags >> FLAG_ZERO_POS) & 0b1 == 0b1;
    }
    pub fn set_flag_zero(self: *SM83, val: bool) void {
        self.flags = if (val) self.flags | FLAG_ZERO_MASK else self.flags & ~FLAG_ZERO_MASK;
    }
    pub fn flag_subtract(self: SM83) bool {
        return (self.flags >> FLAG_SUBTRACT_POS) & 0b1 == 0b1;
    }
    pub fn set_flag_subtract(self: *SM83, val: bool) void {
        self.flags = if (val) self.flags | FLAG_SUBTRACT_MASK else self.flags & ~FLAG_SUBTRACT_MASK;
    }
    pub fn flag_half_carry(self: SM83) bool {
        return (self.flags >> FLAG_HALF_CARRY_POS) & 0b1 == 0b1;
    }
    pub fn set_flag_half_carry(self: *SM83, val: bool) void {
        self.flags = if (val) self.flags | FLAG_HALF_CARRY_MASK else self.flags & ~FLAG_HALF_CARRY_MASK;
    }
    pub fn flag_carry(self: SM83) bool {
        return (self.flags & FLAG_CARRY_MASK) != 0;
    }
    pub fn set_flag_carry(self: *SM83, val: bool) void {
        self.flags = if (val) self.flags | FLAG_CARRY_MASK else self.flags & ~FLAG_CARRY_MASK;
    }
};

const std = @import("std");
const expect = std.testing.expect;
test "16 bit registers" {
    try expect((SM83{ .a = 0xAA, .f = 0xBB }).af() == 0xAABB);
    try expect((SM83{ .b = 0xAA, .c = 0xBB }).bc() == 0xAABB);
    try expect((SM83{ .d = 0xAA, .e = 0xBB }).de() == 0xAABB);
    try expect((SM83{ .h = 0xAA, .l = 0xBB }).hl() == 0xAABB);

    var cpu = SM83{};
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
    var cpu = SM83{};

    try expect(cpu.flag_zero() == false);
    try expect(cpu.flag_subtract() == false);
    try expect(cpu.flag_half_carry() == false);
    try expect(cpu.flag_carry() == false);

    cpu.set_flag_zero(true);
    try expect(cpu.flag_zero() == true);
    try expect(cpu.flag_subtract() == false);
    try expect(cpu.flag_half_carry() == false);
    try expect(cpu.flag_carry() == false);
    cpu.set_flag_zero(false);
    try expect(cpu.flag_zero() == false);
    try expect(cpu.flag_subtract() == false);
    try expect(cpu.flag_half_carry() == false);
    try expect(cpu.flag_carry() == false);

    cpu.set_flag_subtract(true);
    try expect(cpu.flag_zero() == false);
    try expect(cpu.flag_subtract() == true);
    try expect(cpu.flag_half_carry() == false);
    try expect(cpu.flag_carry() == false);
    cpu.set_flag_subtract(false);
    try expect(cpu.flag_zero() == false);
    try expect(cpu.flag_subtract() == false);
    try expect(cpu.flag_half_carry() == false);
    try expect(cpu.flag_carry() == false);

    cpu.set_flag_half_carry(true);
    try expect(cpu.flag_zero() == false);
    try expect(cpu.flag_subtract() == false);
    try expect(cpu.flag_half_carry() == true);
    try expect(cpu.flag_carry() == false);
    cpu.set_flag_half_carry(false);
    try expect(cpu.flag_zero() == false);
    try expect(cpu.flag_subtract() == false);
    try expect(cpu.flag_half_carry() == false);
    try expect(cpu.flag_carry() == false);

    cpu.set_flag_carry(true);
    try expect(cpu.flag_zero() == false);
    try expect(cpu.flag_subtract() == false);
    try expect(cpu.flag_half_carry() == false);
    try expect(cpu.flag_carry() == true);
    cpu.set_flag_carry(false);
    try expect(cpu.flag_zero() == false);
    try expect(cpu.flag_subtract() == false);
    try expect(cpu.flag_half_carry() == false);
    try expect(cpu.flag_carry() == false);
}
