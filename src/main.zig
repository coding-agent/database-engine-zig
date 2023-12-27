const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const createDatabase = @import("./file_management.zig").createDatabase;

pub fn main() !void {
    const args_allocator = gpa.allocator();
    const args = try std.process.argsAlloc(args_allocator);
    defer std.process.argsFree(args_allocator, args);

    _ = try createDatabase("new-db");
}