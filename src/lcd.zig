const std = @import("std");

pub const LCD = struct {
    pub const WIDTH: usize = 160;
    pub const HEIGHT: usize = 144;

    allocator: std.mem.Allocator,

    // For now, using 32-bit color (RGBA) and pinning alpha channel to 0xFF
    pixels: []u32,

    pub fn init(allocator: std.mem.Allocator) !LCD {
        const result = LCD{
            .allocator = allocator,
            .pixels = try allocator.alloc(u32, WIDTH * HEIGHT),
        };

        var i: usize = 0;
        while (i < WIDTH * HEIGHT) : (i += 1) {
            result.pixels[i] = 0xFF_00_00_00;
        }

        return result;
    }

    pub fn deinit(self: *const LCD) void {
        self.allocator.free(self.pixels);
    }

    pub fn cycle(_: *const LCD, _: u32) void {
        // self.pixels[ticks % (WIDTH * HEIGHT)] = ticks | 0xFF_00_00_00;
    }
};
