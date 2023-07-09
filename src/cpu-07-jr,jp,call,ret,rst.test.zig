//! CPU "integration" tests

const std = @import("std");
const expect = std.testing.expect;

// No gods, no kings, only bus
const Bus = @import("./bus.zig").Bus;
const Rom = @import("./rom.zig").Rom;
const PPU = @import("./ppu.zig").PPU;
const CPU = @import("./cpu.zig").CPU;

pub fn run() !void {
    var rom = try Rom.from_file("test-roms/07-jr,jp,call,ret,rst.gb", std.testing.allocator);
    defer rom.deinit();

    var ppu = try PPU.init(std.testing.allocator);
    defer ppu.deinit();

    var bus = try Bus.init(std.testing.allocator, &rom, &ppu);
    defer bus.deinit();

    var cpu = try CPU.init(std.testing.allocator, &bus);
    defer cpu.deinit();
    bus.cpu = &cpu;

    // https://github.com/wheremyfoodat/Gameboy-logs - Blargg7LYStubbed.zip
    const file = try std.fs.cwd().openFile("test-roms/07-jr,jp,call,ret,rst.txt", .{});
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
    ppu.ly = 0x90;

    // Run until we reach the start of the program ROM (basically just run the
    // boot ROM):
    while (cpu.pc != 0x0100) {
        // std.debug.print("{}\n", .{cpu});
        cpu.step();
    }
    var line_number: u64 = 1;

    // Now start comparing our log:
    while (try in_stream.readUntilDelimiterOrEof(&readBuf, '\n')) |expected| {
        // Annoyingly, the logs do not contain any traces when the CPU is in
        // address range $0000-$0100 (inclusive)
        //
        // Since we're testing RST, we are jumping into that address range many
        // times in this test, so we need to let the CPU run while it's in that
        // range before we can resume comparing log output.
        while (cpu.pc < 0x100) {
            cpu.step();
        }
        const expected_str = try std.fmt.bufPrint(&expectedBuf, "{}: {s}", .{ line_number, expected });
        const actual_str = try std.fmt.bufPrint(&actualBuf, "{}: {s}", .{ line_number, cpu });
        try std.testing.expectEqualStrings(expected_str, actual_str);
        line_number += 1;
        cpu.step();
    }
}

// test "blargg 07-jr,jp,call,ret,rst log comparison" {
//     try run();
// }
