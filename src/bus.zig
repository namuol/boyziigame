//! TODO: Docs

const Rom = @import("./rom.zig").Rom;

pub const Bus = struct {
    rom: Rom,

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
            // TODO: Follow the rest from the guide
            else => return TEMP_READ_ERROR_SIGIL,
        }
    }
};

const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
test "rom read" {
    const raw_data = try std.testing.allocator.alloc(u8, 3);
    raw_data[0x0000] = 0x00;
    raw_data[0x0001] = 0x01;
    raw_data[0x0002] = 0x02;
    const rom = Rom{ ._raw_data = raw_data, .allocator = std.testing.allocator };
    defer rom.deinit();

    const bus = Bus{ .rom = rom };
    try expect(bus.read(0x0000) == 0x00);
    try expect(bus.read(0x0001) == 0x01);
    try expect(bus.read(0x0002) == 0x02);
}
