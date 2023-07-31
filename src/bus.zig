//! TODO: Docs

const std = @import("std");
const Rom = @import("./rom.zig").Rom;
const CPU = @import("./cpu.zig").CPU;
const PPU = @import("./ppu.zig").PPU;

pub const Bus = struct {
    allocator: std.mem.Allocator,
    ram: []u8,
    rom: *Rom = undefined,
    ppu: *PPU = undefined,
    cpu: *CPU = undefined,

    watch: u16 = 0x0000,
    watch_hit: bool = false,

    // Temporary read-error sigil; we should probably look into how the bus
    // behaves when attempting to read from addresses that are out of range.
    const TEMP_READ_ERROR_SIGIL: u8 = 0x42;
    pub fn read(self: *const Bus, addr: u16) u8 {
        // Follow the memory mapping guide here:
        // https://gbdev.io/pandocs/Memory_Map.html
        return switch (addr) {
            // This should probably be controlled by the CPU, but for now this
            // is how we allow the CPU to control whether it's reading from the
            // boot rom or not from the first 256 bytes of address space:
            0x0000...0x00FF => if (self.cpu.boot_rom_enabled())
                self.cpu.boot_rom_read(@truncate(u8, addr))
            else
                self.rom.bus_read(addr),
            // From cartridge, usually a fixed bank
            0x0100...0x3FFF => self.rom.bus_read(addr),
            // From cartridge, switchable bank via mapper (if any)
            0x4000...0x7FFF => self.rom.bus_read(addr),
            // 8 KiB Video RAM (VRAM)
            0x8000...0x9FFF => self.ppu.read(addr),
            // From cartridge, switchable bank if any
            0xA000...0xBFFF => self.rom.bus_read(addr),
            // 4 KiB Work RAM (WRAM)
            0xC000...0xCFFF => self.ram[addr - 0xC000],
            // 4 KiB Work RAM (WRAM) - In CGB mode, switchable bank 1~7
            0xD000...0xDFFF => self.ram[addr - 0xC000],
            // Mirror of C000~DDFF (ECHO RAM)
            0xE000...0xFDFF => self.ram[(addr - 0xC000) % (0xFDFF - 0xE000)],
            // Object attribute memory (OAM)
            0xFE00...0xFE9F => self.ppu.read(addr),
            // DMA hardware register
            0xFF46 => self.ppu.read(addr),
            // Hardware registers/HRAM
            0xFF00...0xFF45, 0xFF47...0xFFFF => self.cpu.read_hw_register(@truncate(u8, addr & 0x00FF)),
            else => TEMP_READ_ERROR_SIGIL,
        };
    }

    pub fn read_16(self: *const Bus, addr: u16) u16 {
        const lo: u16 = self.read(addr);
        const hi: u16 = self.read(addr + 1);
        return (hi << 8) | lo;
    }

    pub fn write(self: *Bus, addr: u16, data: u8) void {
        if (self.watch == addr) {
            self.watch_hit = true;
            // std.debug.print("Watchpoint: [${X:0>4}] = ${X:0>2}\n", .{ addr, data });
        }

        // Follow the memory mapping guide here:
        // https://gbdev.io/pandocs/Memory_Map.html
        switch (addr) {
            // From cartridge, usually a fixed bank
            0x0000...0x3FFF => self.rom.bus_write(addr, data),
            // From cartridge, switchable bank via mapper (if any)
            0x4000...0x7FFF => self.rom.bus_write(addr, data),
            // VRAM
            0x8000...0x9FFF => self.ppu.write(addr, data),
            // From cartridge, switchable bank if any
            0xA000...0xBFFF => self.rom.bus_write(addr, data),
            // 4 KiB Work RAM (WRAM)
            0xC000...0xCFFF => self.ram[addr - 0xC000] = data,
            // 4 KiB Work RAM (WRAM) - In CGB mode, switchable bank 1~7
            0xD000...0xDFFF => self.ram[addr - 0xC000] = data,
            // Mirror of C000~DDFF (ECHO RAM)
            0xE000...0xFDFF => self.ram[(addr - 0xC000) % (0xFDFF - 0xE000)] = data,
            // Object attribute memory (OAM)
            0xFE00...0xFE9F => self.ppu.write(addr, data),
            // DMA hardware register
            0xFF46 => self.ppu.write(addr, data),
            // Hardware registers/HRAM
            0xFF00...0xFF45, 0xFF47...0xFFFF => self.cpu.write_hw_register(@truncate(u8, addr & 0x00FF), data),
            else => {
                // self.cpu.panic("Dunno how to write to ${x:0>4}\n", .{addr});
            },
        }
    }

    pub fn write_16(self: *Bus, addr: u16, data: u16) void {
        const lo: u8 = @truncate(u8, data);
        const hi: u8 = @truncate(u8, (data >> 8));
        self.write(addr, lo);
        self.write(addr +% 1, hi);
    }

    pub fn init(allocator: std.mem.Allocator, rom: *Rom, ppu: *PPU) !Bus {
        var self = Bus{
            .allocator = allocator,
            .rom = rom,
            .ppu = ppu,
            .ram = try allocator.alloc(u8, 8 * 1024),
        };

        var i: usize = 0;
        while (i < 8 * 1024) : (i += 1) {
            self.ram[i] = 0x00;
        }

        return self;
    }

    pub fn init_(allocator: std.mem.Allocator) !Bus {
        var self = Bus{
            .allocator = allocator,
            .ram = try allocator.alloc(u8, 8 * 1024),
        };

        var i: usize = 0;
        while (i < 8 * 1024) : (i += 1) {
            self.ram[i] = 0x00;
        }

        return self;
    }

    pub fn deinit(self: *const Bus) void {
        self.allocator.free(self.ram);
    }
};
