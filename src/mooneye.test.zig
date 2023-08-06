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
    console.setBreakpoint(0xFFFF);

    // Skip bootloader
    console.cpu.boot();

    var loops: u64 = 0;
    while (true) {
        _ = console.step();

        // LD B,B is a "breakpoint"
        if (console.bus.read(console.cpu.pc) == 0x40) {
            break;
        }

        loops += 1;
        if (loops > 10_000_000) {
            std.debug.panic("Timeout", .{});
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

// MBC1 ROM-only

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

// MBC1 RAM

test "test-roms/mooneye-test-suite/emulator-only/mbc1/ram_256kb.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc1/ram_256kb.gb");
}

test "test-roms/mooneye-test-suite/emulator-only/mbc1/ram_64kb.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc1/ram_64kb.gb");
}

// MBC1 Bits (flags & such?)

test "test-roms/mooneye-test-suite/emulator-only/mbc1/bits_bank1.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc1/bits_bank1.gb");
}

test "test-roms/mooneye-test-suite/emulator-only/mbc1/bits_bank2.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc1/bits_bank2.gb");
}

test "test-roms/mooneye-test-suite/emulator-only/mbc1/bits_mode.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc1/bits_mode.gb");
}

test "test-roms/mooneye-test-suite/emulator-only/mbc1/bits_ramg.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc1/bits_ramg.gb");
}

// ACCEPTANCE

// test "test-roms/mooneye-test-suite/acceptance/add_sp_e_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/add_sp_e_timing.gb");
// }

// DMG-0 model only
// test "test-roms/mooneye-test-suite/acceptance/boot_div-dmg0.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_div-dmg0.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/boot_hwio-dmg0.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_hwio-dmg0.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/boot_regs-dmg0.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_regs-dmg0.gb");
// }

// SGB/SGB2 only
// test "test-roms/mooneye-test-suite/acceptance/boot_div-S.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_div-S.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/boot_div2-S.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_div2-S.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/boot_hwio-S.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_hwio-S.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/boot_regs-sgb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_regs-sgb.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/boot_regs-sgb2.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_regs-sgb2.gb");
// }

// MGB only
// test "test-roms/mooneye-test-suite/acceptance/boot_regs-mgb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_regs-mgb.gb");
// }

// test "test-roms/mooneye-test-suite/acceptance/boot_div-dmgABCmgb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_div-dmgABCmgb.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/boot_hwio-dmgABCmgb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_hwio-dmgABCmgb.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/boot_regs-dmgABC.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_regs-dmgABC.gb");
// }

// EI/DI/IF (interrupt flags & friends)
test "test-roms/mooneye-test-suite/acceptance/if_ie_registers.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/if_ie_registers.gb");
}
// test "test-roms/mooneye-test-suite/acceptance/rapid_di_ei.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/rapid_di_ei.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/ei_sequence.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ei_sequence.gb");
// }
test "test-roms/mooneye-test-suite/acceptance/ei_timing.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ei_timing.gb");
}
test "test-roms/mooneye-test-suite/acceptance/halt_ime0_ei.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/halt_ime0_ei.gb");
}

// Other timing related stuff:

// test "test-roms/mooneye-test-suite/acceptance/call_cc_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/call_cc_timing.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/call_cc_timing2.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/call_cc_timing2.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/call_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/call_timing.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/call_timing2.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/call_timing2.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/di_timing-GS.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/di_timing-GS.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/div_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/div_timing.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/halt_ime0_nointr_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/halt_ime0_nointr_timing.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/halt_ime1_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/halt_ime1_timing.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/halt_ime1_timing2-GS.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/halt_ime1_timing2-GS.gb");
// }

// test "test-roms/mooneye-test-suite/acceptance/intr_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/intr_timing.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/jp_cc_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/jp_cc_timing.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/jp_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/jp_timing.gb");
// }
test "test-roms/mooneye-test-suite/acceptance/ld_hl_sp_e_timing.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ld_hl_sp_e_timing.gb");
}

// test "test-roms/mooneye-test-suite/acceptance/pop_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/pop_timing.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/push_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/push_timing.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/ret_cc_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ret_cc_timing.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/ret_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ret_timing.gb");
// }
test "test-roms/mooneye-test-suite/acceptance/reti_intr_timing.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/reti_intr_timing.gb");
}
// test "test-roms/mooneye-test-suite/acceptance/reti_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/reti_timing.gb");
// }
// test "test-roms/mooneye-test-suite/acceptance/rst_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/rst_timing.gb");
// }

// DMA
test "test-roms/mooneye-test-suite/acceptance/oam_dma/basic.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/oam_dma/basic.gb");
}
test "test-roms/mooneye-test-suite/acceptance/oam_dma/reg_read.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/oam_dma/reg_read.gb");
}
// TODO: Needs MBC5
// test "test-roms/mooneye-test-suite/acceptance/oam_dma/sources-GS.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/oam_dma/sources-GS.gb");
// }
test "test-roms/mooneye-test-suite/acceptance/oam_dma_restart.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/oam_dma_restart.gb");
}
// ALMOST passes:
// test "test-roms/mooneye-test-suite/acceptance/oam_dma_start.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/oam_dma_start.gb");
// }
test "test-roms/mooneye-test-suite/acceptance/oam_dma_timing.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/oam_dma_timing.gb");
}
