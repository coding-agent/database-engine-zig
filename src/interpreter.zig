const std = @import("std");
const FileManagement = @import("./file_management.zig");
const Types = @import("./types/types.zig");
const Vocabulary = Types.Vocabulary;
const eql = std.mem.eql;
const stringToEnum = std.meta.stringToEnum;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const Options = struct { db: ?[]const u8 = null, file: ?*std.fs.File = null };

pub fn interpreter(args: [][]const u8, options: Options) !void {
    const statement1 = stringToEnum(Vocabulary, args[0]) orelse return std.debug.print("Unknown Statement '{s}'", .{args[0]});
    switch (statement1) {
        .CREATE => {
            const statement2 = args[1];

            if (eql(u8, statement2, "DATABASE")) {
                const schema = try FileManagement.createDatabase(args[2]);
                std.debug.print("Created new Schema: {s}\n", .{schema.name});
            }

            if (eql(u8, statement2, "TABLE")) {
                var file = options.file orelse return std.debug.print("No database Selected", .{});
                var database = try FileManagement.parseJSON(Types.Database, file.*);
                const tables_length = if(database.tables) |val| val.len else 0;
                defer file.*.close();
                var table = try  FileManagement.createTable(args[2], tables_length);

                //append table
                var tables = try gpa.allocator().alloc(Types.Table, tables_length+1);
                if(database.tables) |database_tables| for (database_tables, 0..) |each_table, i| {
                    tables[i] = each_table;
                };
                tables[tables_length] = table;
                database.tables = tables;
                const string = try FileManagement.stringify(&database);
                try file.seekTo(0);
                try file.*.writeAll(string);
            }
        },

        .DROP => {
            try FileManagement.deleteDatabase(args[1]);
            std.debug.print("Deleted Schema: {s}\n", .{args[1]});
        },

        .USE => {
            const databaseName = if(args.len > 1) args[1] else return std.debug.print("No Database Selected", .{});
            var file = FileManagement.findFile(databaseName) catch return std.debug.print("No Database found", .{});

            std.debug.print("Using: {s}\n", .{databaseName});
            var buff: [50]u8 = undefined;
            const stdin = std.io.getStdIn().reader();
            const in = try stdin.readUntilDelimiter(&buff, '\n');

            var input_list = std.ArrayList([]const u8).init(gpa.allocator());

            var input_splited = std.mem.splitAny(u8, in[0..in.len-1], " ");
            while (input_splited.next()) |word| {
                if (word[0] == ' ') continue;
                try input_list.append(word);
            }
            try interpreter(try input_list.toOwnedSlice(), .{.db = databaseName, .file = &file});
        },

        .SELECT => {
            var file = options.file orelse return std.debug.print("No database Selected", .{});
            var database = try FileManagement.parseJSON(Types.Database, file.*);
            if(database.tables == null) return std.debug.print("No tables in the Database", .{});
            
        },

        .EXIT => return,

        else => return std.debug.print("Unhandled statement: {s}", .{args[0]})
    }
}