const _00 = @import("./cpu-00-bootrom.test.zig");
const _01 = @import("./cpu-01-special.test.zig");
const _02 = @import("./cpu-02-interrupts.test.zig");
const _03 = @import("./cpu-03-op sp,hl.test.zig");
const _04 = @import("./cpu-04-op r,imm.test.zig");
const _05 = @import("./cpu-05-op rp.test.zig");
const _06 = @import("./cpu-00-bootrom.test.zig");

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
    try _05.run();
}
