const std = @import("std");

const CPU = @import("./cpu.zig").CPU;
const PPU = @import("./ppu.zig").PPU;
const LCD = @import("./lcd.zig").LCD;
const Bus = @import("./bus.zig").Bus;
const Rom = @import("./rom.zig").Rom;

pub const Console = struct {
    const BreakpointTag = enum {
        addr,
        write,
        none,
    };
    const Breakpoint = union(BreakpointTag) {
        addr: u16,
        write: u16,
        none: bool,
    };

    allocator: std.mem.Allocator,

    rom: Rom,
    bus: Bus,
    cpu: CPU,
    ppu: PPU,
    lcd: LCD,
    breakpoint: Breakpoint = Breakpoint{ .none = true },

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
        self.ppu.bus = &self.bus;

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

    pub fn setBreakpoint(self: *Console, addr: u16) void {
        self.breakpoint = Breakpoint{ .addr = addr };
    }

    pub fn setWatchpoint(self: *Console, addr: u16) void {
        self.breakpoint = Breakpoint{ .write = addr };
        self.bus.watch = addr;
    }

    pub fn step(self: *Console) bool {
        var loops: u64 = 0;
        var stepped = false;
        while (!stepped) {
            _ = self.ppu.cycle();
            stepped = self.cpu.cycle();
            _ = self.lcd.cycle(self.cpu.ticks);
            if (loops > 1000) {
                self.cpu.panic("Excess loops in console.step!", .{});
            }
            loops += 1;
        }

        return self.shouldBreak();
    }

    pub fn frame(self: *Console) bool {
        const cyclesPerFrame = self.cpu.cycleRate / 60;

        var loops: u64 = 0;
        var broke = false;
        var i: usize = 0;
        // HACK; roughly approximate frame
        while (i < cyclesPerFrame) : (i += 1) {
            _ = self.ppu.cycle();
            const stepped = self.cpu.cycle();
            _ = self.lcd.cycle(self.cpu.ticks);

            if (stepped and self.shouldBreak()) {
                broke = true;
                break;
            }
            if (loops > 100_000_000) {
                self.cpu.panic("Excess loops in console.frame!", .{});
            }
            loops += 1;
        }

        return broke;
    }

    pub fn shouldBreak(self: *Console) bool {
        if (self.bus.read(self.cpu.pc) == 0x40) {
            return true;
        }

        switch (self.breakpoint) {
            .addr => |addr| {
                const result = addr == self.cpu.pc;
                if (result) {
                    std.debug.print("shouldBreak!\n", .{});
                }
                return result;
            },
            .write => {
                if (self.bus.watch_hit) {
                    self.bus.watch_hit = false;
                    return true;
                }
                return false;
            },
            .none => return false,
        }
    }
};

// test "init" {
//     var console = try Console.init("./pokemon_blue.gb", std.testing.allocator);
//     defer console.deinit();
//     std.debug.print("{}\n", .{console.cpu});
//     console.cpu.step();
//     std.debug.print("{}\n", .{console.cpu});
// }
