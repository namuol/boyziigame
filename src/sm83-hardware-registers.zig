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
        0xFF76 => "rUNKNOWN6", // (00h) - Always 00h (Read Only)
        0xFF77 => "rUNKNOWN7", // (00h) - Always 00h (Read Only)
        0xFFFF => "rIE", // Interrupt Enable (R/W)
        else => "",
    };
}
