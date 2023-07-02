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

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() == .ok);

    var console = try Console.init("./pokemon_blue.gb", allocator);
    defer console.deinit();

    // Double width; main screen on left hand side, debugging info on right hand side:
    const scale = 4;
    const screen_width = 160 * scale * 2;
    const screen_height = 144 * scale;

    ray.InitWindow(screen_width, screen_height, "BoyZ II Game");
    defer ray.CloseWindow(); // Close window and OpenGL context

    const image = ray.Image{
        .data = &console.lcd.pixels[0],
        .width = 160,
        .height = 144,
        .format = ray.PIXELFORMAT_UNCOMPRESSED_R8G8B8A8,
        .mipmaps = 1,
    };

    const texture = ray.LoadTextureFromImage(image);
    defer ray.UnloadTexture(texture);

    ray.SetTargetFPS(60); // Set our game to run at 60 frames-per-second

    while (!ray.WindowShouldClose()) // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        console.frame();
        std.debug.print("{}\n", .{console.cpu});
        //----------------------------------------------------------------------------------

        ray.UpdateTexture(texture, image.data);

        // Draw
        //----------------------------------------------------------------------------------
        ray.BeginDrawing();
        defer ray.EndDrawing();

        // Draw the texture full screen.
        // For this, we use the screen dimensions, and use them as the destination rectangle for the texture.
        ray.DrawTextureRec(texture, ray.Rectangle{ .x = 0.0, .y = 0.0, .width = @intToFloat(f32, texture.width * scale), .height = @intToFloat(f32, texture.height * scale) }, ray.Vector2{ .x = 0.0, .y = 0.0 }, ray.WHITE);

        ray.ClearBackground(ray.RAYWHITE);

        ray.DrawText("BoyZ II Game", 690, 20, 20, ray.LIGHTGRAY);
        //----------------------------------------------------------------------------------
    }
}
