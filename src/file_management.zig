const std = @import("std");
const fs = std.fs;
const Dir = fs.Dir;
const File = std.fs.File;
const Types = @import("./types/types.zig");
const Schema = Types.Schema;
const Table = Types.Table;
const Column = Types.Column;
const Database = Types.Database;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

fn createFile(name: []const u8) !File{
    var buff: [50]u8 = undefined;
    const cwd = fs.cwd();

    const file_format = ".json";
    const file_name = try std.fmt.bufPrint(&buff, "{s}{s}", .{name, file_format});

    var databasesDir = try cwd.makeOpenPath("databases", .{});
    var databaseDir = try databasesDir.makeOpenPath(name, .{});
    var database = try databaseDir.createFile(file_name, .{});

    var initialContentObject = Database{
        .name = name,
        .tables = null
    };
    const contentstring = try stringify(&initialContentObject, 500);

    _ = try database.write(contentstring);
    return database;
}

pub fn createDatabase(name: []const u8) !Schema{
    const database: File = try createFile(name);
    defer database.close();
    return Schema {
        .name = name,
        .file = database,
        .tables = undefined,
    };
}

pub fn deleteDatabase(name: []const u8) !void{
    var buff: [50]u8 = undefined;
    const cwd = fs.cwd();

    const file_format = ".json";
    const file_name = try std.fmt.bufPrint(&buff, "{s}{s}", .{name, file_format});
    _ = file_name;

    var databasesDir = try cwd.makeOpenPath("databases", .{});
    try databasesDir.deleteTree(name);
}

pub fn createTable(database: Schema, name: []const u8) !void{
    const table = Table {
        .name = name,
        .index = database.tables.len+1,
        .columns = undefined
    };
    _ = table;

    database.file.write();
}

fn selectTable(databaseName: []const u8, table: []const u8) !void {

    _ = table;
    _ = databaseName;
}

fn stringify(object: anytype, comptime size: usize) ![]const u8 {
    var buf: [size]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var string = std.ArrayList(u8).init(fba.allocator());
    
    try std.json.stringify(object.*, .{}, string.writer());
    return string.toOwnedSlice();
}