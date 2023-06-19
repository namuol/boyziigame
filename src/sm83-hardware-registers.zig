const HardwareRegister = enum(u8) {
    JOYP = 0x00,
    SB = 0x01,
    SC = 0x02,
    DIV = 0x04,
    TIMA = 0x05,
    TMA = 0x06,
    TAC = 0x07,
    IF = 0x0F,
    NR10 = 0x10,
    NR11 = 0x11,
    NR12 = 0x12,
    NR13 = 0x13,
    NR14 = 0x14,
    NR20 = 0x15,
    NR21 = 0x16,
    NR22 = 0x17,
    NR23 = 0x18,
    NR24 = 0x19,
    NR30 = 0x1A,
    NR31 = 0x1B,
    NR32 = 0x1C,
    NR33 = 0x1D,
    NR34 = 0x1E,
    NR40 = 0x1F,
    NR41 = 0x20,
    NR42 = 0x21,
    NR43 = 0x22,
    NR44 = 0x23,
    NR50 = 0x24,
    NR51 = 0x25,
    NR52 = 0x26,
    WAVE = 0x30,
    LCDC = 0x40,
    STAT = 0x41,
    SCY = 0x42,
    SCX = 0x43,
    LY = 0x44,
    LYC = 0x45,
    DMA = 0x46,
    BGP = 0x47,
    OBP0 = 0x48,
    OBP1 = 0x49,
    WY = 0x4A,
    WX = 0x4B,
    KEY1 = 0x4D,
    VBK = 0x4F,
    HDMA1 = 0x51,
    HDMA2 = 0x52,
    HDMA3 = 0x53,
    HDMA4 = 0x54,
    HDMA5 = 0x55,
    RP = 0x56,
    BGPI = 0x68,
    BGPD = 0x69,
    OBPI = 0x6A,
    OBPD = 0x6B,
    UNKNOWN1 = 0x6C,
    SVBK = 0x70,
    UNKNOWN2 = 0x72,
    UNKNOWN3 = 0x73,
    UNKNOWN4 = 0x74,
    UNKNOWN5 = 0x75,
    PCM12 = 0x76,
    PCM34 = 0x77,
    IE = 0xFF,
    _,
};

/// Given a u16 address, return an ASM constant string.
///
/// If not a documented hardware register, returns an empty string.
///
/// Adapted from https://zoomten.github.io/PongBoy/_book/hwconst.html since it
/// appears that SameBoy (a reference emulator used to aid implementation of this
/// one) uses these mnemonics in their Disassembly output and we want to match
/// it exactly to easily test accuracy.
pub fn hardware_register_string(reg: u8) []const u8 {
    return switch (reg) {
        0x00 => "rJOYP", // Joypad (R/W)
        0x01 => "rSB", // Serial transfer data (R/W)
        0x02 => "rSC", // Serial Transfer Control (R/W)
        0x04 => "rDIV", // Divider Register (R/W)
        0x05 => "rTIMA", // Timer counter (R/W)
        0x06 => "rTMA", // Timer Modulo (R/W)
        0x07 => "rTAC", // Timer Control (R/W)
        0x0F => "rIF", // Interrupt Flag (R/W)
        0x10 => "rNR10", // Channel 1 Sweep register (R/W)
        0x11 => "rNR11", // Channel 1 Sound length/Wave pattern duty (R/W)
        0x12 => "rNR12", // Channel 1 Volume Envelope (R/W)
        0x13 => "rNR13", // Channel 1 Frequency lo (Write Only)
        0x14 => "rNR14", // Channel 1 Frequency hi (R/W)
        0x15 => "rNR20", // Channel 2 Sweep register (R/W)
        0x16 => "rNR21", // Channel 2 Sound Length/Wave Pattern Duty (R/W)
        0x17 => "rNR22", // Channel 2 Volume Envelope (R/W)
        0x18 => "rNR23", // Channel 2 Frequency lo data (W)
        0x19 => "rNR24", // Channel 2 Frequency hi data (R/W)
        0x1A => "rNR30", // Channel 3 Sound on/off (R/W)
        0x1B => "rNR31", // Channel 3 Sound Length
        0x1C => "rNR32", // Channel 3 Select output level (R/W)
        0x1D => "rNR33", // Channel 3 Frequency's lower data (W)
        0x1E => "rNR34", // Channel 3 Frequency's higher data (R/W)
        0x1F => "rNR40", // Channel 4 Sweep register (R/W)
        0x20 => "rNR41", // Channel 4 Sound Length (R/W)
        0x21 => "rNR42", // Channel 4 Volume Envelope (R/W)
        0x22 => "rNR43", // Channel 4 Polynomial Counter (R/W)
        0x23 => "rNR44", // Channel 4 Counter/consecutive; Inital (R/W)
        0x24 => "rNR50", // Channel control / ON-OFF / Volume (R/W)
        0x25 => "rNR51", // Selection of Sound output terminal (R/W)
        0x26 => "rNR52", // Sound on/off
        0x30 => "rWAVE", // Wavetable register (W)
        0x40 => "rLCDC", // LCD Control (R/W)
        0x41 => "rSTAT", // LCDC Status (R/W)
        0x42 => "rSCY", // Scroll Y (R/W)
        0x43 => "rSCX", // Scroll X (R/W)
        0x44 => "rLY", // LCDC Y-Coordinate (R)
        0x45 => "rLYC", // LY Compare (R/W)
        0x46 => "rDMA", // DMA Transfer and Start Address (W)
        0x47 => "rBGP", // BG Palette Data (R/W) - Non CGB Mode Only
        0x48 => "rOBP0", // Object Palette 0 Data (R/W) - Non CGB Mode Only
        0x49 => "rOBP1", // Object Palette 1 Data (R/W) - Non CGB Mode Only
        0x4A => "rWY", // Window Y Position (R/W)
        0x4B => "rWX", // Window X Position minus 7 (R/W)
        0x4D => "rKEY1", // CGB Mode Only - Prepare Speed Switch
        0x4F => "rVBK", // CGB Mode Only - VRAM Bank
        0x51 => "rHDMA1", // CGB Mode Only - New DMA Source, High
        0x52 => "rHDMA2", // CGB Mode Only - New DMA Source, Low
        0x53 => "rHDMA3", // CGB Mode Only - New DMA Destination, High
        0x54 => "rHDMA4", // CGB Mode Only - New DMA Destination, Low
        0x55 => "rHDMA5", // CGB Mode Only - New DMA Length/Mode/Start
        0x56 => "rRP", // CGB Mode Only - Infrared Communications Port
        0x68 => "rBGPI", // CGB Mode Only - Background Palette Index
        0x69 => "rBGPD", // CGB Mode Only - Background Palette Data
        0x6A => "rOBPI", // CGB Mode Only - Sprite Palette Index
        0x6B => "rOBPD", // CGB Mode Only - Sprite Palette Data
        0x6C => "rUNKNOWN1", // (FEh) Bit 0 (Read/Write) - CGB Mode Only
        0x70 => "rSVBK", // CGB Mode Only - WRAM Bank
        0x72 => "rUNKNOWN2", // (00h) - Bit 0-7 (Read/Write)
        0x73 => "rUNKNOWN3", // (00h) - Bit 0-7 (Read/Write)
        0x74 => "rUNKNOWN4", // (00h) - Bit 0-7 (Read/Write) - CGB Mode Only
        0x75 => "rUNKNOWN5", // (8Fh) - Bit 4-6 (Read/Write)

        // SameBoy and other rom disassemblies say these registers contain
        // current amplitude data for PCM channels.
        //
        // May not get around to emulating these but for compatibility with
        // SameBoy output I track them here.
        //
        // See https://github.com/LIJI32/GBVisualizer for details
        0x76 => "rPCM12",
        0x77 => "rPCM34",
        // TODO: Fill the rest of these in at comptime?
        0xFC => "rPCM34+$085",
        0xFD => "rPCM34+$085",
        0xFE => "rPCM34+$087",

        0xFF => "rIE", // Interrupt Enable (R/W)
        else => "",
    };
}

/// https://gbdev.io/pandocs/Power_Up_Sequence.html#hardware-registers
pub fn simulate_dmg_boot(r: *[256]u8) void {
    // JOYP
    r[0x00] = 0xCF;
    // SB
    r[0x01] = 0x00;
    // SC
    r[0x02] = 0x7E;
    // DIV
    r[0x04] = 0xAB;
    // TIMA
    r[0x05] = 0x00;
    // TMA
    r[0x06] = 0x00;
    // TAC
    r[0x07] = 0xF8;
    // IF
    r[0x0F] = 0xE1;
    // NR10
    r[0x10] = 0x80;
    // NR11
    r[0x11] = 0xBF;
    // NR12
    r[0x12] = 0xF3;
    // NR13
    r[0x13] = 0xFF;
    // NR14
    r[0x14] = 0xBF;
    // NR21
    r[0x16] = 0x3F;
    // NR22
    r[0x17] = 0x00;
    // NR23
    r[0x18] = 0xFF;
    // NR24
    r[0x19] = 0xBF;
    // NR30
    r[0x1A] = 0x7F;
    // NR31
    r[0x1B] = 0xFF;
    // NR32
    r[0x1C] = 0x9F;
    // NR33
    r[0x1D] = 0xFF;
    // NR34
    r[0x1E] = 0xBF;
    // NR41
    r[0x20] = 0xFF;
    // NR42
    r[0x21] = 0x00;
    // NR43
    r[0x22] = 0x00;
    // NR44
    r[0x23] = 0xBF;
    // NR50
    r[0x24] = 0x77;
    // NR51
    r[0x25] = 0xF3;
    // NR52
    r[0x26] = 0xF1;
    // LCDC
    r[0x40] = 0x91;
    // STAT
    r[0x41] = 0x85;
    // SCY
    r[0x42] = 0x00;
    // SCX
    r[0x43] = 0x00;
    // LY
    r[0x44] = 0x00;
    // LYC
    r[0x45] = 0x00;
    // DMA
    r[0x46] = 0xFF;
    // BGP
    r[0x47] = 0xFC;

    // OBP0
    // r[0x48] = ??;
    // OBP1
    // r[0x49] = ??;

    // WY
    r[0x4A] = 0x00;
    // WX
    r[0x4B] = 0x00;
    // KEY1
    r[0x4D] = 0xFF;
    // VBK
    r[0x4F] = 0xFF;
    // HDMA1
    r[0x51] = 0xFF;
    // HDMA2
    r[0x52] = 0xFF;
    // HDMA3
    r[0x53] = 0xFF;
    // HDMA4
    r[0x54] = 0xFF;
    // HDMA5
    r[0x55] = 0xFF;
    // RP
    r[0x56] = 0xFF;
    // BCPS
    r[0x68] = 0xFF;
    // BCPD
    r[0x69] = 0xFF;
    // OCPS
    r[0x6A] = 0xFF;
    // OCPD
    r[0x6B] = 0xFF;
    // SVBK
    r[0x70] = 0xFF;
    // IE
    r[0xFF] = 0x00;

    // Compatibility stuff with SameBoy boot rom?

    // HACK: $FF50 is used to tell the CPU to read from cartridge ROM instead of boot ROM
    r[0x50] = 0x01;

    // HACK: Initialize rLCD to 0x80; LCD & PPU enabled, all other flags unset
    r[0x40] = 0x80;

    // HACK: Initialize rLY to 0x91 (145), first vblank row of pixels.
    r[0x44] = 0x91;
}
