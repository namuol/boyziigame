const std = @import("std");
const LCD = @import("./lcd.zig").LCD;

pub const PixelFIFO = struct {
    // Each pixel in the FIFO has four properties:
    //
    // - Color: a value between 0 and 3
    // - Palette: on CGB a value between 0 and 7 and on DMG this only applies to
    //   objects
    // - Sprite Priority: on CGB this is the OAM index for the object and on DMG
    //   this doesn’t exist
    // - Background Priority: holds the value of the OBJ-to-BG Priority bit
    const SpritePixel = struct {
        color: u2,
        sprite_palette: u3,
        bg_priority: u1,
    };

    start: u4 = 0,
    len: u8 = 0,

    // A simple array of 2-bit pixel color values.
    //
    // TODO: Generalize this for CGB
    pixels: [16]u2 = [_]u2{0} ** 16,

    // Put a new pixel onto the end of the FIFO.
    //
    // Panics if no space is left on the FIFO.
    pub fn enqueue(self: *PixelFIFO, pixel: u2) void {
        if (self.len == 16) {
            @panic("Cannot enqueue; pixel FIFO is full");
        }

        self.pixels[self.start +% self.len] = pixel;
        self.len += 1;
    }

    // Take the first item off the start of the FIFO.
    //
    // Panics if the FIFO is empty.
    pub fn dequeue(self: *PixelFIFO) u2 {
        if (self.len == 0) {
            @panic("Cannot dequeue; pixel FIFO is empty");
        }

        const pixel = self.pixels[self.start];
        self.start +%= 1;
        self.len -= 1;
        return pixel;
    }
};

const expectEqual = std.testing.expectEqual;
test "enqueue/dequeue" {
    var fifo = PixelFIFO{};

    try expectEqual(fifo.len, 0);

    var i: u8 = 0;
    while (i < 16) : (i += 1) {
        fifo.enqueue(@truncate(u2, i % 4));
        try expectEqual(fifo.len, i + 1);
    }
    i = 0;
    while (i < 16) : (i += 1) {
        const dequeued = fifo.dequeue();
        try expectEqual(dequeued, @truncate(u2, i % 4));
        try expectEqual(fifo.len, 15 - i);
    }
}

const MODE_OAM_SCAN: u2 = 2;
const MODE_DRAWING: u2 = 3;
const MODE_HBLANK: u2 = 0;
const MODE_VBLANK: u2 = 1;

const LCD_PPU_ENABLE: u8 = 1 << 7;
const WINDOW_TILE_MAP_AREA: u8 = 1 << 6;
const WINDOW_ENABLE: u8 = 1 << 5;
const BG_WINDOW_TILE_DATA_AREA: u8 = 1 << 4;
const BG_TILE_MAP_AREA: u8 = 1 << 3;
const OBJ_SIZE: u8 = 1 << 2;
const OBJ_ENABLE: u8 = 1 << 1;
const BG_AND_WINDOW_ENABLE_PRIORITY: u8 = 1 << 0;

pub const PPU = struct {
    allocator: std.mem.Allocator,

    lcd: *LCD = undefined,

    vram: []u8,
    oam: []u8,

    /// Vertical line currently being drawn (including hidden vblank lines)
    ly: u8 = 0,
    dot: u16 = 0,
    mode: u2 = undefined,

    // LCD control register
    lcdc: u8 = 0,

    // Temporary 8-pixel buffer to hold pixel data fetched by the pixel fetcher
    // while it waits for the fifo to have space for the read data.
    pixel_fetch: [2]u2 = [_]u2{0} ** 2,

    bg_pixel_fifo: PixelFIFO = PixelFIFO{},
    obj_pixel_fifo: PixelFIFO = PixelFIFO{},

    pub fn init(allocator: std.mem.Allocator) !PPU {
        return PPU{
            .allocator = allocator,
            // TODO: CGB needs to have two switchable banks of 8KiB
            .vram = try allocator.alloc(u8, 8 * 1024),
            .oam = try allocator.alloc(u8, 4 * 40),
        };
    }

    pub fn deinit(self: *const PPU) void {
        self.allocator.free(self.vram);
        self.allocator.free(self.oam);
    }

    pub fn cycle(self: *PPU) void {
        if (self.ly > 143) {
            self.mode = MODE_VBLANK;
        } else {
            switch (self.dot) {
                0...79 => {
                    // TODO: OAM SEARCH
                    //
                    // Find all sprites that are visible on the current line and
                    // put them into an array of up to 10 sprites.
                    //
                    // 20 cycles
                    self.mode = MODE_OAM_SCAN;
                },
                80...252 => {
                    self.mode = MODE_DRAWING;
                },
                253...457 => self.mode = MODE_HBLANK,
                else => {},
            }
        }

        self.dot += 1;
        if (self.dot > 457) {
            self.dot = 0;
            self.ly += 1;
            if (self.ly > 153) {
                self.ly = 0;
            }
        }
    }

    pub fn read(self: *const PPU, addr: u16) u8 {
        switch (addr) {
            0x8000...0x9FFF => {
                // Return garbage while drawing to LCD:
                if (self.mode == MODE_DRAWING and (self.lcdc & LCD_PPU_ENABLE) != 0) {
                    return 0xFF;
                }
                return self.vram[addr - 0x8000];
            },
            0xFE00...0xFE9F => {
                // TODO: What do we do here during MODE_OAM_SCAN?
                return self.oam[addr - 0xFE00];
            },
            else => @panic("PPU read from unexpected address range"),
        }
    }

    pub fn write(self: *const PPU, addr: u16, data: u8) void {
        switch (addr) {
            0x8000...0x9FFF => {
                // Ignore writes when drawing to LCD:
                if (self.mode == MODE_DRAWING and (self.lcdc & LCD_PPU_ENABLE) != 0) {
                    return;
                }
                self.vram[addr - 0x8000] = data;
            },
            0xFE00...0xFE9F => {
                // TODO: What do we do here during MODE_OAM_SCAN?
                self.oam[addr - 0xFE00] = data;
            },
            else => @panic("PPU write to unexpected address range"),
        }
    }
};
