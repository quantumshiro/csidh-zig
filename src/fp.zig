const std = @import("std");
const testing = std.testing;
const params = @import("params.zig");
const uint = @import("uint.zig");
const rng = @import("rng.zig");
const constants = @import("constants.zig");

pub fn reduce_once(x: *params.uint) void {
    var t: params.uint = undefined;
    var p_copy: params.uint = constants.p;
    if (!uint.sub3(&t, x, &p_copy)) {
        x.* = t;
    }
}

pub fn add3(x: *params.fp, y: *params.fp, z: *params.fp) void {
    uint.add3(@ptrCast(*params.uint, x), @ptrCast(*params.uint, y), @ptrCast(*params.uint, z));
    reduce_once(@ptrCast(*params.uint, x));
}

test "test_reduce_once" {
    var x: params.uint = .{ .c = [_]u64{constants.p.c[0] + 10} ** 64 };
    std.debug.print("Before: x.c[0] = {}\n", .{x.c[0]});
    reduce_once(&x);
    std.debug.print("After: x.c[0] = {}\n", .{x.c[0]});
    try testing.expectEqual(x.c[0], 10);
}
