const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    const args_allocator = gpa.allocator();
    const args = try std.process.argsAlloc(args_allocator);
    defer std.process.argsFree(args_allocator, args);

    std.debug.print("", .{});
}