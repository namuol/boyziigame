//! SM83 "integration" tests

const std = @import("std");
const expect = std.testing.expect;

// No gods, no kings, only bus
const Bus = @import("./bus.zig").Bus;
const Rom = @import("./rom.zig").Rom;
const SM83 = @import("./sm83.zig").SM83;

test "basic cycle (LD)" {
    const raw_data = try std.testing.allocator.alloc(u8, 10);

    const bus_ = try Bus.init(std.testing.allocator, Rom{ ._raw_data = raw_data, .allocator = std.testing.allocator });
    defer bus_.deinit();
    defer bus_.rom.deinit();
    var sm83 = SM83{ .bus = bus_ };

    // LD BC, $1234
    raw_data[0x0000] = 0x01;
    raw_data[0x0001] = 0x34;
    raw_data[0x0002] = 0x12;
    var i: usize = 0;
    sm83.step();
    try expect(sm83.bc() == 0x1234);
    try expect(sm83.pc == 0x0003);

    // LD (BC), A
    // We write 0x42 to the start of RAM:
    raw_data[0x0003] = 0x02;
    sm83.a = 0x42;
    sm83.set_bc(0xC000);
    i = 0;
    sm83.step();
    try expect(sm83.bus.read(0xC000) == 0x42);
    try expect(sm83.pc == 0x0004);

    // LD A, $42
    raw_data[0x0004] = 0x3E;
    raw_data[0x0005] = 0x42;
    sm83.a = 0;
    i = 0;
    sm83.step();
    try expect(sm83.a == 0x42);
    try expect(sm83.pc == 0x0006);
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

    const bus_ = try Bus.init(std.testing.allocator, Rom{ ._raw_data = raw_data, .allocator = std.testing.allocator });
    defer bus_.deinit();
    defer bus_.rom.deinit();
    var sm83 = SM83{ .bus = bus_ };

    sm83.step();
    try expect(sm83.a == 0x01);

    sm83.step();
    try expect(sm83.b == 0x01);

    sm83.step();
    try expect(sm83.c == 0x01);

    sm83.step();
    try expect(sm83.d == 0x01);

    sm83.step();
    try expect(sm83.e == 0x01);

    sm83.step();
    try expect(sm83.h == 0x01);

    sm83.step();
    try expect(sm83.l == 0x01);
}

test "disassemble" {
    var rom = try Rom.from_file("pokemon_blue.gb", std.testing.allocator);
    defer rom.deinit();

    const bus = try Bus.init(std.testing.allocator, rom);
    defer bus.deinit();

    var cpu = SM83{ .bus = bus };
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

test "real world ROM" {
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
        // \\registers:
        // \\AF  = $0080 (---Z)
        // \\BC  = $0013
        // \\DE  = $00d8
        // \\HL  = $014d
        // \\SP  = $fffe
        // \\PC  = $0159
        // \\IME = Disabled
        // \\
        // \\disassemble:
        // \\  ->0159: LD [$cf1a], a
        // \\    015c: JP $1f54
        // \\    015f: LD a, $20
        // \\    0161: LD c, $00
        // \\    0163: LDH [rJOYP & $FF], a ; =$00
        // \\
        // \\registers:
        // \\AF  = $0080 (---Z)
        // \\BC  = $0013
        // \\DE  = $00d8
        // \\HL  = $014d
        // \\SP  = $fffe
        // \\PC  = $015c
        // \\IME = Disabled
        // \\
        // \\disassemble:
        // \\  ->015c: JP $1f54
        // \\    015f: LD a, $20
        // \\    0161: LD c, $00
        // \\    0163: LDH [rJOYP & $FF], a ; =$00
        // \\    0165: LDH a, [rJOYP & $FF] ; =$00
        // \\
        // \\registers:
        // \\AF  = $0080 (---Z)
        // \\BC  = $0013
        // \\DE  = $00d8
        // \\HL  = $014d
        // \\SP  = $fffe
        // \\PC  = $1f54
        // \\IME = Disabled
        // \\
        // \\disassemble:
        // \\  ->1f54: DI
        // \\    1f55: XOR a
        // \\    1f56: LDH [rIF & $FF], a ; =$0f
        // \\    1f58: LDH [rIE & $FF], a ; =$ff
        // \\    1f5a: LDH [rSCX & $FF], a ; =$43
        \\
    );

    var rom = try Rom.from_file("pokemon_blue.gb", std.testing.allocator);
    defer rom.deinit();

    const bus = try Bus.init(std.testing.allocator, rom);
    defer bus.deinit();

    var cpu = SM83{ .bus = bus };
    cpu.boot();
    const fmt = "registers:\n{}\n\ndisassemble:\n{}\n";
    // const fmt_debug = "registers:\n{}\n\nopcode: {X:0>2}\ndisassemble:\n{}\n";
    var buf = std.ArrayList(u8).init(std.testing.allocator);
    defer buf.deinit();
    var writer = buf.writer();

    var i: usize = 0;
    while (i < 6) : (i += 1) {
        // const opcode = cpu.bus.read(cpu.pc);
        // std.debug.print(fmt_debug, .{ cpu.registers(), opcode, cpu.disassemble(5) });
        try writer.print(fmt, .{ cpu.registers(), cpu.disassemble(5) });
        cpu.step();
    }

    try std.testing.expectEqualStrings(expected, buf.items);
}
