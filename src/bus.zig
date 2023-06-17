//! TODO: Docs

const std = @import("std");
const Rom = @import("./rom.zig").Rom;
const SM83 = @import("./sm83.zig").SM83;

pub const Bus = struct {
    allocator: std.mem.Allocator,
    rom: Rom,
    ram: []u8,
    cpu: *const SM83 = undefined,

    // Temporary read-error sigil; we should probably look into how the bus
    // behaves when attempting to read from addresses that are out of range.
    const TEMP_READ_ERROR_SIGIL: u8 = 0xAA;
    pub fn read(self: *const Bus, addr: u16) u8 {
        // Follow the memory mapping guide here:
        // https://gbdev.io/pandocs/Memory_Map.html
        switch (addr) {
            // From cartridge, usually a fixed bank
            0x0000...0x3FFF => return self.rom.bus_read(addr) catch TEMP_READ_ERROR_SIGIL,
            // From cartridge, switchable bank via mapper (if any)
            0x4000...0x7FFF => return self.rom.bus_read(addr) catch TEMP_READ_ERROR_SIGIL,
            // 4 KiB Work RAM (WRAM)
            0xC000...0xCFFF => return self.ram[addr - 0xC000],
            // 4 KiB Work RAM (WRAM) - In CGB mode, switchable bank 1~7
            0xD000...0xDFFF => return self.ram[addr - 0xC000],
            // Hardware registers
            0xFF00...0xFFFF => return self.cpu.read_hw_register(@truncate(u8, addr & 0x00FF)),
            // TODO: Follow the rest from the guide
            else => return TEMP_READ_ERROR_SIGIL,
        }
    }

    pub fn read_16(self: *const Bus, addr: u16) u16 {
        const lo: u16 = self.read(addr);
        const hi: u16 = self.read(addr + 1);
        return (hi << 8) | lo;
    }

    pub fn write(self: *Bus, addr: u16, data: u8) void {
        // Follow the memory mapping guide here:
        // https://gbdev.io/pandocs/Memory_Map.html
        switch (addr) {
            // From cartridge, usually a fixed bank
            // 0x0000...0x3FFF => return self.rom.bus_read(addr) catch TEMP_READ_ERROR_SIGIL,
            // // From cartridge, switchable bank via mapper (if any)
            // 0x4000...0x7FFF => return self.rom.bus_read(addr) catch TEMP_READ_ERROR_SIGIL,

            // 4 KiB Work RAM (WRAM)
            0xC000...0xCFFF => self.ram[addr - 0xC000] = data,
            // 4 KiB Work RAM (WRAM) - In CGB mode, switchable bank 1~7
            0xD000...0xDFFF => self.ram[addr - 0xC000] = data,
            // TODO: Follow the rest from the guide
            else => {
                // Do nothing
            },
        }
    }

    pub fn write_16(self: *Bus, addr: u16, data: u16) void {
        const lo: u8 = @truncate(u8, data << 8);
        const hi: u8 = @truncate(u8, (data >> 8));
        self.write(addr, lo);
        self.write(addr + 1, hi);
    }

    pub fn init(allocator: std.mem.Allocator, rom: Rom) !Bus {
        return Bus{
            .allocator = allocator,
            .rom = rom,
            .ram = try allocator.alloc(u8, 8 * 1024),
        };
    }

    pub fn deinit(self: *const Bus) void {
        self.allocator.free(self.ram);
    }
};

const expect = std.testing.expect;
test "bus read" {
    const raw_data = try std.testing.allocator.alloc(u8, 3);
    defer std.testing.allocator.free(raw_data);
    raw_data[0x0000] = 0x00;
    raw_data[0x0001] = 0x01;
    raw_data[0x0002] = 0x02;
    const rom = Rom{ ._raw_data = raw_data, .allocator = std.testing.allocator };

    const bus = try Bus.init(std.testing.allocator, rom);
    defer bus.deinit();

    try expect(bus.read(0x0000) == 0x00);
    try expect(bus.read(0x0001) == 0x01);
    try expect(bus.read(0x0002) == 0x02);
}

test "bus read_16" {
    const raw_data = try std.testing.allocator.alloc(u8, 2);
    defer std.testing.allocator.free(raw_data);
    raw_data[0x0000] = 0x34;
    raw_data[0x0001] = 0x12;
    const rom = Rom{ ._raw_data = raw_data, .allocator = std.testing.allocator };

    const bus = try Bus.init(std.testing.allocator, rom);
    defer bus.deinit();
    try expect(bus.read_16(0x0000) == 0x1234);
}
