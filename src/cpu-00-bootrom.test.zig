//! SM83 "integration" tests

const std = @import("std");
const expect = std.testing.expect;

// No gods, no kings, only bus
const Bus = @import("./bus.zig").Bus;
const Rom = @import("./rom.zig").Rom;
const SM83 = @import("./sm83.zig").SM83;

test "bootrom log comparison" {
    var rom = try Rom.from_file("test-roms/01-special.gb", std.testing.allocator);
    defer rom.deinit();

    var bus = try Bus.init(std.testing.allocator, rom);
    defer bus.deinit();

    var cpu = SM83{ .bus = &bus };
    bus.cpu = &cpu;

    // Load BootromLog.txt from https://github.com/wheremyfoodat/Gameboy-logs
    const file = try std.fs.cwd().openFile("src/BootromLog.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var expectedBuf: [1024]u8 = undefined;
    var actualBuf: [1024]u8 = undefined;

    // From the docs for Gameboy-logs:
    //
    // > For the convenience of anyone who uses them, LY (MMIO register at
    // > 0xFF44) is stubbed to 0x90 permanently.
    cpu.hardwareRegisters[0x44] = 0x90;

    while (try in_stream.readUntilDelimiterOrEof(&expectedBuf, '\n')) |expected| {
        try std.testing.expectEqualStrings(expected, try std.fmt.bufPrint(&actualBuf, "{}", .{cpu}));
        cpu.step();
    }
}