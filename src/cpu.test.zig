const _00 = @import("./cpu-00-bootrom.test.zig");
const _01 = @import("./cpu-01-special.test.zig");
const _02 = @import("./cpu-02-interrupts.test.zig");
const _03 = @import("./cpu-03-op sp,hl.test.zig");
const _04 = @import("./cpu-04-op r,imm.test.zig");
const _05 = @import("./cpu-05-op rp.test.zig");
const _06 = @import("./cpu-00-bootrom.test.zig");
const _07 = @import("./cpu-07-jr,jp,call,ret,rst.test.zig");
const _08 = @import("./cpu-08-misc instrs.test.zig");
const _09 = @import("./cpu-09-op r,r.test.zig");
const _10 = @import("./cpu-10-bit ops.test.zig");
const _11 = @import("./cpu-11-op a,(hl).test.zig");

test "00-bootrom" {
    try _00.run();
}

test "01-special" {
    try _01.run();
}

test "02-interrupts" {
    try _02.run();
}

test "03-op sp,hl" {
    try _03.run();
}

test "04-op r,imm" {
    try _04.run();
}

test "05-op rp" {
    try _05.run();
}

test "06-ld r,r" {
    try _06.run();
}

test "07-jr,jp,call,ret,rst" {
    try _07.run();
}

test "08-misc instrs" {
    try _08.run();
}

test "09-op r,r" {
    try _09.run();
}

test "10-bit ops" {
    try _10.run();
}

test "11-op a,(hl)" {
    try _11.run();
}
