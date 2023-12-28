const std = @import("std");
const FileManagement = @import("./file_management.zig");
const Types = @import("./types/types.zig");
const Vocabulary = Types.Vocabulary;
const createDatabase = FileManagement.createDatabase;
const eql = std.mem.eql;
const stringToEnum = std.meta.stringToEnum;

pub fn interpreter(args: [][]const u8) !void {
    const statement1 = stringToEnum(Vocabulary, args[0]) orelse return std.debug.print("Cannot be empty", .{});
    switch (statement1) {
        .CREATE => {
            const schema = try createDatabase(args[1]);
            std.debug.print("Created new Schema:\n {any}", .{schema});
        },

        .DROP  => {
            //TODO DELETE DATABASE
        },

        else => {}
    }
}