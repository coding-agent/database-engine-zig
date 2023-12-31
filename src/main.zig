const std = @import("std");
const interpreter = @import("./interpreter.zig").interpreter;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const Arena = std.heap.ArenaAllocator;

pub fn main() !void {
    var arena = Arena.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    const args = try std.process.argsAlloc(allocator);
    defer arena.deinit();
    defer std.process.argsFree(allocator, args);

    try interpreter(args[1..], allocator,.{});
}