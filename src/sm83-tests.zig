//! SM83 "integration" tests

const std = @import("std");
const expect = std.testing.expect;

// No gods, no kings, only bus
const Bus = @import("./bus.zig").Bus;
const Rom = @import("./rom.zig").Rom;
const SM83 = @import("./sm83.zig").SM83;

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
    sm83.step();
    try expect(sm83.bc() == 0x1234);
    try expect(sm83.pc == 0x0003);

    // LD (BC), A
    // We write 0x42 to the start of RAM:
    raw_data[0x0003] = 0x02;
    sm83.a = 0x42;
    sm83.set_bc(0xC000);
    i = 0;
    sm83.step();
    try expect(sm83.bus.read(0xC000) == 0x42);
    try expect(sm83.pc == 0x0004);

    // LD A, $42
    raw_data[0x0004] = 0x3E;
    raw_data[0x0005] = 0x42;
    sm83.a = 0;
    i = 0;
    sm83.step();
    try expect(sm83.a == 0x42);
    try expect(sm83.pc == 0x0006);
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

    sm83.step();
    try expect(sm83.a == 0x01);

    sm83.step();
    try expect(sm83.b == 0x01);

    sm83.step();
    try expect(sm83.c == 0x01);

    sm83.step();
    try expect(sm83.d == 0x01);

    sm83.step();
    try expect(sm83.e == 0x01);

    sm83.step();
    try expect(sm83.h == 0x01);

    sm83.step();
    try expect(sm83.l == 0x01);
}

test "real world ROM" {
    var rom = try Rom.from_file("pokemon_blue.gb", std.testing.allocator);
    defer rom.deinit();

    const bus = try Bus.init(std.testing.allocator, rom);
    defer bus.deinit();

    var cpu = SM83{ .bus = bus };
    cpu.boot();
    cpu.trace();

    cpu.step();
    cpu.trace();

    cpu.step();
    cpu.trace();

    cpu.step();
    cpu.trace();

    cpu.step();
    cpu.trace();
    std.debug.print("\n", .{});
}
