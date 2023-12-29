const std = @import("std");
const FileManagement = @import("./file_management.zig");
const Types = @import("./types/types.zig");
const Vocabulary = Types.Vocabulary;
const eql = std.mem.eql;
const stringToEnum = std.meta.stringToEnum;

pub fn interpreter(args: [][]const u8) !void {
    const statement1 = stringToEnum(Vocabulary, args[0]) orelse return std.debug.print("Unknown Statement '{s}'", .{args[0]});
    switch (statement1) {
        .CREATE => {
            const schema = try FileManagement.createDatabase(args[1]);
            std.debug.print("Created new Schema: {s}\n", .{schema.name});
        },

        .DROP => {
            try FileManagement.deleteDatabase(args[1]);
            std.debug.print("Deleted Schema: {s}\n", .{args[1]});

        },

        else => std.debug.print("Unhandled statement: {s}", .{args[0]}),
    }
}