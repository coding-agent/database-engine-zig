const std = @import("std");
const FileManagement = @import("./file_management.zig");
const Types = @import("./types/types.zig");
const Table = Types.Table;
const Column = Types.Column;
const Database = Types.Database;
const Vocabulary = Types.Vocabulary;
const eql = std.mem.eql;
const stringToEnum = std.meta.stringToEnum;
const Options = struct { db: ?[]const u8 = null, file: ?*std.fs.File = null };
const Allocator = std.mem.Allocator;

pub fn interpreter(args: [][]const u8, allocator: Allocator, options: Options) !void {
    const statement1 = stringToEnum(Vocabulary, args[0]) orelse return std.debug.print("Unknown Statement '{s}'", .{args[0]});
    switch (statement1) {
        .CREATE => {
            const statement2 = args[1];

            if (eql(u8, statement2, "DATABASE")) {
                const schema = try FileManagement.createDatabase(args[2], allocator);
                std.debug.print("Created new Schema: {s}\n", .{schema.name});
            }

            if (eql(u8, statement2, "TABLE")) {
                var file = options.file orelse return std.debug.print("No database Selected", .{});
                defer file.*.close();

                var database = try FileManagement.parseJSON(Database, file.*, allocator);
                const tables_length = if(database.tables) |val| val.len else 0;
                const tables = database.tables.?;
                for(tables) |table| {
                    if(eql(u8, args[2], table.name)) return std.debug.print("Table already exists!", .{});
                }
                var table = try FileManagement.createTable(args[2], tables_length);

                //append tables to database
                var new_tables = try allocator.alloc(Table, tables_length+1);
                if(database.tables) |file_tables|
                    for (file_tables, 0..) |file_table, j| {
                    new_tables[j] = file_table;
                };
                new_tables[tables_length] = table;
                database.tables = new_tables;

                const string = try FileManagement.stringify(&database, allocator);
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
            var buff: [100]u8 = undefined;
            const stdin = std.io.getStdIn().reader();
            const in = try stdin.readUntilDelimiter(&buff, '\n');

            var input_list = std.ArrayList([]const u8).init(allocator);

            var input_splited = std.mem.splitAny(u8, in[0..in.len-1], " ");
            while (input_splited.next()) |word| {
                if (word[0] == ' ') continue;
                try input_list.append(word);
            }
            try interpreter(try input_list.toOwnedSlice(), allocator,.{.db = databaseName, .file = &file});
        },

        .SELECT => {
            var file = options.file orelse return std.debug.print("No database Selected", .{});
            var database = try FileManagement.parseJSON(Database, file.*, allocator);
            if(database.tables == null) return std.debug.print("No tables in the Database", .{});
        },

        .ALTER => {
            if(!eql(u8, args[1], "TABLE")) return std.debug.print("Unkown statement: Alter", .{args[1]});
            

        },

        .EXIT => return,

        else => return std.debug.print("Unhandled statement: {s}", .{args[0]})
    }
}