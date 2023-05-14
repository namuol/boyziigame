const opcodes = require("./sm83-opcodes.json");
const template = (code, op) => `
// ${code}
Opcode {
  .mnemonic = Mnemonic.${op.mnemonic},
  .bytes = ${op.bytes},
  .cycles = &[_]u5{ ${op.cycles.join(", ")} },
  .operands = &[_]Operand{${op.operands
    .map(
      (opr) => `
    Operand {
      .name = OperandName.${!Number.isNaN(parseInt(opr.name[0])) ? "_" : ""}${
        opr.name
      },
      .immediate = ${opr.immediate},${["bytes", "increment", "decrement"]
        .map((n) => (opr[n] != null ? `.${n} = ${opr[n]},` : null))
        .filter((n) => n != null)
        .join("\n")}
    },
  `
    )
    .join("\n")}},
  .immediate = ${op.immediate},
  .flags = FlagBehaviors {
    .z = FlagBehavior.${{ "-": "__", 0: "_0", 1: "_1", Z: "self" }[op.flags.Z]},
    .n = FlagBehavior.${{ "-": "__", 0: "_0", 1: "_1", N: "self" }[op.flags.N]},
    .h = FlagBehavior.${{ "-": "__", 0: "_0", 1: "_1", H: "self" }[op.flags.H]},
    .c = FlagBehavior.${{ "-": "__", 0: "_0", 1: "_1", C: "self" }[op.flags.C]},
  },
},
`;

const output = Object.entries(opcodes.cbprefixed).map(([op, code]) =>
  template(op, code)
);

console.log(output.join("\n"));
