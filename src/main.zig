const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const createDatabase = @import("./internal.zig").createDatabase;

pub fn main() !void {
    const args_allocator = gpa.allocator();
    const args = try std.process.argsAlloc(args_allocator);
    defer std.process.argsFree(args_allocator, args);

    try createDatabase("new-db");
}