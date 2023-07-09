// build with `zig build-exe main.zig -lc -lraylib`

// This is a Zig version of a raylib example from
// https://github.com/raysan5/raylib/
// It is distributed under the same license as the original - unmodified zlib/libpng license
// Header from the original source code follows below:

///*******************************************************************************************
//*
//*   raylib [core] example - Basic window
//*
//*   Welcome to raylib!
//*
//*   To test examples, just press F6 and execute raylib_compile_execute script
//*   Note that compiled executable is placed in the same folder as .c file
//*
//*   You can find all basic examples on C:\raylib\raylib\examples folder or
//*   raylib official webpage: www.raylib.com
//*
//*   Enjoy using raylib. :)
//*
//*   Example originally created with raylib 1.0, last time updated with raylib 1.0
//*
//*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
//*   BSD-like license that allows static linking with closed source software
//*
//*   Copyright (c) 2013-2023 Ramon Santamaria (@raysan5)
//*
//********************************************************************************************/

const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const Console = @import("./console.zig").Console;

const DebugView = enum(u8) {
    None,
    TileData,
    TileMaps,
};

const COLORS = [4]ray.Color{
    ray.Color{
        .r = 0xFF,
        .g = 0x00,
        .b = 0xFF,
        .a = 0x11,
    },
    ray.Color{
        .r = 0xDD,
        .g = 0xDD,
        .b = 0xDD,
        .a = 0xFF,
    },
    ray.Color{
        .r = 0x00,
        .g = 0x00,
        .b = 0x00,
        .a = 0xFF,
    },
    ray.Color{
        .r = 0x00,
        .g = 0x00,
        .b = 0x00,
        .a = 0xFF,
    },
};

const DEBUG_VIEWS = [_]DebugView{
    .TileMaps,
    .TileData,
    .None,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() == .ok);

    var console = try Console.init("./cpu_instrs.gb", allocator);
    defer console.deinit();

    // Double width; main screen on left hand side, debugging info on right hand side:
    const scale = 4;
    const screen_width = 160 * scale * 2;
    const screen_height = 144 * scale;

    ray.InitWindow(screen_width, screen_height, "BoyZ II Game");
    defer ray.CloseWindow(); // Close window and OpenGL context

    ray.SetTargetFPS(60); // Set our game to run at 60 frames-per-second

    const lcd_image = ray.Image{
        .data = &console.lcd.pixels[0],
        .width = 160,
        .height = 144,
        .format = ray.PIXELFORMAT_UNCOMPRESSED_R8G8B8A8,
        .mipmaps = 1,
    };
    const lcd_texture = ray.LoadTextureFromImage(lcd_image);
    defer ray.UnloadTexture(lcd_texture);
    ray.SetTextureFilter(lcd_texture, ray.TEXTURE_FILTER_POINT);

    //
    // Tile Data texture
    //
    const tile_data_image_buf = try allocator.alloc(u32, 8 * 16 * 8 * 16);
    var tile_data_image = ray.Image{
        .data = &tile_data_image_buf[0],
        .width = 8 * 16, // 16 tiles wide
        .height = 8 * 16, // 16 tiles tall
        .format = ray.PIXELFORMAT_UNCOMPRESSED_R8G8B8A8,
        .mipmaps = 1,
    };
    defer allocator.free(tile_data_image_buf);
    const tile_data_texture = ray.LoadTextureFromImage(tile_data_image);
    defer ray.UnloadTexture(tile_data_texture);
    ray.SetTextureFilter(tile_data_texture, ray.TEXTURE_FILTER_POINT);

    //
    // Tile Map texture
    //
    const tile_map_image_buf = try allocator.alloc(u32, 8 * 32 * 8 * 64);
    var tile_map_image = ray.Image{
        .data = &tile_map_image_buf[0],
        .width = 8 * 32, // 32 tiles wide
        .height = 8 * 64, // 64 tiles tall
        .format = ray.PIXELFORMAT_UNCOMPRESSED_R8G8B8A8,
        .mipmaps = 1,
    };
    defer allocator.free(tile_map_image_buf);
    const tile_map_texture = ray.LoadTextureFromImage(tile_map_image);
    defer ray.UnloadTexture(tile_map_texture);
    ray.SetTextureFilter(tile_map_texture, ray.TEXTURE_FILTER_POINT);

    var debug_view_index: u8 = 0;

    while (!ray.WindowShouldClose()) // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (!ray.IsKeyDown(ray.KEY_SPACE)) {
            console.frame();
        } else {
            var i: u8 = 0;
            while (i < 128) : (i += 1) {
                console.frame();
            }
        }

        // std.debug.print("{}\n", .{console.cpu});
        if (ray.IsKeyPressed(ray.KEY_TAB)) {
            debug_view_index +%= 1;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        ray.UpdateTexture(lcd_texture, lcd_image.data);

        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(ray.RAYWHITE);

        // Draw the texture full screen.
        // For this, we use the screen dimensions, and use them as the destination rectangle for the texture.
        ray.DrawTextureEx(lcd_texture, ray.Vector2{ .x = 0.0, .y = 0.0 }, 0.0, @intToFloat(f32, scale), ray.WHITE);

        switch (DEBUG_VIEWS[debug_view_index % DEBUG_VIEWS.len]) {
            .TileData => {
                var tile_num: usize = 0;
                // FIXME: Hard-coding number of tiles in VRAM for now
                while (tile_num < 384) : (tile_num += 1) {
                    // Each tile occupies 16 bytes, where each line is represented by 2 bytes:
                    //
                    // ```
                    // Byte 0-1  Topmost Line (Top 8 pixels)
                    // Byte 2-3  Second Line
                    // etc.
                    // ```

                    // For each line, the first byte specifies the least
                    // significant bit of the color ID of each pixel, and the
                    // second byte specifies the most significant bit. In both
                    // bytes, bit 7 represents the leftmost pixel, and bit 0 the
                    // rightmost.
                    var line: usize = 0;
                    while (line < 8) : (line += 1) {
                        const lsb = console.ppu.vram[tile_num * 16 + line * 2];
                        const msb = console.ppu.vram[tile_num * 16 + line * 2 + 1];
                        const y = 8 * (tile_num / 20) + line;
                        const x = 8 * (tile_num % 20);
                        ray.ImageDrawPixel(&tile_data_image, @intCast(c_int, x + 7), @intCast(c_int, y), COLORS[((msb << 1) & 2) | (lsb & (1 >> 0) & 1)]);
                        ray.ImageDrawPixel(&tile_data_image, @intCast(c_int, x + 6), @intCast(c_int, y), COLORS[((msb >> 0) & 2) | (lsb & (1 >> 1) & 1)]);
                        ray.ImageDrawPixel(&tile_data_image, @intCast(c_int, x + 5), @intCast(c_int, y), COLORS[((msb >> 1) & 2) | (lsb & (1 >> 2) & 1)]);
                        ray.ImageDrawPixel(&tile_data_image, @intCast(c_int, x + 4), @intCast(c_int, y), COLORS[((msb >> 2) & 2) | (lsb & (1 >> 3) & 1)]);
                        ray.ImageDrawPixel(&tile_data_image, @intCast(c_int, x + 3), @intCast(c_int, y), COLORS[((msb >> 3) & 2) | (lsb & (1 >> 4) & 1)]);
                        ray.ImageDrawPixel(&tile_data_image, @intCast(c_int, x + 2), @intCast(c_int, y), COLORS[((msb >> 4) & 2) | (lsb & (1 >> 5) & 1)]);
                        ray.ImageDrawPixel(&tile_data_image, @intCast(c_int, x + 1), @intCast(c_int, y), COLORS[((msb >> 5) & 2) | (lsb & (1 >> 6) & 1)]);
                        ray.ImageDrawPixel(&tile_data_image, @intCast(c_int, x + 0), @intCast(c_int, y), COLORS[((msb >> 6) & 2) | (lsb & (1 >> 7) & 1)]);
                    }
                }

                ray.UpdateTexture(tile_data_texture, tile_data_image.data);
                ray.DrawText("Tile Data", screen_width / 2 + 16, 16, 20, ray.BLACK);
                const tile_data_texture_scale = (scale / 2);
                const x = screen_width / 2 + (((screen_width / 2) - (8 * 20 * tile_data_texture_scale)) / 2);
                const y = ((screen_height - (8 * 20 * tile_data_texture_scale)) / 2);
                ray.DrawTextureEx(tile_data_texture, ray.Vector2{ .x = x, .y = y }, 0.0, @intToFloat(f32, tile_data_texture_scale), ray.WHITE);
            },
            .TileMaps => {
                var tile_index: usize = 0x9800;
                // FIXME: Hard-coding number of tiles in VRAM for now
                while (tile_index < 0x9FFF) : (tile_index += 1) {
                    var tile_num: u16 = console.ppu.vram[tile_index - 0x8000];
                    // Each tile occupies 16 bytes, where each line is represented by 2 bytes:
                    //
                    // ```
                    // Byte 0-1  Topmost Line (Top 8 pixels)
                    // Byte 2-3  Second Line
                    // etc.
                    // ```

                    // For each line, the first byte specifies the least
                    // significant bit of the color ID of each pixel, and the
                    // second byte specifies the most significant bit. In both
                    // bytes, bit 7 represents the leftmost pixel, and bit 0 the
                    // rightmost.
                    var line: usize = 0;
                    while (line < 8) : (line += 1) {
                        const lsb = console.ppu.vram[tile_num * 16 + line * 2];
                        const msb = console.ppu.vram[tile_num * 16 + line * 2 + 1];
                        const y = 8 * ((tile_index - 0x9800) / 32) + line;
                        const x = 8 * ((tile_index - 0x9800) % 32);
                        ray.ImageDrawPixel(&tile_map_image, @intCast(c_int, x + 7), @intCast(c_int, y), COLORS[((msb << 1) & 2) | (lsb & (1 >> 0) & 1)]);
                        ray.ImageDrawPixel(&tile_map_image, @intCast(c_int, x + 6), @intCast(c_int, y), COLORS[((msb >> 0) & 2) | (lsb & (1 >> 1) & 1)]);
                        ray.ImageDrawPixel(&tile_map_image, @intCast(c_int, x + 5), @intCast(c_int, y), COLORS[((msb >> 1) & 2) | (lsb & (1 >> 2) & 1)]);
                        ray.ImageDrawPixel(&tile_map_image, @intCast(c_int, x + 4), @intCast(c_int, y), COLORS[((msb >> 2) & 2) | (lsb & (1 >> 3) & 1)]);
                        ray.ImageDrawPixel(&tile_map_image, @intCast(c_int, x + 3), @intCast(c_int, y), COLORS[((msb >> 3) & 2) | (lsb & (1 >> 4) & 1)]);
                        ray.ImageDrawPixel(&tile_map_image, @intCast(c_int, x + 2), @intCast(c_int, y), COLORS[((msb >> 4) & 2) | (lsb & (1 >> 5) & 1)]);
                        ray.ImageDrawPixel(&tile_map_image, @intCast(c_int, x + 1), @intCast(c_int, y), COLORS[((msb >> 5) & 2) | (lsb & (1 >> 6) & 1)]);
                        ray.ImageDrawPixel(&tile_map_image, @intCast(c_int, x + 0), @intCast(c_int, y), COLORS[((msb >> 6) & 2) | (lsb & (1 >> 7) & 1)]);
                    }
                }

                ray.UpdateTexture(tile_map_texture, tile_map_image.data);
                ray.DrawText("Tile Maps", screen_width / 2 + 16, 16, 20, ray.BLACK);
                const tile_map_texture_scale = scale / 4;
                const x = screen_width / 2 + (((screen_width / 2) - (8 * 32 * tile_map_texture_scale)) / 2);
                const y = ((screen_height - (8 * 64 * tile_map_texture_scale)) / 2);
                ray.DrawTextureEx(tile_map_texture, ray.Vector2{ .x = x, .y = y }, 0.0, @intToFloat(f32, tile_map_texture_scale), ray.WHITE);
            },
            else => {
                ray.DrawText("BoyZ II Game", screen_width / 2 + 16, 16, 20, ray.LIGHTGRAY);
            },
        }
        //----------------------------------------------------------------------------------
    }
}
