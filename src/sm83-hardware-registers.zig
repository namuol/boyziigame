/// Given a u16 address, return an ASM constant string.
///
/// If not a documented hardware register, returns an empty string.
///
/// Adapted from https://zoomten.github.io/PongBoy/_book/hwconst.html since it
/// appears that SameBoy (a reference emulator used to aid implementation of this
/// one) uses these mnemonics in their Disassembly output and we want to match
/// it exactly to easily test accuracy.
pub fn hardware_register_string(addr: u16) []const u8 {
    return switch (addr) {
        0xFF00 => "rJOYP", // Joypad (R/W)
        0xFF01 => "rSB", // Serial transfer data (R/W)
        0xFF02 => "rSC", // Serial Transfer Control (R/W)
        0xFF04 => "rDIV", // Divider Register (R/W)
        0xFF05 => "rTIMA", // Timer counter (R/W)
        0xFF06 => "rTMA", // Timer Modulo (R/W)
        0xFF07 => "rTAC", // Timer Control (R/W)
        0xFF0F => "rIF", // Interrupt Flag (R/W)
        0xFF10 => "rNR10", // Channel 1 Sweep register (R/W)
        0xFF11 => "rNR11", // Channel 1 Sound length/Wave pattern duty (R/W)
        0xFF12 => "rNR12", // Channel 1 Volume Envelope (R/W)
        0xFF13 => "rNR13", // Channel 1 Frequency lo (Write Only)
        0xFF14 => "rNR14", // Channel 1 Frequency hi (R/W)
        0xFF15 => "rNR20", // Channel 2 Sweep register (R/W)
        0xFF16 => "rNR21", // Channel 2 Sound Length/Wave Pattern Duty (R/W)
        0xFF17 => "rNR22", // Channel 2 Volume Envelope (R/W)
        0xFF18 => "rNR23", // Channel 2 Frequency lo data (W)
        0xFF19 => "rNR24", // Channel 2 Frequency hi data (R/W)
        0xFF1A => "rNR30", // Channel 3 Sound on/off (R/W)
        0xFF1B => "rNR31", // Channel 3 Sound Length
        0xFF1C => "rNR32", // Channel 3 Select output level (R/W)
        0xFF1D => "rNR33", // Channel 3 Frequency's lower data (W)
        0xFF1E => "rNR34", // Channel 3 Frequency's higher data (R/W)
        0xFF1F => "rNR40", // Channel 4 Sweep register (R/W)
        0xFF20 => "rNR41", // Channel 4 Sound Length (R/W)
        0xFF21 => "rNR42", // Channel 4 Volume Envelope (R/W)
        0xFF22 => "rNR43", // Channel 4 Polynomial Counter (R/W)
        0xFF23 => "rNR44", // Channel 4 Counter/consecutive; Inital (R/W)
        0xFF24 => "rNR50", // Channel control / ON-OFF / Volume (R/W)
        0xFF25 => "rNR51", // Selection of Sound output terminal (R/W)
        0xFF26 => "rNR52", // Sound on/off
        0xFF30 => "rWAVE", // Wavetable register (W)
        0xFF40 => "rLCDC", // LCD Control (R/W)
        0xFF41 => "rSTAT", // LCDC Status (R/W)
        0xFF42 => "rSCY", // Scroll Y (R/W)
        0xFF43 => "rSCX", // Scroll X (R/W)
        0xFF44 => "rLY", // LCDC Y-Coordinate (R)
        0xFF45 => "rLYC", // LY Compare (R/W)
        0xFF46 => "rDMA", // DMA Transfer and Start Address (W)
        0xFF47 => "rBGP", // BG Palette Data (R/W) - Non CGB Mode Only
        0xFF48 => "rOBP0", // Object Palette 0 Data (R/W) - Non CGB Mode Only
        0xFF49 => "rOBP1", // Object Palette 1 Data (R/W) - Non CGB Mode Only
        0xFF4A => "rWY", // Window Y Position (R/W)
        0xFF4B => "rWX", // Window X Position minus 7 (R/W)
        0xFF4D => "rKEY1", // CGB Mode Only - Prepare Speed Switch
        0xFF4F => "rVBK", // CGB Mode Only - VRAM Bank
        0xFF51 => "rHDMA1", // CGB Mode Only - New DMA Source, High
        0xFF52 => "rHDMA2", // CGB Mode Only - New DMA Source, Low
        0xFF53 => "rHDMA3", // CGB Mode Only - New DMA Destination, High
        0xFF54 => "rHDMA4", // CGB Mode Only - New DMA Destination, Low
        0xFF55 => "rHDMA5", // CGB Mode Only - New DMA Length/Mode/Start
        0xFF56 => "rRP", // CGB Mode Only - Infrared Communications Port
        0xFF68 => "rBGPI", // CGB Mode Only - Background Palette Index
        0xFF69 => "rBGPD", // CGB Mode Only - Background Palette Data
        0xFF6A => "rOBPI", // CGB Mode Only - Sprite Palette Index
        0xFF6B => "rOBPD", // CGB Mode Only - Sprite Palette Data
        0xFF6C => "rUNKNOWN1", // (FEh) Bit 0 (Read/Write) - CGB Mode Only
        0xFF70 => "rSVBK", // CGB Mode Only - WRAM Bank
        0xFF72 => "rUNKNOWN2", // (00h) - Bit 0-7 (Read/Write)
        0xFF73 => "rUNKNOWN3", // (00h) - Bit 0-7 (Read/Write)
        0xFF74 => "rUNKNOWN4", // (00h) - Bit 0-7 (Read/Write) - CGB Mode Only
        0xFF75 => "rUNKNOWN5", // (8Fh) - Bit 4-6 (Read/Write)

        // SameBoy and other rom disassemblies say these registers contain
        // current amplitude data for PCM channels.
        //
        // May not get around to emulating these but for compatibility with
        // SameBoy output I track them here.
        //
        // See https://github.com/LIJI32/GBVisualizer for details
        0xFF76 => "rPCM12",
        0xFF77 => "rPCM34",
        // TODO: Fill the rest of these in at comptime?
        0xFFFC => "rPCM34+$085",
        0xFFFD => "rPCM34+$085",
        0xFFFE => "rPCM34+$087",

        0xFFFF => "rIE", // Interrupt Enable (R/W)
        else => "",
    };
}

/// https://gbdev.io/pandocs/Power_Up_Sequence.html#hardware-registers
pub fn dmg_reset(r: *[256]u8) void {
    // P1
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
}
