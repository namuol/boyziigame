//! CPU "integration" tests

const std = @import("std");
const expect = std.testing.expect;

// No gods, no kings, only bus
const Bus = @import("./bus.zig").Bus;
const Rom = @import("./rom.zig").Rom;
const PPU = @import("./ppu.zig").PPU;
const CPU = @import("./cpu.zig").CPU;

test "basic cycle (LD)" {
    const raw_data = try std.testing.allocator.alloc(u8, 10);

    var bus_ = try Bus.init(std.testing.allocator, Rom{ ._raw_data = raw_data, .allocator = std.testing.allocator });
    defer bus_.deinit();
    defer bus_.rom.deinit();
    var cpu = CPU{ .bus = &bus_ };
    bus_.cpu = &cpu;

    // LD BC, $1234
    raw_data[0x0000] = 0x01;
    raw_data[0x0001] = 0x34;
    raw_data[0x0002] = 0x12;

    // HACK: Disable boot rom:
    cpu.hardwareRegisters[0x50] = 0x01;

    var i: usize = 0;
    cpu.step();
    try expect(cpu.pc == 0x0003);
    try expect(cpu.bc() == 0x1234);

    // LD (BC), A
    // We write 0x42 to the start of RAM:
    raw_data[0x0003] = 0x02;
    cpu.a = 0x42;
    cpu.set_bc(0xC000);
    i = 0;
    cpu.step();
    try expect(cpu.pc == 0x0004);
    try expect(cpu.bus.read(0xC000) == 0x42);

    // LD A, $42
    raw_data[0x0004] = 0x3E;
    raw_data[0x0005] = 0x42;
    cpu.a = 0;
    i = 0;
    cpu.step();
    try expect(cpu.pc == 0x0006);
    try expect(cpu.a == 0x42);
}

test "basic cycle (INC)" {
    const raw_data = try std.testing.allocator.alloc(u8, 10);
    // INC A
    raw_data[0x0000] = 0x3C;
    // INC B
    raw_data[0x0001] = 0x04;
    // INC C
    raw_data[0x0002] = 0x0C;
    // INC D
    raw_data[0x0003] = 0x14;
    // INC E
    raw_data[0x0004] = 0x1C;
    // INC H
    raw_data[0x0005] = 0x24;
    // INC L
    raw_data[0x0006] = 0x2C;

    var bus_ = try Bus.init(std.testing.allocator, Rom{ ._raw_data = raw_data, .allocator = std.testing.allocator });
    defer bus_.deinit();
    defer bus_.rom.deinit();
    var cpu = CPU{ .bus = &bus_ };
    bus_.cpu = &cpu;

    // Disable bootROM so we read directly from ROM:
    cpu.hardwareRegisters[0x50] = 0x01;

    cpu.step();
    try expect(cpu.a == 0x01);

    cpu.step();
    try expect(cpu.b == 0x01);

    cpu.step();
    try expect(cpu.c == 0x01);

    cpu.step();
    try expect(cpu.d == 0x01);

    cpu.step();
    try expect(cpu.e == 0x01);

    cpu.step();
    try expect(cpu.h == 0x01);

    cpu.step();
    try expect(cpu.l == 0x01);
}

test "disassemble" {
    var rom = try Rom.from_file("pokemon_blue.gb", std.testing.allocator);
    defer rom.deinit();

    var ppu = try PPU.init(std.testing.allocator);
    defer ppu.deinit();

    var bus = try Bus.init(std.testing.allocator, &rom, &ppu);
    defer bus.deinit();

    var cpu = try CPU.init(std.testing.allocator, &bus);
    defer cpu.deinit();
    bus.cpu = &cpu;
    cpu.boot();

    // Output format borrowed from the excellent SameBoy debugger:
    const expected = (
        \\  ->0100: NOP
        \\    0101: JP $0150
        \\    0104: ADC $ed
        \\    0106: LD h, [hl]
        \\    0107: LD h, [hl]
        \\    0108: CALL z, $000d
        \\    010b: DEC bc
        \\    010c: INC bc
        \\    010d: LD [hl], e
        \\    010e: NOP
        \\    010f: ADD e
        \\    0110: NOP
        \\    0111: INC c
        \\    0112: NOP
        \\    0113: DEC c
        \\    0114: NOP
        \\    0115: LD [$1f11], sp
        \\    0118: ADC b
        \\    0119: ADC c
        \\    011a: NOP
        \\    011b: LD c, $dc
        \\    011d: CALL z, $e66e
        \\    0120: .BYTE $dd
        \\    0121: .BYTE $dd
        \\    0122: RETI
        \\    0123: SBC c
        \\    0124: CP e
        \\    0125: CP e
        \\    0126: LD h, a
        \\    0127: LD h, e
        \\    0128: LD l, [hl]
        \\    0129: LD c, $ec
        \\    012b: CALL z, $dcdd
        \\    012e: SBC c
        \\    012f: SBC a
        \\    0130: CP e
        \\    0131: CP c
        \\    0132: INC sp
        \\    0133: LD a, $50
        \\    0135: LD c, a
        \\    0136: LD c, e
        \\    0137: LD b, l
        \\    0138: LD c, l
        \\    0139: LD c, a
        \\    013a: LD c, [hl]
        \\    013b: JR nz, $017f
        \\    013d: LD c, h
        \\    013e: LD d, l
        \\    013f: LD b, l
        \\    0140: NOP
        \\    0141: NOP
        \\    0142: NOP
        \\    0143: NOP
        \\    0144: JR nc, $0177
        \\    0146: INC bc
        \\    0147: INC de
        \\    0148: DEC b
        \\    0149: INC bc
        \\    014a: LD bc, $0033
        \\    014d: .BYTE $d3
        \\    014e: SBC l
        \\    014f: LD a, [bc]
        \\    0150: CP $11
        \\    0152: JR z, $0157
        \\    0154: XOR a
        \\    0155: JR $0159
        \\    0157: LD a, $00
        \\    0159: LD [$cf1a], a
        \\    015c: JP $1f54
        \\    015f: LD a, $20
        \\    0161: LD c, $00
        \\
    );

    var actual = try std.fmt.allocPrint(std.testing.allocator, "{}", .{cpu.disassemble(71)});
    defer std.testing.allocator.free(actual);
    try std.testing.expectEqualStrings(expected, actual);
}

// test "real world ROM panic" {
//     var rom = try Rom.from_file("pokemon_blue.gb", std.testing.allocator);
//     defer rom.deinit();

//     var bus = try Bus.init(std.testing.allocator, &rom);
//     defer bus.deinit();

//     var cpu = try CPU.init(std.testing.allocator, &bus);
//     defer cpu.deinit();
//     bus.cpu = &cpu;
//     cpu.boot();

//     // const fmt_debug = "registers:\n{}\n\nopcode: {X:0>2}\ndisassemble:\n{}\n";
//     var buf = std.ArrayList(u8).init(std.testing.allocator);
//     defer buf.deinit();

//     var i: usize = 0;
//     while (i < 100) : (i += 1) {
//         // const opcode = cpu.bus.read(cpu.pc);
//         // std.debug.print(fmt_debug, .{ cpu.registers(), opcode, cpu.disassemble(5) });
//         cpu.step();
//     }
// }

test "real world ROM log match" {
    // From SameBoy; TODO use actual Gameboy-logs: https://github.com/wheremyfoodat/Gameboy-logs
    const expected = (
        \\registers:
        \\AF  = $01b0 (CH-Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $0100
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0100: NOP
        \\    0101: JP $0150
        \\    0104: ADC $ed
        \\    0106: LD h, [hl]
        \\    0107: LD h, [hl]
        \\
        \\registers:
        \\AF  = $01b0 (CH-Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $0101
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0101: JP $0150
        \\    0104: ADC $ed
        \\    0106: LD h, [hl]
        \\    0107: LD h, [hl]
        \\    0108: CALL z, $000d
        \\
        \\registers:
        \\AF  = $01b0 (CH-Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $0150
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0150: CP $11
        \\    0152: JR z, $0157
        \\    0154: XOR a
        \\    0155: JR $0159
        \\    0157: LD a, $00
        \\
        \\registers:
        \\AF  = $0150 (C-N-)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $0152
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0152: JR z, $0157
        \\    0154: XOR a
        \\    0155: JR $0159
        \\    0157: LD a, $00
        \\    0159: LD [$cf1a], a
        \\
        \\registers:
        \\AF  = $0150 (C-N-)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $0154
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0154: XOR a
        \\    0155: JR $0159
        \\    0157: LD a, $00
        \\    0159: LD [$cf1a], a
        \\    015c: JP $1f54
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $0155
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0155: JR $0159
        \\    0157: LD a, $00
        \\    0159: LD [$cf1a], a
        \\    015c: JP $1f54
        \\    015f: LD a, $20
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $0159
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0159: LD [$cf1a], a
        \\    015c: JP $1f54
        \\    015f: LD a, $20
        \\    0161: LD c, $00
        \\    0163: LDH [rJOYP & $FF], a ; =$00
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $015c
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->015c: JP $1f54
        \\    015f: LD a, $20
        \\    0161: LD c, $00
        \\    0163: LDH [rJOYP & $FF], a ; =$00
        \\    0165: LDH a, [rJOYP & $FF] ; =$00
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f54
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f54: DI
        \\    1f55: XOR a
        \\    1f56: LDH [rIF & $FF], a ; =$0f
        \\    1f58: LDH [rIE & $FF], a ; =$ff
        \\    1f5a: LDH [rSCX & $FF], a ; =$43
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f55
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f55: XOR a
        \\    1f56: LDH [rIF & $FF], a ; =$0f
        \\    1f58: LDH [rIE & $FF], a ; =$ff
        \\    1f5a: LDH [rSCX & $FF], a ; =$43
        \\    1f5c: LDH [rSCY & $FF], a ; =$42
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f56
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f56: LDH [rIF & $FF], a ; =$0f
        \\    1f58: LDH [rIE & $FF], a ; =$ff
        \\    1f5a: LDH [rSCX & $FF], a ; =$43
        \\    1f5c: LDH [rSCY & $FF], a ; =$42
        \\    1f5e: LDH [rSB & $FF], a ; =$01
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f58
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f58: LDH [rIE & $FF], a ; =$ff
        \\    1f5a: LDH [rSCX & $FF], a ; =$43
        \\    1f5c: LDH [rSCY & $FF], a ; =$42
        \\    1f5e: LDH [rSB & $FF], a ; =$01
        \\    1f60: LDH [rSC & $FF], a ; =$02
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f5a
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f5a: LDH [rSCX & $FF], a ; =$43
        \\    1f5c: LDH [rSCY & $FF], a ; =$42
        \\    1f5e: LDH [rSB & $FF], a ; =$01
        \\    1f60: LDH [rSC & $FF], a ; =$02
        \\    1f62: LDH [rWX & $FF], a ; =$4b
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f5c
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f5c: LDH [rSCY & $FF], a ; =$42
        \\    1f5e: LDH [rSB & $FF], a ; =$01
        \\    1f60: LDH [rSC & $FF], a ; =$02
        \\    1f62: LDH [rWX & $FF], a ; =$4b
        \\    1f64: LDH [rWY & $FF], a ; =$4a
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f5e
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f5e: LDH [rSB & $FF], a ; =$01
        \\    1f60: LDH [rSC & $FF], a ; =$02
        \\    1f62: LDH [rWX & $FF], a ; =$4b
        \\    1f64: LDH [rWY & $FF], a ; =$4a
        \\    1f66: LDH [rTMA & $FF], a ; =$06
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f60
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f60: LDH [rSC & $FF], a ; =$02
        \\    1f62: LDH [rWX & $FF], a ; =$4b
        \\    1f64: LDH [rWY & $FF], a ; =$4a
        \\    1f66: LDH [rTMA & $FF], a ; =$06
        \\    1f68: LDH [rTAC & $FF], a ; =$07
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f62
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f62: LDH [rWX & $FF], a ; =$4b
        \\    1f64: LDH [rWY & $FF], a ; =$4a
        \\    1f66: LDH [rTMA & $FF], a ; =$06
        \\    1f68: LDH [rTAC & $FF], a ; =$07
        \\    1f6a: LDH [rBGP & $FF], a ; =$47
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f64
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f64: LDH [rWY & $FF], a ; =$4a
        \\    1f66: LDH [rTMA & $FF], a ; =$06
        \\    1f68: LDH [rTAC & $FF], a ; =$07
        \\    1f6a: LDH [rBGP & $FF], a ; =$47
        \\    1f6c: LDH [rOBP0 & $FF], a ; =$48
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f66
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f66: LDH [rTMA & $FF], a ; =$06
        \\    1f68: LDH [rTAC & $FF], a ; =$07
        \\    1f6a: LDH [rBGP & $FF], a ; =$47
        \\    1f6c: LDH [rOBP0 & $FF], a ; =$48
        \\    1f6e: LDH [rOBP1 & $FF], a ; =$49
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f68
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f68: LDH [rTAC & $FF], a ; =$07
        \\    1f6a: LDH [rBGP & $FF], a ; =$47
        \\    1f6c: LDH [rOBP0 & $FF], a ; =$48
        \\    1f6e: LDH [rOBP1 & $FF], a ; =$49
        \\    1f70: LD a, $80
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f6a
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f6a: LDH [rBGP & $FF], a ; =$47
        \\    1f6c: LDH [rOBP0 & $FF], a ; =$48
        \\    1f6e: LDH [rOBP1 & $FF], a ; =$49
        \\    1f70: LD a, $80
        \\    1f72: LDH [rLCDC & $FF], a ; =$40
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f6c
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f6c: LDH [rOBP0 & $FF], a ; =$48
        \\    1f6e: LDH [rOBP1 & $FF], a ; =$49
        \\    1f70: LD a, $80
        \\    1f72: LDH [rLCDC & $FF], a ; =$40
        \\    1f74: CALL $0061
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f6e
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f6e: LDH [rOBP1 & $FF], a ; =$49
        \\    1f70: LD a, $80
        \\    1f72: LDH [rLCDC & $FF], a ; =$40
        \\    1f74: CALL $0061
        \\    1f77: LD sp, $dfff
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f70
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f70: LD a, $80
        \\    1f72: LDH [rLCDC & $FF], a ; =$40
        \\    1f74: CALL $0061
        \\    1f77: LD sp, $dfff
        \\    1f7a: LD hl, $c000
        \\
        \\registers:
        \\AF  = $8080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f72
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f72: LDH [rLCDC & $FF], a ; =$40
        \\    1f74: CALL $0061
        \\    1f77: LD sp, $dfff
        \\    1f7a: LD hl, $c000
        \\    1f7d: LD bc, $2000
        \\
        \\registers:
        \\AF  = $8080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f74
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f74: CALL $0061
        \\    1f77: LD sp, $dfff
        \\    1f7a: LD hl, $c000
        \\    1f7d: LD bc, $2000
        \\    1f80: LD [hl], $00
        \\
        \\registers:
        \\AF  = $8080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffc
        \\PC  = $0061
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0061: XOR a
        \\    0062: LDH [rIF & $FF], a ; =$0f
        \\    0064: LDH a, [rIE & $FF] ; =$ff
        \\    0066: LD b, a
        \\    0067: RES a, 0
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffc
        \\PC  = $0062
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0062: LDH [rIF & $FF], a ; =$0f
        \\    0064: LDH a, [rIE & $FF] ; =$ff
        \\    0066: LD b, a
        \\    0067: RES a, 0
        \\    0069: LDH [rIE & $FF], a ; =$ff
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffc
        \\PC  = $0064
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0064: LDH a, [rIE & $FF] ; =$ff
        \\    0066: LD b, a
        \\    0067: RES a, 0
        \\    0069: LDH [rIE & $FF], a ; =$ff
        \\    006b: LDH a, [rLY & $FF] ; =$44
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffc
        \\PC  = $0066
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0066: LD b, a
        \\    0067: RES a, 0
        \\    0069: LDH [rIE & $FF], a ; =$ff
        \\    006b: LDH a, [rLY & $FF] ; =$44
        \\    006d: CP $91
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffc
        \\PC  = $0067
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0067: RES a, 0
        \\    0069: LDH [rIE & $FF], a ; =$ff
        \\    006b: LDH a, [rLY & $FF] ; =$44
        \\    006d: CP $91
        \\    006f: JR nz, $006b
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffc
        \\PC  = $0069
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0069: LDH [rIE & $FF], a ; =$ff
        \\    006b: LDH a, [rLY & $FF] ; =$44
        \\    006d: CP $91
        \\    006f: JR nz, $006b
        \\    0071: LDH a, [rLCDC & $FF] ; =$40
        \\
        \\registers:
        \\AF  = $0080 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffc
        \\PC  = $006b
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->006b: LDH a, [rLY & $FF] ; =$44
        \\    006d: CP $91
        \\    006f: JR nz, $006b
        \\    0071: LDH a, [rLCDC & $FF] ; =$40
        \\    0073: AND $7f
        \\
        \\registers:
        \\AF  = $9180 (---Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffc
        \\PC  = $006d
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->006d: CP $91
        \\    006f: JR nz, $006b
        \\    0071: LDH a, [rLCDC & $FF] ; =$40
        \\    0073: AND $7f
        \\    0075: LDH [rLCDC & $FF], a ; =$40
        \\
        \\registers:
        \\AF  = $91c0 (--NZ)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffc
        \\PC  = $006f
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->006f: JR nz, $006b
        \\    0071: LDH a, [rLCDC & $FF] ; =$40
        \\    0073: AND $7f
        \\    0075: LDH [rLCDC & $FF], a ; =$40
        \\    0077: LD a, b
        \\
        \\registers:
        \\AF  = $91c0 (--NZ)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffc
        \\PC  = $0071
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0071: LDH a, [rLCDC & $FF] ; =$40
        \\    0073: AND $7f
        \\    0075: LDH [rLCDC & $FF], a ; =$40
        \\    0077: LD a, b
        \\    0078: LDH [rIE & $FF], a ; =$ff
        \\
        \\registers:
        \\AF  = $80c0 (--NZ)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffc
        \\PC  = $0073
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0073: AND $7f
        \\    0075: LDH [rLCDC & $FF], a ; =$40
        \\    0077: LD a, b
        \\    0078: LDH [rIE & $FF], a ; =$ff
        \\    007a: RET
        \\
        \\registers:
        \\AF  = $00a0 (-H-Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffc
        \\PC  = $0075
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0075: LDH [rLCDC & $FF], a ; =$40
        \\    0077: LD a, b
        \\    0078: LDH [rIE & $FF], a ; =$ff
        \\    007a: RET
        \\    007b: LDH a, [rLCDC & $FF] ; =$40
        \\
        \\registers:
        \\AF  = $00a0 (-H-Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffc
        \\PC  = $0077
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0077: LD a, b
        \\    0078: LDH [rIE & $FF], a ; =$ff
        \\    007a: RET
        \\    007b: LDH a, [rLCDC & $FF] ; =$40
        \\    007d: SET a, 7
        \\
        \\registers:
        \\AF  = $00a0 (-H-Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffc
        \\PC  = $0078
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->0078: LDH [rIE & $FF], a ; =$ff
        \\    007a: RET
        \\    007b: LDH a, [rLCDC & $FF] ; =$40
        \\    007d: SET a, 7
        \\    007f: LDH [rLCDC & $FF], a ; =$40
        \\
        \\registers:
        \\AF  = $00a0 (-H-Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffc
        \\PC  = $007a
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->007a: RET
        \\    007b: LDH a, [rLCDC & $FF] ; =$40
        \\    007d: SET a, 7
        \\    007f: LDH [rLCDC & $FF], a ; =$40
        \\    0081: RET
        \\
        \\registers:
        \\AF  = $00a0 (-H-Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $fffe
        \\PC  = $1f77
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f77: LD sp, $dfff
        \\    1f7a: LD hl, $c000
        \\    1f7d: LD bc, $2000
        \\    1f80: LD [hl], $00
        \\    1f82: INC hl
        \\
        \\registers:
        \\AF  = $00a0 (-H-Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $014d
        \\SP  = $dfff
        \\PC  = $1f7a
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f7a: LD hl, $c000
        \\    1f7d: LD bc, $2000
        \\    1f80: LD [hl], $00
        \\    1f82: INC hl
        \\    1f83: DEC bc
        \\
        \\registers:
        \\AF  = $00a0 (-H-Z)
        \\BC  = $0013
        \\DE  = $00d8
        \\HL  = $c000
        \\SP  = $dfff
        \\PC  = $1f7d
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f7d: LD bc, $2000
        \\    1f80: LD [hl], $00
        \\    1f82: INC hl
        \\    1f83: DEC bc
        \\    1f84: LD a, b
        \\
        \\registers:
        \\AF  = $00a0 (-H-Z)
        \\BC  = $2000
        \\DE  = $00d8
        \\HL  = $c000
        \\SP  = $dfff
        \\PC  = $1f80
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f80: LD [hl], $00
        \\    1f82: INC hl
        \\    1f83: DEC bc
        \\    1f84: LD a, b
        \\    1f85: OR c
        \\
        \\registers:
        \\AF  = $00a0 (-H-Z)
        \\BC  = $2000
        \\DE  = $00d8
        \\HL  = $c000
        \\SP  = $dfff
        \\PC  = $1f82
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f82: INC hl
        \\    1f83: DEC bc
        \\    1f84: LD a, b
        \\    1f85: OR c
        \\    1f86: JR nz, $1f80
        \\
        \\registers:
        \\AF  = $00a0 (-H-Z)
        \\BC  = $2000
        \\DE  = $00d8
        \\HL  = $c001
        \\SP  = $dfff
        \\PC  = $1f83
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f83: DEC bc
        \\    1f84: LD a, b
        \\    1f85: OR c
        \\    1f86: JR nz, $1f80
        \\    1f88: CALL $2004
        \\
        \\registers:
        \\AF  = $00a0 (-H-Z)
        \\BC  = $1fff
        \\DE  = $00d8
        \\HL  = $c001
        \\SP  = $dfff
        \\PC  = $1f84
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f84: LD a, b
        \\    1f85: OR c
        \\    1f86: JR nz, $1f80
        \\    1f88: CALL $2004
        \\    1f8b: LD hl, $ff80
        \\
        \\registers:
        \\AF  = $1fa0 (-H-Z)
        \\BC  = $1fff
        \\DE  = $00d8
        \\HL  = $c001
        \\SP  = $dfff
        \\PC  = $1f85
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f85: OR c
        \\    1f86: JR nz, $1f80
        \\    1f88: CALL $2004
        \\    1f8b: LD hl, $ff80
        \\    1f8e: LD bc, $007f
        \\
        \\registers:
        \\AF  = $ff00 (----)
        \\BC  = $1fff
        \\DE  = $00d8
        \\HL  = $c001
        \\SP  = $dfff
        \\PC  = $1f86
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f86: JR nz, $1f80
        \\    1f88: CALL $2004
        \\    1f8b: LD hl, $ff80
        \\    1f8e: LD bc, $007f
        \\    1f91: CALL $36e0
        \\
        \\registers:
        \\AF  = $ff00 (----)
        \\BC  = $1fff
        \\DE  = $00d8
        \\HL  = $c001
        \\SP  = $dfff
        \\PC  = $1f80
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f80: LD [hl], $00
        \\    1f82: INC hl
        \\    1f83: DEC bc
        \\    1f84: LD a, b
        \\    1f85: OR c
        \\
        \\registers:
        \\AF  = $ff00 (----)
        \\BC  = $1fff
        \\DE  = $00d8
        \\HL  = $c001
        \\SP  = $dfff
        \\PC  = $1f82
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f82: INC hl
        \\    1f83: DEC bc
        \\    1f84: LD a, b
        \\    1f85: OR c
        \\    1f86: JR nz, $1f80
        \\
        \\registers:
        \\AF  = $ff00 (----)
        \\BC  = $1fff
        \\DE  = $00d8
        \\HL  = $c002
        \\SP  = $dfff
        \\PC  = $1f83
        \\IME = Disabled
        \\
        \\disassemble:
        \\  ->1f83: DEC bc
        \\    1f84: LD a, b
        \\    1f85: OR c
        \\    1f86: JR nz, $1f80
        \\    1f88: CALL $2004
        \\
        \\
    );

    var rom = try Rom.from_file("pokemon_blue.gb", std.testing.allocator);
    defer rom.deinit();

    var ppu = try PPU.init(std.testing.allocator);
    defer ppu.deinit();

    var bus = try Bus.init(std.testing.allocator, &rom, &ppu);
    defer bus.deinit();

    var cpu = try CPU.init(std.testing.allocator, &bus);
    defer cpu.deinit();
    bus.cpu = &cpu;
    cpu.boot();

    const fmt = "registers:\n{}\n\ndisassemble:\n{}\n";
    // const fmt_debug = "registers:\n{}\n\nopcode: {X:0>2}\ndisassemble:\n{}\n";
    var buf = std.ArrayList(u8).init(std.testing.allocator);
    defer buf.deinit();
    var writer = buf.writer();

    var i: usize = 0;
    while (i < 53) : (i += 1) {
        // const opcode = cpu.bus.read(cpu.pc);
        // std.debug.print(fmt_debug, .{ cpu.registers(), opcode, cpu.disassemble(5) });
        try writer.print(fmt, .{ cpu.registers(), cpu.disassemble(5) });
        cpu.step();
    }

    try std.testing.expectEqualStrings(expected, buf.items);
}
