const Mnemonic = enum {
    ADC,
    ADD,
    AND,
    BIT,
    CALL,
    CCF,
    CP,
    CPL,
    DAA,
    DEC,
    DI,
    EI,
    HALT,
    ILLEGAL_D3,
    ILLEGAL_DB,
    ILLEGAL_DD,
    ILLEGAL_E3,
    ILLEGAL_E4,
    ILLEGAL_EB,
    ILLEGAL_EC,
    ILLEGAL_ED,
    ILLEGAL_F4,
    ILLEGAL_FC,
    ILLEGAL_FD,
    INC,
    JP,
    JR,
    LD,
    LDH,
    NOP,
    OR,
    POP,
    PREFIX,
    PUSH,
    RES,
    RET,
    RETI,
    RL,
    RLA,
    RLC,
    RLCA,
    RR,
    RRA,
    RRC,
    RRCA,
    RST,
    SBC,
    SCF,
    SET,
    SLA,
    SRA,
    SRL,
    STOP,
    SUB,
    SWAP,
    XOR,
};

const OperandName = enum {
    _0,
    _00H,
    _1,
    _2,
    _3,
    _4,
    _5,
    _6,
    _7,
    _08H,
    _10H,
    _18H,
    _20H,
    _28H,
    _30H,
    _38H,
    A,
    a8,
    a16,
    AF,
    B,
    BC,
    C,
    D,
    d8,
    d16,
    DE,
    E,
    H,
    HL,
    L,
    NC,
    NZ,
    r8,
    SP,
    Z,
};

const Operand = struct {
    name: OperandName,
    immediate: bool,
    bytes: u2 = 0,
    increment: ?bool = null,
    decrement: ?bool = null,
};

const FlagBehavior = enum {
    // Untouched
    __,
    // Reset
    _0,
    // Set
    _1,
    // If an operation has the flags defined as Z, N, H, or C, the corresponding
    // flags are set as the operation performed dictates.
    self,
};

const FlagBehaviors = struct {
    z: FlagBehavior,
    n: FlagBehavior,
    h: FlagBehavior,
    c: FlagBehavior,
};

const Opcode = struct {
    mnemonic: Mnemonic,
    bytes: u2,
    cycles: []const u5,
    operands: []const Operand,
    immediate: bool,
    flags: FlagBehaviors,
};

// The following were generated using this JS script and running it with the
// data found in `src/sm83-opcodes.json`:
//
// template = (code, op) => `
// // ${code}
// Opcode {
//   .mnemonic = Mnemonic.${op.mnemonic},
//   .bytes = ${op.bytes},
//   .cycles = &[_]u5{ ${op.cycles.join(", ")} },
//   .operands = &[_]Operand{${op.operands
//   .map(
//     (opr) => `
//     Operand {
//       .name = OperandName.${!Number.isNaN(parseInt(opr.name[0])) ? "_" : ""}${opr.name},
//       .immediate = ${opr.immediate},${["bytes", "increment", "decrement"]
//         .map((n) => (opr[n] != null ? `.${n} = ${opr[n]},` : null))
//         .filter(n => n != null)
//         .join("\n")}
//     },
//   `
//   )
//   .join("\n")}},
//   .immediate = ${op.immediate},
//   .flags = FlagBehaviors {
//     .z = FlagBehavior.${{ "-": "__", 0: "_0", 1: "_1", Z: "self" }[op.flags.Z]},
//     .n = FlagBehavior.${{ "-": "__", 0: "_0", 1: "_1", N: "self" }[op.flags.N]},
//     .h = FlagBehavior.${{ "-": "__", 0: "_0", 1: "_1", H: "self" }[op.flags.H]},
//     .c = FlagBehavior.${{ "-": "__", 0: "_0", 1: "_1", C: "self" }[op.flags.C]},
//   },
// },
// `;

// This huge blob of generated code will inflate the size of the executable and
// increase compilation time a meaningful amount.
//
// A more memory-efficient solution could harness the patterns outlined in this
// guide's "disassembly tables":
//
// https://gb-archive.github.io/salvage/decoding_gbz80_opcodes/Decoding%20Gamboy%20Z80%20Opcodes.html

pub const UNPREFIXED = [256]Opcode{
    // 0x00
    Opcode{
        .mnemonic = Mnemonic.NOP,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x01
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 3,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.BC,
                .immediate = true,
            },
            Operand{
                .name = OperandName.d16,
                .immediate = true,
                .bytes = 2,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x02
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.BC,
                .immediate = false,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x03
    Opcode{
        .mnemonic = Mnemonic.INC,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.BC,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x04
    Opcode{
        .mnemonic = Mnemonic.INC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x05
    Opcode{
        .mnemonic = Mnemonic.DEC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x06
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x07
    Opcode{
        .mnemonic = Mnemonic.RLCA,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior._0,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x08
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 3,
        .cycles = &[_]u5{20},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.a16,
                .immediate = false,
                .bytes = 2,
            },
            Operand{
                .name = OperandName.SP,
                .immediate = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x09
    Opcode{
        .mnemonic = Mnemonic.ADD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = true,
            },
            Operand{
                .name = OperandName.BC,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x0A
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.BC,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x0B
    Opcode{
        .mnemonic = Mnemonic.DEC,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.BC,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x0C
    Opcode{
        .mnemonic = Mnemonic.INC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x0D
    Opcode{
        .mnemonic = Mnemonic.DEC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x0E
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x0F
    Opcode{
        .mnemonic = Mnemonic.RRCA,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior._0,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x10
    Opcode{
        .mnemonic = Mnemonic.STOP,
        .bytes = 2,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x11
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 3,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.DE,
                .immediate = true,
            },
            Operand{
                .name = OperandName.d16,
                .immediate = true,
                .bytes = 2,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x12
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.DE,
                .immediate = false,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x13
    Opcode{
        .mnemonic = Mnemonic.INC,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.DE,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x14
    Opcode{
        .mnemonic = Mnemonic.INC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x15
    Opcode{
        .mnemonic = Mnemonic.DEC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x16
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x17
    Opcode{
        .mnemonic = Mnemonic.RLA,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior._0,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x18
    Opcode{
        .mnemonic = Mnemonic.JR,
        .bytes = 2,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.r8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x19
    Opcode{
        .mnemonic = Mnemonic.ADD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = true,
            },
            Operand{
                .name = OperandName.DE,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x1A
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.DE,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x1B
    Opcode{
        .mnemonic = Mnemonic.DEC,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.DE,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x1C
    Opcode{
        .mnemonic = Mnemonic.INC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x1D
    Opcode{
        .mnemonic = Mnemonic.DEC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x1E
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x1F
    Opcode{
        .mnemonic = Mnemonic.RRA,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior._0,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x20
    Opcode{
        .mnemonic = Mnemonic.JR,
        .bytes = 2,
        .cycles = &[_]u5{ 12, 8 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.NZ,
                .immediate = true,
            },
            Operand{
                .name = OperandName.r8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x21
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 3,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = true,
            },
            Operand{
                .name = OperandName.d16,
                .immediate = true,
                .bytes = 2,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x22
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
                .increment = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x23
    Opcode{
        .mnemonic = Mnemonic.INC,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x24
    Opcode{
        .mnemonic = Mnemonic.INC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x25
    Opcode{
        .mnemonic = Mnemonic.DEC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x26
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x27
    Opcode{
        .mnemonic = Mnemonic.DAA,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior.__,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x28
    Opcode{
        .mnemonic = Mnemonic.JR,
        .bytes = 2,
        .cycles = &[_]u5{ 12, 8 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.Z,
                .immediate = true,
            },
            Operand{
                .name = OperandName.r8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x29
    Opcode{
        .mnemonic = Mnemonic.ADD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x2A
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
                .increment = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x2B
    Opcode{
        .mnemonic = Mnemonic.DEC,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x2C
    Opcode{
        .mnemonic = Mnemonic.INC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x2D
    Opcode{
        .mnemonic = Mnemonic.DEC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x2E
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x2F
    Opcode{
        .mnemonic = Mnemonic.CPL,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior._1,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x30
    Opcode{
        .mnemonic = Mnemonic.JR,
        .bytes = 2,
        .cycles = &[_]u5{ 12, 8 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.NC,
                .immediate = true,
            },
            Operand{
                .name = OperandName.r8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x31
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 3,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.SP,
                .immediate = true,
            },
            Operand{
                .name = OperandName.d16,
                .immediate = true,
                .bytes = 2,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x32
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
                .decrement = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x33
    Opcode{
        .mnemonic = Mnemonic.INC,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.SP,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x34
    Opcode{
        .mnemonic = Mnemonic.INC,
        .bytes = 1,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x35
    Opcode{
        .mnemonic = Mnemonic.DEC,
        .bytes = 1,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x36
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 2,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x37
    Opcode{
        .mnemonic = Mnemonic.SCF,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._1,
        },
    },

    // 0x38
    Opcode{
        .mnemonic = Mnemonic.JR,
        .bytes = 2,
        .cycles = &[_]u5{ 12, 8 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
            Operand{
                .name = OperandName.r8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x39
    Opcode{
        .mnemonic = Mnemonic.ADD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = true,
            },
            Operand{
                .name = OperandName.SP,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x3A
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
                .decrement = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x3B
    Opcode{
        .mnemonic = Mnemonic.DEC,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.SP,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x3C
    Opcode{
        .mnemonic = Mnemonic.INC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x3D
    Opcode{
        .mnemonic = Mnemonic.DEC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0x3E
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x3F
    Opcode{
        .mnemonic = Mnemonic.CCF,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x40
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x41
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x42
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x43
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x44
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x45
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x46
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x47
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x48
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x49
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x4A
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x4B
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x4C
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x4D
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x4E
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x4F
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x50
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x51
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x52
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x53
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x54
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x55
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x56
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x57
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x58
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x59
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x5A
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x5B
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x5C
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x5D
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x5E
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x5F
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x60
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x61
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x62
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x63
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x64
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x65
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x66
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x67
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x68
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x69
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x6A
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x6B
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x6C
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x6D
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x6E
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x6F
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x70
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x71
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x72
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x73
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x74
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x75
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x76
    Opcode{
        .mnemonic = Mnemonic.HALT,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x77
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x78
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x79
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x7A
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x7B
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x7C
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x7D
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x7E
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x7F
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x80
    Opcode{
        .mnemonic = Mnemonic.ADD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x81
    Opcode{
        .mnemonic = Mnemonic.ADD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x82
    Opcode{
        .mnemonic = Mnemonic.ADD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x83
    Opcode{
        .mnemonic = Mnemonic.ADD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x84
    Opcode{
        .mnemonic = Mnemonic.ADD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x85
    Opcode{
        .mnemonic = Mnemonic.ADD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x86
    Opcode{
        .mnemonic = Mnemonic.ADD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x87
    Opcode{
        .mnemonic = Mnemonic.ADD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x88
    Opcode{
        .mnemonic = Mnemonic.ADC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x89
    Opcode{
        .mnemonic = Mnemonic.ADC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x8A
    Opcode{
        .mnemonic = Mnemonic.ADC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x8B
    Opcode{
        .mnemonic = Mnemonic.ADC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x8C
    Opcode{
        .mnemonic = Mnemonic.ADC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x8D
    Opcode{
        .mnemonic = Mnemonic.ADC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x8E
    Opcode{
        .mnemonic = Mnemonic.ADC,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x8F
    Opcode{
        .mnemonic = Mnemonic.ADC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x90
    Opcode{
        .mnemonic = Mnemonic.SUB,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x91
    Opcode{
        .mnemonic = Mnemonic.SUB,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x92
    Opcode{
        .mnemonic = Mnemonic.SUB,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x93
    Opcode{
        .mnemonic = Mnemonic.SUB,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x94
    Opcode{
        .mnemonic = Mnemonic.SUB,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x95
    Opcode{
        .mnemonic = Mnemonic.SUB,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x96
    Opcode{
        .mnemonic = Mnemonic.SUB,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x97
    Opcode{
        .mnemonic = Mnemonic.SUB,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior._1,
            .n = FlagBehavior._1,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0x98
    Opcode{
        .mnemonic = Mnemonic.SBC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x99
    Opcode{
        .mnemonic = Mnemonic.SBC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x9A
    Opcode{
        .mnemonic = Mnemonic.SBC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x9B
    Opcode{
        .mnemonic = Mnemonic.SBC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x9C
    Opcode{
        .mnemonic = Mnemonic.SBC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x9D
    Opcode{
        .mnemonic = Mnemonic.SBC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x9E
    Opcode{
        .mnemonic = Mnemonic.SBC,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0x9F
    Opcode{
        .mnemonic = Mnemonic.SBC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.__,
        },
    },

    // 0xA0
    Opcode{
        .mnemonic = Mnemonic.AND,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior._0,
        },
    },

    // 0xA1
    Opcode{
        .mnemonic = Mnemonic.AND,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior._0,
        },
    },

    // 0xA2
    Opcode{
        .mnemonic = Mnemonic.AND,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior._0,
        },
    },

    // 0xA3
    Opcode{
        .mnemonic = Mnemonic.AND,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior._0,
        },
    },

    // 0xA4
    Opcode{
        .mnemonic = Mnemonic.AND,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior._0,
        },
    },

    // 0xA5
    Opcode{
        .mnemonic = Mnemonic.AND,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior._0,
        },
    },

    // 0xA6
    Opcode{
        .mnemonic = Mnemonic.AND,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior._0,
        },
    },

    // 0xA7
    Opcode{
        .mnemonic = Mnemonic.AND,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior._0,
        },
    },

    // 0xA8
    Opcode{
        .mnemonic = Mnemonic.XOR,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xA9
    Opcode{
        .mnemonic = Mnemonic.XOR,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xAA
    Opcode{
        .mnemonic = Mnemonic.XOR,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xAB
    Opcode{
        .mnemonic = Mnemonic.XOR,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xAC
    Opcode{
        .mnemonic = Mnemonic.XOR,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xAD
    Opcode{
        .mnemonic = Mnemonic.XOR,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xAE
    Opcode{
        .mnemonic = Mnemonic.XOR,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xAF
    Opcode{
        .mnemonic = Mnemonic.XOR,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior._1,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xB0
    Opcode{
        .mnemonic = Mnemonic.OR,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xB1
    Opcode{
        .mnemonic = Mnemonic.OR,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xB2
    Opcode{
        .mnemonic = Mnemonic.OR,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xB3
    Opcode{
        .mnemonic = Mnemonic.OR,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xB4
    Opcode{
        .mnemonic = Mnemonic.OR,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xB5
    Opcode{
        .mnemonic = Mnemonic.OR,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xB6
    Opcode{
        .mnemonic = Mnemonic.OR,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xB7
    Opcode{
        .mnemonic = Mnemonic.OR,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xB8
    Opcode{
        .mnemonic = Mnemonic.CP,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0xB9
    Opcode{
        .mnemonic = Mnemonic.CP,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0xBA
    Opcode{
        .mnemonic = Mnemonic.CP,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0xBB
    Opcode{
        .mnemonic = Mnemonic.CP,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0xBC
    Opcode{
        .mnemonic = Mnemonic.CP,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0xBD
    Opcode{
        .mnemonic = Mnemonic.CP,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0xBE
    Opcode{
        .mnemonic = Mnemonic.CP,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0xBF
    Opcode{
        .mnemonic = Mnemonic.CP,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior._1,
            .n = FlagBehavior._1,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xC0
    Opcode{
        .mnemonic = Mnemonic.RET,
        .bytes = 1,
        .cycles = &[_]u5{ 20, 8 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.NZ,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC1
    Opcode{
        .mnemonic = Mnemonic.POP,
        .bytes = 1,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.BC,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC2
    Opcode{
        .mnemonic = Mnemonic.JP,
        .bytes = 3,
        .cycles = &[_]u5{ 16, 12 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.NZ,
                .immediate = true,
            },
            Operand{
                .name = OperandName.a16,
                .immediate = true,
                .bytes = 2,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC3
    Opcode{
        .mnemonic = Mnemonic.JP,
        .bytes = 3,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.a16,
                .immediate = true,
                .bytes = 2,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC4
    Opcode{
        .mnemonic = Mnemonic.CALL,
        .bytes = 3,
        .cycles = &[_]u5{ 24, 12 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.NZ,
                .immediate = true,
            },
            Operand{
                .name = OperandName.a16,
                .immediate = true,
                .bytes = 2,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC5
    Opcode{
        .mnemonic = Mnemonic.PUSH,
        .bytes = 1,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.BC,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC6
    Opcode{
        .mnemonic = Mnemonic.ADD,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0xC7
    Opcode{
        .mnemonic = Mnemonic.RST,
        .bytes = 1,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._00H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC8
    Opcode{
        .mnemonic = Mnemonic.RET,
        .bytes = 1,
        .cycles = &[_]u5{ 20, 8 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.Z,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC9
    Opcode{
        .mnemonic = Mnemonic.RET,
        .bytes = 1,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xCA
    Opcode{
        .mnemonic = Mnemonic.JP,
        .bytes = 3,
        .cycles = &[_]u5{ 16, 12 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.Z,
                .immediate = true,
            },
            Operand{
                .name = OperandName.a16,
                .immediate = true,
                .bytes = 2,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xCB
    Opcode{
        .mnemonic = Mnemonic.PREFIX,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xCC
    Opcode{
        .mnemonic = Mnemonic.CALL,
        .bytes = 3,
        .cycles = &[_]u5{ 24, 12 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.Z,
                .immediate = true,
            },
            Operand{
                .name = OperandName.a16,
                .immediate = true,
                .bytes = 2,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xCD
    Opcode{
        .mnemonic = Mnemonic.CALL,
        .bytes = 3,
        .cycles = &[_]u5{24},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.a16,
                .immediate = true,
                .bytes = 2,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xCE
    Opcode{
        .mnemonic = Mnemonic.ADC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0xCF
    Opcode{
        .mnemonic = Mnemonic.RST,
        .bytes = 1,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._08H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD0
    Opcode{
        .mnemonic = Mnemonic.RET,
        .bytes = 1,
        .cycles = &[_]u5{ 20, 8 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.NC,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD1
    Opcode{
        .mnemonic = Mnemonic.POP,
        .bytes = 1,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.DE,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD2
    Opcode{
        .mnemonic = Mnemonic.JP,
        .bytes = 3,
        .cycles = &[_]u5{ 16, 12 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.NC,
                .immediate = true,
            },
            Operand{
                .name = OperandName.a16,
                .immediate = true,
                .bytes = 2,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD3
    Opcode{
        .mnemonic = Mnemonic.ILLEGAL_D3,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD4
    Opcode{
        .mnemonic = Mnemonic.CALL,
        .bytes = 3,
        .cycles = &[_]u5{ 24, 12 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.NC,
                .immediate = true,
            },
            Operand{
                .name = OperandName.a16,
                .immediate = true,
                .bytes = 2,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD5
    Opcode{
        .mnemonic = Mnemonic.PUSH,
        .bytes = 1,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.DE,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD6
    Opcode{
        .mnemonic = Mnemonic.SUB,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0xD7
    Opcode{
        .mnemonic = Mnemonic.RST,
        .bytes = 1,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._10H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD8
    Opcode{
        .mnemonic = Mnemonic.RET,
        .bytes = 1,
        .cycles = &[_]u5{ 20, 8 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD9
    Opcode{
        .mnemonic = Mnemonic.RETI,
        .bytes = 1,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xDA
    Opcode{
        .mnemonic = Mnemonic.JP,
        .bytes = 3,
        .cycles = &[_]u5{ 16, 12 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
            Operand{
                .name = OperandName.a16,
                .immediate = true,
                .bytes = 2,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xDB
    Opcode{
        .mnemonic = Mnemonic.ILLEGAL_DB,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xDC
    Opcode{
        .mnemonic = Mnemonic.CALL,
        .bytes = 3,
        .cycles = &[_]u5{ 24, 12 },
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
            Operand{
                .name = OperandName.a16,
                .immediate = true,
                .bytes = 2,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xDD
    Opcode{
        .mnemonic = Mnemonic.ILLEGAL_DD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xDE
    Opcode{
        .mnemonic = Mnemonic.SBC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0xDF
    Opcode{
        .mnemonic = Mnemonic.RST,
        .bytes = 1,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._18H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE0
    Opcode{
        .mnemonic = Mnemonic.LDH,
        .bytes = 2,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.a8,
                .immediate = false,
                .bytes = 1,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE1
    Opcode{
        .mnemonic = Mnemonic.POP,
        .bytes = 1,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE2
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = false,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE3
    Opcode{
        .mnemonic = Mnemonic.ILLEGAL_E3,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE4
    Opcode{
        .mnemonic = Mnemonic.ILLEGAL_E4,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE5
    Opcode{
        .mnemonic = Mnemonic.PUSH,
        .bytes = 1,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE6
    Opcode{
        .mnemonic = Mnemonic.AND,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior._0,
        },
    },

    // 0xE7
    Opcode{
        .mnemonic = Mnemonic.RST,
        .bytes = 1,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._20H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE8
    Opcode{
        .mnemonic = Mnemonic.ADD,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.SP,
                .immediate = true,
            },
            Operand{
                .name = OperandName.r8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior._0,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0xE9
    Opcode{
        .mnemonic = Mnemonic.JP,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xEA
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 3,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.a16,
                .immediate = false,
                .bytes = 2,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xEB
    Opcode{
        .mnemonic = Mnemonic.ILLEGAL_EB,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xEC
    Opcode{
        .mnemonic = Mnemonic.ILLEGAL_EC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xED
    Opcode{
        .mnemonic = Mnemonic.ILLEGAL_ED,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xEE
    Opcode{
        .mnemonic = Mnemonic.XOR,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xEF
    Opcode{
        .mnemonic = Mnemonic.RST,
        .bytes = 1,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._28H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xF0
    Opcode{
        .mnemonic = Mnemonic.LDH,
        .bytes = 2,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.a8,
                .immediate = false,
                .bytes = 1,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xF1
    Opcode{
        .mnemonic = Mnemonic.POP,
        .bytes = 1,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.AF,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior.self,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0xF2
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xF3
    Opcode{
        .mnemonic = Mnemonic.DI,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xF4
    Opcode{
        .mnemonic = Mnemonic.ILLEGAL_F4,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xF5
    Opcode{
        .mnemonic = Mnemonic.PUSH,
        .bytes = 1,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.AF,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xF6
    Opcode{
        .mnemonic = Mnemonic.OR,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0xF7
    Opcode{
        .mnemonic = Mnemonic.RST,
        .bytes = 1,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._30H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xF8
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 2,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = true,
            },
            Operand{
                .name = OperandName.SP,
                .immediate = true,
                .increment = true,
            },
            Operand{
                .name = OperandName.r8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior._0,
            .n = FlagBehavior._0,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0xF9
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 1,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.SP,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xFA
    Opcode{
        .mnemonic = Mnemonic.LD,
        .bytes = 3,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
            Operand{
                .name = OperandName.a16,
                .immediate = false,
                .bytes = 2,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xFB
    Opcode{
        .mnemonic = Mnemonic.EI,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xFC
    Opcode{
        .mnemonic = Mnemonic.ILLEGAL_FC,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xFD
    Opcode{
        .mnemonic = Mnemonic.ILLEGAL_FD,
        .bytes = 1,
        .cycles = &[_]u5{4},
        .operands = &[_]Operand{},
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xFE
    Opcode{
        .mnemonic = Mnemonic.CP,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.d8,
                .immediate = true,
                .bytes = 1,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._1,
            .h = FlagBehavior.self,
            .c = FlagBehavior.self,
        },
    },

    // 0xFF
    Opcode{
        .mnemonic = Mnemonic.RST,
        .bytes = 1,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._38H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },
};

pub const PREFIXED = [256]Opcode{
    // 0x00
    Opcode{
        .mnemonic = Mnemonic.RLC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x01
    Opcode{
        .mnemonic = Mnemonic.RLC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x02
    Opcode{
        .mnemonic = Mnemonic.RLC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x03
    Opcode{
        .mnemonic = Mnemonic.RLC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x04
    Opcode{
        .mnemonic = Mnemonic.RLC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x05
    Opcode{
        .mnemonic = Mnemonic.RLC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x06
    Opcode{
        .mnemonic = Mnemonic.RLC,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x07
    Opcode{
        .mnemonic = Mnemonic.RLC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x08
    Opcode{
        .mnemonic = Mnemonic.RRC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x09
    Opcode{
        .mnemonic = Mnemonic.RRC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x0A
    Opcode{
        .mnemonic = Mnemonic.RRC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x0B
    Opcode{
        .mnemonic = Mnemonic.RRC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x0C
    Opcode{
        .mnemonic = Mnemonic.RRC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x0D
    Opcode{
        .mnemonic = Mnemonic.RRC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x0E
    Opcode{
        .mnemonic = Mnemonic.RRC,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x0F
    Opcode{
        .mnemonic = Mnemonic.RRC,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x10
    Opcode{
        .mnemonic = Mnemonic.RL,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x11
    Opcode{
        .mnemonic = Mnemonic.RL,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x12
    Opcode{
        .mnemonic = Mnemonic.RL,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x13
    Opcode{
        .mnemonic = Mnemonic.RL,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x14
    Opcode{
        .mnemonic = Mnemonic.RL,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x15
    Opcode{
        .mnemonic = Mnemonic.RL,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x16
    Opcode{
        .mnemonic = Mnemonic.RL,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x17
    Opcode{
        .mnemonic = Mnemonic.RL,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x18
    Opcode{
        .mnemonic = Mnemonic.RR,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x19
    Opcode{
        .mnemonic = Mnemonic.RR,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x1A
    Opcode{
        .mnemonic = Mnemonic.RR,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x1B
    Opcode{
        .mnemonic = Mnemonic.RR,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x1C
    Opcode{
        .mnemonic = Mnemonic.RR,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x1D
    Opcode{
        .mnemonic = Mnemonic.RR,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x1E
    Opcode{
        .mnemonic = Mnemonic.RR,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x1F
    Opcode{
        .mnemonic = Mnemonic.RR,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x20
    Opcode{
        .mnemonic = Mnemonic.SLA,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x21
    Opcode{
        .mnemonic = Mnemonic.SLA,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x22
    Opcode{
        .mnemonic = Mnemonic.SLA,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x23
    Opcode{
        .mnemonic = Mnemonic.SLA,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x24
    Opcode{
        .mnemonic = Mnemonic.SLA,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x25
    Opcode{
        .mnemonic = Mnemonic.SLA,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x26
    Opcode{
        .mnemonic = Mnemonic.SLA,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x27
    Opcode{
        .mnemonic = Mnemonic.SLA,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x28
    Opcode{
        .mnemonic = Mnemonic.SRA,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x29
    Opcode{
        .mnemonic = Mnemonic.SRA,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x2A
    Opcode{
        .mnemonic = Mnemonic.SRA,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x2B
    Opcode{
        .mnemonic = Mnemonic.SRA,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x2C
    Opcode{
        .mnemonic = Mnemonic.SRA,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x2D
    Opcode{
        .mnemonic = Mnemonic.SRA,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x2E
    Opcode{
        .mnemonic = Mnemonic.SRA,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x2F
    Opcode{
        .mnemonic = Mnemonic.SRA,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x30
    Opcode{
        .mnemonic = Mnemonic.SWAP,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0x31
    Opcode{
        .mnemonic = Mnemonic.SWAP,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0x32
    Opcode{
        .mnemonic = Mnemonic.SWAP,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0x33
    Opcode{
        .mnemonic = Mnemonic.SWAP,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0x34
    Opcode{
        .mnemonic = Mnemonic.SWAP,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0x35
    Opcode{
        .mnemonic = Mnemonic.SWAP,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0x36
    Opcode{
        .mnemonic = Mnemonic.SWAP,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0x37
    Opcode{
        .mnemonic = Mnemonic.SWAP,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior._0,
        },
    },

    // 0x38
    Opcode{
        .mnemonic = Mnemonic.SRL,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x39
    Opcode{
        .mnemonic = Mnemonic.SRL,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x3A
    Opcode{
        .mnemonic = Mnemonic.SRL,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x3B
    Opcode{
        .mnemonic = Mnemonic.SRL,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x3C
    Opcode{
        .mnemonic = Mnemonic.SRL,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x3D
    Opcode{
        .mnemonic = Mnemonic.SRL,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x3E
    Opcode{
        .mnemonic = Mnemonic.SRL,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x3F
    Opcode{
        .mnemonic = Mnemonic.SRL,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._0,
            .c = FlagBehavior.self,
        },
    },

    // 0x40
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x41
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x42
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x43
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x44
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x45
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x46
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x47
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x48
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x49
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x4A
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x4B
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x4C
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x4D
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x4E
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x4F
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x50
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x51
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x52
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x53
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x54
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x55
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x56
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x57
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x58
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x59
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x5A
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x5B
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x5C
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x5D
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x5E
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x5F
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x60
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x61
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x62
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x63
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x64
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x65
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x66
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x67
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x68
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x69
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x6A
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x6B
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x6C
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x6D
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x6E
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x6F
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x70
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x71
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x72
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x73
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x74
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x75
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x76
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x77
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x78
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x79
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x7A
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x7B
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x7C
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x7D
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x7E
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{12},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x7F
    Opcode{
        .mnemonic = Mnemonic.BIT,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.self,
            .n = FlagBehavior._0,
            .h = FlagBehavior._1,
            .c = FlagBehavior.__,
        },
    },

    // 0x80
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x81
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x82
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x83
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x84
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x85
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x86
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x87
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x88
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x89
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x8A
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x8B
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x8C
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x8D
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x8E
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x8F
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x90
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x91
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x92
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x93
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x94
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x95
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x96
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x97
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x98
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x99
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x9A
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x9B
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x9C
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x9D
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x9E
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0x9F
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xA0
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xA1
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xA2
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xA3
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xA4
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xA5
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xA6
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xA7
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xA8
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xA9
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xAA
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xAB
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xAC
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xAD
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xAE
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xAF
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xB0
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xB1
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xB2
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xB3
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xB4
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xB5
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xB6
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xB7
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._6,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xB8
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xB9
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xBA
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xBB
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xBC
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xBD
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xBE
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xBF
    Opcode{
        .mnemonic = Mnemonic.RES,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._7,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC0
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC1
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC2
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC3
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC4
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC5
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC6
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC7
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._0,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC8
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xC9
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xCA
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xCB
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xCC
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xCD
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xCE
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xCF
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._1,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD0
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD1
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD2
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD3
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD4
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD5
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD6
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD7
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._2,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD8
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xD9
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xDA
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xDB
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xDC
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xDD
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xDE
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xDF
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._3,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE0
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE1
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE2
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE3
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE4
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE5
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE6
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE7
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._4,
                .immediate = true,
            },
            Operand{
                .name = OperandName.A,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE8
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.B,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xE9
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.C,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xEA
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.D,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xEB
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.E,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xEC
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.H,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xED
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{8},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.L,
                .immediate = true,
            },
        },
        .immediate = true,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },

    // 0xEE
    Opcode{
        .mnemonic = Mnemonic.SET,
        .bytes = 2,
        .cycles = &[_]u5{16},
        .operands = &[_]Operand{
            Operand{
                .name = OperandName._5,
                .immediate = true,
            },
            Operand{
                .name = OperandName.HL,
                .immediate = false,
            },
        },
        .immediate = false,
        .flags = FlagBehaviors{
            .z = FlagBehavior.__,
            .n = FlagBehavior.__,
            .h = FlagBehavior.__,
            .c = FlagBehavior.__,
        },
    },
};

const std = @import("std");
const expect = std.testing.expect;
test "size" {
    try expect(UNPREFIXED.len == 256);
}

test "nop" {
    try expect(UNPREFIXED[0].mnemonic == Mnemonic.NOP);
}
