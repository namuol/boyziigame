//! SM83 "integration" tests

const std = @import("std");
const expect = std.testing.expect;

// No gods, no kings, only bus
const Bus = @import("./bus.zig").Bus;
const Rom = @import("./rom.zig").Rom;
const SM83 = @import("./sm83.zig").SM83;

pub fn run() !void {
    var rom = try Rom.from_file("test-roms/05-op rp.gb", std.testing.allocator);
    defer rom.deinit();

    var bus = try Bus.init(std.testing.allocator, rom);
    defer bus.deinit();

    var cpu = SM83{ .bus = &bus };
    bus.cpu = &cpu;

    // https://github.com/wheremyfoodat/Gameboy-logs - Blargg4LYStubbed.zip
    const file = try std.fs.cwd().openFile("test-roms/05-op rp.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var readBuf: [1024]u8 = undefined;
    var expectedBuf: [1024]u8 = undefined;
    var actualBuf: [1024]u8 = undefined;

    // From the docs for Gameboy-logs:
    //
    // > For the convenience of anyone who uses them, LY (MMIO register at
    // > 0xFF44) is stubbed to 0x90 permanently.
    cpu.hardwareRegisters[0x44] = 0x90;

    // Run until we reach the start of the program ROM (basically just run the
    // boot ROM):
    while (cpu.pc != 0x0100) {
        // std.debug.print("{}\n", .{cpu});
        cpu.step();
    }
    var line_number: u64 = 1;

    // Now start comparing our log:
    while (try in_stream.readUntilDelimiterOrEof(&readBuf, '\n')) |expected| {
        const expected_str = try std.fmt.bufPrint(&expectedBuf, "{}: {s}", .{ line_number, expected });
        const actual_str = try std.fmt.bufPrint(&actualBuf, "{}: {s}", .{ line_number, cpu });
        try std.testing.expectEqualStrings(expected_str, actual_str);
        cpu.step();
        line_number += 1;
    }
}

// test "blargg 05-op rp log comparison" {
//     try run();
// }
