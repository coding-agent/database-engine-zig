const std = @import("std");
const interpreter = @import("./interpreter.zig").interpreter;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    const args_allocator = gpa.allocator();
    const args = try std.process.argsAlloc(args_allocator);
    defer std.process.argsFree(args_allocator, args);
    //var arena = std.heap.ArenaAllocator.allocator();

    try interpreter(args[1..], .{});
}