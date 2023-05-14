//! GB ROM interface
//!
//! References I've found helpful:
//!
//! - Pan Docs: The Cartridge Header: https://gbdev.io/pandocs/The_Cartridge_Header.html
const std = @import("std");
const print = std.debug.print;

fn checksum_header(comptime T: type, comptime R: type, bytes: []T) R {
    var result: R = 0;
    for (bytes) |byte| {
        result = result -% byte -% 1;
    }
    return result;
}

fn checksum_rom(data: []const u8) u16 {
    var result: u16 = 0;
    var i: usize = 0;
    for (data) |byte| {
        if (i != 0x014E and i != 0x014F) {
            result +%= byte;
        }
        i += 1;
    }
    return result;
}

pub const Rom = struct {
    _raw_data: []u8 = undefined,

    logo: [48]u8 = undefined,
    title: [11]u8 = undefined,
    manufacturer_code: [4]u8 = undefined,
    cgb_flag: CgbFlag = undefined,
    new_licensee_code: [2]u8 = undefined,
    sgb_flag: SgbFlag = undefined,
    cartridge_type: CartridgeType = undefined,
    rom_size: RomSize = undefined,
    ram_size: RamSize = undefined,
    destination_code: DestinationCode = undefined,
    old_licensee_code: u8 = undefined,
    mask_rom_version: u8 = undefined,
    header_checksum: u8 = undefined,
    global_checksum: u16 = undefined,

    allocator: std.mem.Allocator,

    const HEADER_START = 0x100;
    const HEADER_END = 0x150;

    const CgbFlag = enum(u8) {
        CgbEnhancements = 0x80,
        CgbOnly = 0xC0,
        _,
    };

    const SgbFlag = enum(u8) {
        NoSgbFunctions = 0x00,
        SgbFunctions = 0x03,
        _,
    };

    const CartridgeType = enum(u8) {
        ROM_ONLY = 0x00,
        MBC1 = 0x01,
        MBC1_RAM = 0x02,
        MBC1_RAM_BATTERY = 0x03,
        MBC2 = 0x05,
        MBC2_BATTERY = 0x06,
        ROM_RAM = 0x08,
        ROM_RAM_BATTERY = 0x09,
        MMM01 = 0x0B,
        MMM01_RAM = 0x0C,
        MMM01_RAM_BATTERY = 0x0D,
        MBC3_TIMER_BATTERY = 0x0F,
        MBC3_TIMER_RAM_BATTERY = 0x10,
        MBC3 = 0x11,
        MBC3_RAM = 0x12,
        MBC3_RAM_BATTERY = 0x13,
        MBC5 = 0x19,
        MBC5_RAM = 0x1A,
        MBC5_RAM_BATTERY = 0x1B,
        MBC5_RUMBLE = 0x1C,
        MBC5_RUMBLE_RAM = 0x1D,
        MBC5_RUMBLE_RAM_BATTERY = 0x1E,
        MBC6 = 0x20,
        MBC7_SENSOR_RUMBLE_RAM_BATTERY = 0x22,
        POCKET_CAMERA = 0xFC,
        BANDAI_TAMA5 = 0xFD,
        HuC3 = 0xFE,
        HuC1_RAM_BATTERY = 0xFF,
    };

    const RomSize = enum(u8) {
        _32KiB = 0x00,
        _64KiB = 0x01,
        _128KiB = 0x02,
        _256KiB = 0x03,
        _512KiB = 0x04,
        _1MiB = 0x05,
        _2MiB = 0x06,
        _4MiB = 0x07,
        _8MiB = 0x08,
        _16MiB = 0x09,
        _32MiB = 0x0A,
        _,
    };

    const RamSize = enum(u8) {
        NoRam = 0x00,
        _8KiB = 0x02,
        _32KiB = 0x03,
        _128KiB = 0x04,
        _64KiB = 0x05,
        _,
    };

    const DestinationCode = enum(u8) {
        Japanese = 0x00,
        NonJapanese = 0x01,
        _,
    };

    const ReadError = error{
        OutOfRange,
    };

    pub fn format(self: *const Rom, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) std.os.WriteError!void {
        const str = (
            \\ ----------- Header -----------
            \\              logo: {s}
            \\                    {s}
            \\                    {s}
            \\             title: {s}
            \\ manufacturer_code: {s}
            \\          cgb_flag: {X}
            \\ new_licensee_code: {s}
            \\          sgb_flag: {X}
            \\    cartridge_type: {s}
            \\          rom_size: {s}
            \\          ram_size: {X}
            \\  destination_code: {X}
            \\ old_licensee_code: {X}
            \\  mask_rom_version: {X}
            \\   header_checksum: {X}   {s}
            \\   global_checksum: {X} {s}
            \\ ------- END Header -----------
        );

        return writer.print(str, .{
            std.fmt.fmtSliceHexUpper(self.logo[0..16]),
            std.fmt.fmtSliceHexUpper(self.logo[16..32]),
            std.fmt.fmtSliceHexUpper(self.logo[32..]),
            self.title,
            std.fmt.fmtSliceHexUpper(&self.manufacturer_code),
            // I wish `@tagName` worked with
            @enumToInt(self.cgb_flag),
            std.fmt.fmtSliceHexUpper(&self.new_licensee_code),
            @enumToInt(self.sgb_flag),
            @tagName(self.cartridge_type),
            @tagName(self.rom_size),
            @enumToInt(self.ram_size),
            @enumToInt(self.destination_code),
            self.old_licensee_code,
            self.mask_rom_version,
            self.header_checksum,
            if (checksum_header(u8, u8, self._raw_data[0x0134..0x014D]) == self.header_checksum) "✅" else "❌",
            self.global_checksum,
            if (checksum_rom(self._raw_data) == self.global_checksum) "✅" else "❌",
        });
    }

    pub fn from_file(file_path: []const u8, allocator: std.mem.Allocator) !Rom {
        var rom = Rom{ .allocator = allocator };
        const file = try std.fs.cwd().openFile(file_path, .{});
        defer file.close();

        rom._raw_data = try file.readToEndAlloc(allocator, 32 * 1024 * 1024);

        {
            var pos: usize = HEADER_START;
            pos += 4; // We discard the entry point and continue...
            std.mem.copy(u8, &rom.logo, rom._raw_data[pos..(pos + rom.logo.len)]);
            pos += rom.logo.len;
            std.mem.copy(u8, &rom.title, rom._raw_data[pos..(pos + rom.title.len)]);
            pos += rom.title.len;
            std.mem.copy(u8, &rom.manufacturer_code, rom._raw_data[pos..(pos + rom.manufacturer_code.len)]);
            pos += rom.manufacturer_code.len;
            rom.cgb_flag = @intToEnum(CgbFlag, rom._raw_data[pos]);
            pos += 1;
            std.mem.copy(u8, &rom.new_licensee_code, rom._raw_data[pos..(pos + rom.new_licensee_code.len)]);
            pos += rom.new_licensee_code.len;
            rom.sgb_flag = @intToEnum(SgbFlag, rom._raw_data[pos]);
            pos += 1;
            rom.cartridge_type = @intToEnum(CartridgeType, rom._raw_data[pos]);
            pos += 1;
            rom.rom_size = @intToEnum(RomSize, rom._raw_data[pos]);
            pos += 1;
            rom.ram_size = @intToEnum(RamSize, rom._raw_data[pos]);
            pos += 1;
            rom.destination_code = @intToEnum(DestinationCode, rom._raw_data[pos]);
            pos += 1;
            rom.old_licensee_code = rom._raw_data[pos];
            pos += 1;
            rom.mask_rom_version = rom._raw_data[pos];
            pos += 1;
            rom.header_checksum = rom._raw_data[pos];
            pos += 1;
            rom.global_checksum = (@as(u16, rom._raw_data[pos]) << 8) | @as(u16, rom._raw_data[pos + 1]);
        }

        return rom;
    }

    // The way the logo pixels are laid out is hard to describe with words, so
    // I'll draw it instead:
    //
    // ```
    //   ADDR U8 U4         U4 U8 ADDR
    // 0x0104 CE C ##.. .##. 6 66 0x0106
    //           E ###. .##. 6
    // 0x0105 ED E ###. .##. 6 66 0x0107
    //           D ##.# .##. 6
    // ```
    //
    //
    // The first four bytes represent the top-half of the `N` from the
    // `Nintendo` logo.
    //
    // The first byte `CE` draws the top two lines of 4 pixels, the first 4 bits
    // for the top row of 4 pixels, and the other 4 bits for the bottom row.
    //
    // - `C` = `0b1100`, hence `##..`
    // - `E` = `0b1110`, hence `###.`
    //
    // The next byte `ED` goes _down_ one 4x4 tile in the image:
    //
    // - `E` = `0b1110`, hence `###.`
    // - `D` = `0b1101`, hence `##.#`
    //
    // Now rather than going down again, we start over at the top and go to the
    // right one tile.
    //
    // We repeat this until we have moved to the right 12 tiles (48 pixels),
    // then move down to the bottom half of the logo and repeat the process.
    //
    // So the bytes correspond to single tiles laid out like this:
    //
    // ```
    // 0 2 4 6 8
    // 1 3 5 7 ...
    // ```
    pub fn draw_logo(self: *const Rom) [8 * 48 + 7]u8 {
        var logo: [8 * 48 + 7]u8 = undefined;
        var i: usize = 0;
        while (i < 7) : (i += 1) {
            logo[(i + 1) * 48 + i] = '\n';
        }
        // Top row of tiles:
        i = 0;
        while ((0x0104 + i) < 0x011C) : (i += 1) {
            const byte = self._raw_data[0x0104 + i];
            const tile_x = i / 2;
            const tile_y = (i % 2) * 2;
            const start1 = tile_y * 49 + tile_x * 4;
            const start2 = (tile_y + 1) * 49 + tile_x * 4;
            const one: u8 = 1;
            var bit: u3 = 7;
            while (bit > 3) : (bit -= 1) {
                logo[start1 + (7 - bit)] = if ((byte & one << (bit - 0)) != 0) '#' else '.';
                logo[start2 + (7 - bit)] = if ((byte & one << (bit - 4)) != 0) '#' else '.';
            }
        }

        // Bottom row of tiles:
        i = 0;
        while ((0x011C + i) < 0x0134) : (i += 1) {
            const byte = self._raw_data[0x011C + i];
            const tile_x = i / 2;
            const tile_y = 4 + (i % 2) * 2;
            const start1 = tile_y * 49 + tile_x * 4;
            const start2 = (tile_y + 1) * 49 + tile_x * 4;
            const one: u8 = 1;
            var bit: u3 = 7;
            while (bit > 3) : (bit -= 1) {
                logo[start1 + (7 - bit)] = if ((byte & one << (bit - 0)) != 0) '#' else '.';
                logo[start2 + (7 - bit)] = if ((byte & one << (bit - 4)) != 0) '#' else '.';
            }
        }

        return logo;
    }

    pub fn deinit(self: *const Rom) void {
        self.allocator.free(self._raw_data);
    }

    //
    // Emulator methods
    //

    /// A read from the bus at a given address.
    ///
    /// Can return an error if the read is out of range of the cartridge ROM, in
    /// which case the caller (i.e. the Bus) should handle the read instead.
    pub fn bus_read(self: *const Rom, addr: u16) !u8 {
        // TODO: Handle mappers and such
        //
        // We might want to return something other than `!u8` (maybe a union of
        // some kind) for scenarios where we want to allow the Rom to defer to
        // the bus to handle things like I/O or other devices.
        if (addr > self._raw_data.len) {
            return ReadError.OutOfRange;
        }

        return self._raw_data[addr];
    }
};

test "read from file and load from buffer" {
    var rom = try Rom.from_file("pokemon_blue.gb", std.testing.allocator);
    defer rom.deinit();

    print("\n{any}\n", .{rom});
    print("\n\n{s}\n", .{rom.draw_logo()});
}
