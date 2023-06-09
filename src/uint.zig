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
        var t: struct { u64, u1 } = @addWithOverflow(y.c[i], @boolToInt(c));
        c = t[1] == 1;
        var tmp: struct { u64, u1 } = @addWithOverflow(t[0], z.c[i]);
        x.c[i] = tmp[0];
        var hoge: bool = if (tmp[1] == 0) false else true;
        c = c or hoge;
    }
    return c;
}

pub fn sub3(x: *uint, y: *uint, z: *uint) bool {
    var b: bool = false;
    var i: usize = 0;
    while (i < limbs) : (i += 1) {
        var t: struct { u64, u1 } = @subWithOverflow(y.c[i], @boolToInt(b));
        b = t[1] == 1;
        var tmp: struct { u64, u1 } = @subWithOverflow(t[0], z.c[i]);
        x.c[i] = tmp[0];
        var hoge: bool = if (tmp[1] == 0) false else true;
        b = b or hoge;
    }
    return b;
}

pub fn mul3_64(x: *uint, y: uint, z: u64) void {
    var c: u64 = 0;
    var i: usize = 0;
    while (i < limbs) : (i += 1) {
        var t: u128 = @intCast(u128, y.c[i]) * @intCast(u128, z) + c;
        c = @truncate(u64, t >> 64);
        x.c[i] = @truncate(u64, t);
    }
}

test "test uint_add3" {
    var x: uint = .{ .c = [_]u64{0} ** 64 };
    var y: uint = .{ .c = [_]u64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 } ** 4 };
    var z: uint = .{ .c = [_]u64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 } ** 4 };

    const overflow = add3(&x, &y, &z);

    try expectEqual(false, overflow);
    try expectEqual(x.c, [_]u64{ 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32 } ** 4);
}

test "test uint_sub3" {
    var x: uint = .{ .c = [_]u64{0} ** 64 };
    var y: uint = .{ .c = [_]u64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 } ** 4 };
    var z: uint = .{ .c = [_]u64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 } ** 4 };

    const overflow = sub3(&x, &y, &z);

    try expectEqual(false, overflow);
    try expectEqual(x.c, [_]u64{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } ** 4);
}

test "test mul3_64" {
    var x: uint = .{ .c = [_]u64{0} ** limbs };
    var y: uint = .{ .c = [_]u64{2} ** limbs };
    var z: u64 = 3;

    mul3_64(&x, y, z);

    var i: usize = 0;
    while (i < limbs) : (i += 1) {
        std.debug.assert(x.c[i] == 6);
    }
}
