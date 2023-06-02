const std = @import("std");
const testing = std.testing;
const assert = testing.assert;
const expectEqual = testing.expectEqual;
const uint = @import("params.zig").uint;
const limbs = @import("params.zig").LIMBS;

const one: uint = .{ .c = [_]u64{1} };

pub fn set(x: *uint, y: u64) void {
    x.c[0] = y;
    var i: usize = 1;
    while (i < limbs) : (i += 1) {
        x.c[i] = 0;
    }
}

pub fn bit(x: *uint, k: u64) bool {
    return 1 & (x.c[k / 64] >> (k % 64));
}

pub fn add3(x: *uint, y: *uint, z: *uint) bool {
    var c: bool = false;
    var i: usize = 0;
    while (i < limbs) : (i += 1) {
        var t: u64 = undefined;
        c = @addWithOverflow(u64, y.c[i], @boolToInt(c), &t);
        c = c or @addWithOverflow(u64, t, z.c[i], &x.c[i]);
    }
    return c;
}

test "uint_add3" {
    var x: uint = .{ .c = [_]u64{0} ** 64 };
    var y: uint = .{ .c = [_]u64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 } ** 4 };
    var z: uint = .{ .c = [_]u64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 } ** 4 };

    const overflow = add3(&x, &y, &z);

    try expectEqual(false, overflow);
    try expectEqual(x.c, [_]u64{ 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32 } ** 4);
}
