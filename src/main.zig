const std = @import("std");
const interpreter = @import("./interpreter.zig").interpreter;
const lexer = @import("./lexer.zig");
const Arena = std.heap.ArenaAllocator;

pub fn main() !void {
    var arena = Arena.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    _ = allocator;
    defer arena.deinit();

    const input = try lexer.parser("", allocator);
    const parsed_input = try lexer.

    //try interpreter(input[1..], allocator,.{});
}