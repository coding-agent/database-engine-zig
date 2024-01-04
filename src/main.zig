const std = @import("std");
const interpreter = @import("./interpreter.zig").interpreter;
const Parser = @import("./parser/parser.zig");
const Arena = std.heap.ArenaAllocator;

pub fn main() !void {
    var arena = Arena.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    const args = try std.process.argsAlloc(allocator);
    const input = args[1..];
    defer arena.deinit();

    const parsed_input = try Parser.parse(input);
    try interpreter(parsed_input, allocator, .{});
}

test "input" {
    try std.testing.expect(true);
}