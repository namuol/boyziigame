const std = @import("std");

const CPU = @import("./cpu.zig").CPU;
const PPU = @import("./ppu.zig").PPU;
const LCD = @import("./lcd.zig").LCD;
const Bus = @import("./bus.zig").Bus;
const Rom = @import("./rom.zig").Rom;

pub const Console = struct {
    allocator: std.mem.Allocator,

    rom: Rom,
    bus: Bus,
    cpu: CPU,
    ppu: PPU,
    lcd: LCD,

    pub fn init(rom_file_path: []const u8, allocator: std.mem.Allocator) !*Console {
        var self = try allocator.create(Console);
        errdefer allocator.destroy(self);

        self.allocator = allocator;

        self.rom = try Rom.from_file(rom_file_path, allocator);
        self.ppu = try PPU.init(allocator);
        self.bus = try Bus.init(allocator, &self.rom, &self.ppu);
        self.cpu = try CPU.init(allocator, &self.bus);
        self.lcd = try LCD.init(allocator);

        self.bus.cpu = &self.cpu;
        self.cpu.bus = &self.bus;
        self.ppu.lcd = &self.lcd;

        return self;
    }

    pub fn deinit(self: *const Console) void {
        self.lcd.deinit();
        self.cpu.deinit();
        self.ppu.deinit();
        self.bus.deinit();
        self.rom.deinit();

        self.allocator.destroy(self);
    }

    pub fn step(self: *Console) void {
        var stepped = false;
        while (!stepped) {
            _ = self.ppu.cycle();
            stepped = self.cpu.cycle();
            _ = self.lcd.cycle(self.cpu.ticks);
        }
    }

    pub fn frame(self: *Console) void {
        const cyclesPerFrame = self.cpu.cycleRate / 60;
        var i: usize = 0;
        // HACK; roughly approximate frame
        while (i < cyclesPerFrame) : (i += 1) {
            _ = self.ppu.cycle();
            _ = self.cpu.cycle();
            _ = self.lcd.cycle(self.cpu.ticks);
        }
    }
};

test "init" {
    var console = try Console.init("./pokemon_blue.gb", std.testing.allocator);
    defer console.deinit();
    std.debug.print("{}\n", .{console.cpu});
    console.cpu.step();
    std.debug.print("{}\n", .{console.cpu});
}
