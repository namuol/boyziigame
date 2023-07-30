//! CPU "integration" tests

const std = @import("std");
const expect = std.testing.expect;

const Console = @import("./console.zig").Console;

/// Runs a mooneye test suite ROM (from Gekkio)
///
/// These ROMs use a special protocol for validating results which make them
/// easy to run: https://github.com/Gekkio/mooneye-test-suite#passfail-reporting
fn run_mooneye_test(rom_file_path: []const u8) !void {
    var console = try Console.init(rom_file_path, std.testing.allocator);
    defer console.deinit();

    // Skip bootloader
    console.cpu.pc = 0x0100;
    console.cpu.hardwareRegisters[0x50] = 0x01;

    var loops: u64 = 0;
    while (true) {
        _ = console.step();
        if (console.bus.read(console.cpu.pc) == 0x40) {
            break;
        }

        loops += 1;
        if (loops > 1_000_000_000) {
            std.debug.panic("Infinite loop?", .{});
            break;
        }
    }

    // A passing test writes the Fibonacci numbers 3/5/8/13/21/34 to the
    // registers B/C/D/E/H/L:
    if (console.cpu.b == 3 and console.cpu.c == 5 and console.cpu.d == 8 and console.cpu.e == 13 and console.cpu.h == 21 and console.cpu.l == 34) {
        // Test passed!
    } else {
        try expect(false);
    }
}

// MBC1 tests:

test "test-roms/mooneye-test-suite/emulator-only/mbc1/rom_16Mb.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc1/rom_16Mb.gb");
}

test "test-roms/mooneye-test-suite/emulator-only/mbc1/rom_1Mb.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc1/rom_1Mb.gb");
}

test "test-roms/mooneye-test-suite/emulator-only/mbc1/rom_2Mb.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc1/rom_2Mb.gb");
}

test "test-roms/mooneye-test-suite/emulator-only/mbc1/rom_4Mb.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc1/rom_4Mb.gb");
}

test "test-roms/mooneye-test-suite/emulator-only/mbc1/rom_512kb.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc1/rom_512kb.gb");
}

test "test-roms/mooneye-test-suite/emulator-only/mbc1/rom_8Mb.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc1/rom_8Mb.gb");
}
