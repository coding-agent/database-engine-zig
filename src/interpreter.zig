const std = @import("std");
const FileManagement = @import("./file_management.zig");
const Types = @import("./types/types.zig");
const Vocabulary = Types.Vocabulary;
const eql = std.mem.eql;
const stringToEnum = std.meta.stringToEnum;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const Options = struct { using: ?[]const u8 = null};

pub fn interpreter(args: [][]const u8, options: Options) !void {
    _ = options;
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

        .USE => {
            const databaseName = if(args.len > 1) args[1] else return std.debug.print("No Database Selected", .{});
            var buff: [50]u8 = undefined;
            const stdin = std.io.getStdIn().reader();
            std.debug.print("what is your query?\n", .{});
            const in = try stdin.readUntilDelimiter(&buff, '\n');
            

            var input_list = std.ArrayList([]const u8).init(gpa.allocator());

            var input_splited = std.mem.splitAny(u8, in, " ");
            while (input_splited.next()) |word| {
                if (word[0] == ' ') continue;
                try input_list.append(word);
            }
            try interpreter(try input_list.toOwnedSlice(), .{.using = databaseName});
        },

        .EXIT => return,

        else => std.debug.print("Unhandled statement: {s}", .{args[0]}),
    }
}