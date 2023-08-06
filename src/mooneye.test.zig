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

test "test-roms/mooneye-test-suite/acceptance/add_sp_e_timing.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/add_sp_e_timing.gb");
}
test "test-roms/mooneye-test-suite/acceptance/bits/mem_oam.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/bits/mem_oam.gb");
}
test "test-roms/mooneye-test-suite/acceptance/bits/reg_f.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/bits/reg_f.gb");
}
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/bits/unused_hwio-GS.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/bits/unused_hwio-GS.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/boot_div-S.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_div-S.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/boot_div-dmg0.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_div-dmg0.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/boot_div-dmgABCmgb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_div-dmgABCmgb.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/boot_div2-S.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_div2-S.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/boot_hwio-S.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_hwio-S.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/boot_hwio-dmg0.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_hwio-dmg0.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/boot_hwio-dmgABCmgb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_hwio-dmgABCmgb.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/boot_regs-dmg0.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_regs-dmg0.gb");
// }
test "test-roms/mooneye-test-suite/acceptance/boot_regs-dmgABC.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_regs-dmgABC.gb");
}
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/boot_regs-mgb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_regs-mgb.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/boot_regs-sgb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_regs-sgb.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/boot_regs-sgb2.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/boot_regs-sgb2.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/call_cc_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/call_cc_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/call_cc_timing2.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/call_cc_timing2.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/call_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/call_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/call_timing2.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/call_timing2.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/di_timing-GS.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/di_timing-GS.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/div_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/div_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/ei_sequence.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ei_sequence.gb");
// }
test "test-roms/mooneye-test-suite/acceptance/ei_timing.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ei_timing.gb");
}
test "test-roms/mooneye-test-suite/acceptance/halt_ime0_ei.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/halt_ime0_ei.gb");
}
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/halt_ime0_nointr_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/halt_ime0_nointr_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/halt_ime1_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/halt_ime1_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/halt_ime1_timing2-GS.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/halt_ime1_timing2-GS.gb");
// }
test "test-roms/mooneye-test-suite/acceptance/if_ie_registers.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/if_ie_registers.gb");
}
test "test-roms/mooneye-test-suite/acceptance/instr/daa.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/instr/daa.gb");
}
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/interrupts/ie_push.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/interrupts/ie_push.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/intr_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/intr_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/jp_cc_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/jp_cc_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/jp_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/jp_timing.gb");
// }
test "test-roms/mooneye-test-suite/acceptance/ld_hl_sp_e_timing.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ld_hl_sp_e_timing.gb");
}
test "test-roms/mooneye-test-suite/acceptance/oam_dma/basic.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/oam_dma/basic.gb");
}
test "test-roms/mooneye-test-suite/acceptance/oam_dma/reg_read.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/oam_dma/reg_read.gb");
}
// test "test-roms/mooneye-test-suite/acceptance/oam_dma/sources-GS.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/oam_dma/sources-GS.gb");
// }
test "test-roms/mooneye-test-suite/acceptance/oam_dma_restart.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/oam_dma_restart.gb");
}
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/oam_dma_start.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/oam_dma_start.gb");
// }
test "test-roms/mooneye-test-suite/acceptance/oam_dma_timing.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/oam_dma_timing.gb");
}
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/pop_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/pop_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/ppu/hblank_ly_scx_timing-GS.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ppu/hblank_ly_scx_timing-GS.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/ppu/intr_1_2_timing-GS.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ppu/intr_1_2_timing-GS.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/ppu/intr_2_0_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ppu/intr_2_0_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/ppu/intr_2_mode0_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ppu/intr_2_mode0_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/ppu/intr_2_mode0_timing_sprites.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ppu/intr_2_mode0_timing_sprites.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/ppu/intr_2_mode3_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ppu/intr_2_mode3_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/ppu/intr_2_oam_ok_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ppu/intr_2_oam_ok_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/ppu/lcdon_timing-GS.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ppu/lcdon_timing-GS.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/ppu/lcdon_write_timing-GS.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ppu/lcdon_write_timing-GS.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/ppu/stat_irq_blocking.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ppu/stat_irq_blocking.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/ppu/stat_lyc_onoff.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ppu/stat_lyc_onoff.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/ppu/vblank_stat_intr-GS.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ppu/vblank_stat_intr-GS.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/push_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/push_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/rapid_di_ei.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/rapid_di_ei.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/ret_cc_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ret_cc_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/ret_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/ret_timing.gb");
// }
test "test-roms/mooneye-test-suite/acceptance/reti_intr_timing.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/reti_intr_timing.gb");
}
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/reti_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/reti_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/rst_timing.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/rst_timing.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/serial/boot_sclk_align-dmgABCmgb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/serial/boot_sclk_align-dmgABCmgb.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/timer/div_write.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/timer/div_write.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/timer/rapid_toggle.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/timer/rapid_toggle.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/timer/tim00.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/timer/tim00.gb");
// }
test "test-roms/mooneye-test-suite/acceptance/timer/tim00_div_trigger.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/timer/tim00_div_trigger.gb");
}
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/timer/tim01.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/timer/tim01.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/timer/tim01_div_trigger.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/timer/tim01_div_trigger.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/timer/tim10.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/timer/tim10.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/timer/tim10_div_trigger.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/timer/tim10_div_trigger.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/timer/tim11.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/timer/tim11.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/timer/tim11_div_trigger.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/timer/tim11_div_trigger.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/timer/tima_reload.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/timer/tima_reload.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/timer/tima_write_reloading.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/timer/tima_write_reloading.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/acceptance/timer/tma_write_reloading.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/acceptance/timer/tma_write_reloading.gb");
// }
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
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/emulator-only/mbc1/multicart_rom_8Mb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc1/multicart_rom_8Mb.gb");
// }
test "test-roms/mooneye-test-suite/emulator-only/mbc1/ram_256kb.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc1/ram_256kb.gb");
}
test "test-roms/mooneye-test-suite/emulator-only/mbc1/ram_64kb.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc1/ram_64kb.gb");
}
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
// --- Need MBC2 support ---
// test "test-roms/mooneye-test-suite/emulator-only/mbc2/bits_ramg.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc2/bits_ramg.gb");
// }
// test "test-roms/mooneye-test-suite/emulator-only/mbc2/bits_romb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc2/bits_romb.gb");
// }
// test "test-roms/mooneye-test-suite/emulator-only/mbc2/bits_unused.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc2/bits_unused.gb");
// }
// test "test-roms/mooneye-test-suite/emulator-only/mbc2/ram.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc2/ram.gb");
// }
// test "test-roms/mooneye-test-suite/emulator-only/mbc2/rom_1Mb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc2/rom_1Mb.gb");
// }
// test "test-roms/mooneye-test-suite/emulator-only/mbc2/rom_2Mb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc2/rom_2Mb.gb");
// }
// test "test-roms/mooneye-test-suite/emulator-only/mbc2/rom_512kb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc2/rom_512kb.gb");
// }
// --- Need MBC5 support ---
// test "test-roms/mooneye-test-suite/emulator-only/mbc5/rom_16Mb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc5/rom_16Mb.gb");
// }
// test "test-roms/mooneye-test-suite/emulator-only/mbc5/rom_1Mb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc5/rom_1Mb.gb");
// }
// test "test-roms/mooneye-test-suite/emulator-only/mbc5/rom_2Mb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc5/rom_2Mb.gb");
// }
// test "test-roms/mooneye-test-suite/emulator-only/mbc5/rom_32Mb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc5/rom_32Mb.gb");
// }
// test "test-roms/mooneye-test-suite/emulator-only/mbc5/rom_4Mb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc5/rom_4Mb.gb");
// }
// test "test-roms/mooneye-test-suite/emulator-only/mbc5/rom_512kb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc5/rom_512kb.gb");
// }
// test "test-roms/mooneye-test-suite/emulator-only/mbc5/rom_64Mb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc5/rom_64Mb.gb");
// }
// test "test-roms/mooneye-test-suite/emulator-only/mbc5/rom_8Mb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/emulator-only/mbc5/rom_8Mb.gb");
// }
// Timeout:
// test "test-roms/mooneye-test-suite/madness/mgb_oam_dma_halt_sprites.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/madness/mgb_oam_dma_halt_sprites.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/manual-only/sprite_priority.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/manual-only/sprite_priority.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/misc/bits/unused_hwio-C.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/misc/bits/unused_hwio-C.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/misc/boot_div-A.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/misc/boot_div-A.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/misc/boot_div-cgb0.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/misc/boot_div-cgb0.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/misc/boot_div-cgbABCDE.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/misc/boot_div-cgbABCDE.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/misc/boot_hwio-C.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/misc/boot_hwio-C.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/misc/boot_regs-A.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/misc/boot_regs-A.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/misc/boot_regs-cgb.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/misc/boot_regs-cgb.gb");
// }
// Fails for unknown reason:
// test "test-roms/mooneye-test-suite/misc/ppu/vblank_stat_intr-C.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/misc/ppu/vblank_stat_intr-C.gb");
// }
// --- Unexpected ROM size value? ---
// test "test-roms/mooneye-test-suite/utils/bootrom_dumper.gb" {
//     try run_mooneye_test("test-roms/mooneye-test-suite/utils/bootrom_dumper.gb");
// }
test "test-roms/mooneye-test-suite/utils/dump_boot_hwio.gb" {
    try run_mooneye_test("test-roms/mooneye-test-suite/utils/dump_boot_hwio.gb");
}
