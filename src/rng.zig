const std = @import("std");

pub fn randombytes(buffer: []u8) !void {
    std.crypto.random.bytes(buffer);
}

test "test randombytes" {
    var buffer: [10]u8 = undefined;
    try randombytes(buffer[0..]);
    std.debug.print("{any}", .{buffer});
}
