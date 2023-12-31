const std = @import("std");
const fs = std.fs;
const Dir = fs.Dir;
const File = std.fs.File;
const Types = @import("./types/types.zig");
const Schema = Types.Schema;
const Table = Types.Table;
const Column = Types.Column;
const Database = Types.Database;
const Metadata = File.Metadata;
const Allocator = std.mem.Allocator;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const databaseFolder = "database";

fn createFile(name: []const u8, allocator: Allocator) !File{
    var buff: [50]u8 = undefined;
    const cwd = fs.cwd();

    const file_format = ".json";
    const file_name = try std.fmt.bufPrint(&buff, "{s}{s}", .{name, file_format});

    var databasesDir = try cwd.makeOpenPath(databaseFolder, .{});
    var databaseDir = try databasesDir.makeOpenPath(name, .{});
    var database = try databaseDir.createFile(file_name, .{});

    var initialContentObject = Database{
        .name = name,
        .tables = null
    };
    const contentstring = try stringify(&initialContentObject, allocator);

    _ = try database.write(contentstring);
    return database;
}

pub fn findFile(name: []const u8) !File {
    var buff: [50]u8 = undefined;
    const cwd = fs.cwd();

    const file_format = ".json";
    const file_name = try std.fmt.bufPrint(&buff, "{s}{s}", .{name, file_format});

    var databasesDir = try cwd.openDir(databaseFolder, .{});
    var databaseDir = try databasesDir.openDir(name, .{});

    return try databaseDir.openFile(file_name, .{.mode = .read_write});
}

pub fn createDatabase(name: []const u8, allocator: Allocator) !Schema{
    const database: File = try createFile(name, allocator);
    defer database.close();
    return Schema {
        .name = name,
        .file = database,
        .tables = undefined,
    };
}

pub fn deleteDatabase(name: []const u8) !void{
    const cwd = fs.cwd();
    var databasesDir = try cwd.makeOpenPath(databaseFolder, .{});
    try databasesDir.deleteTree(name);
}

pub fn createTable(name: []const u8, len: usize) !Table{
    return Table {
        .name = name,
        .index =  len + 1,
        .columns = null
    };
}

pub fn stringify(object: anytype, allocator: Allocator) ![]const u8 {
    var string = std.ArrayList(u8).init(allocator);
    try std.json.stringify(object.*, .{}, string.writer());
    return string.toOwnedSlice();
}

pub fn parseJSON(comptime T: type, file: File, allocator: Allocator) !T {
    const value = try readFile(file, allocator);
    const parsed = try std.json.parseFromSlice(
        T,
        allocator,
        value,
        .{},
    );
    return parsed.value;
}

fn readFile(file: File, allocator: Allocator) ![]const u8{
    const content = file.readToEndAlloc(allocator, 5_000_000);
    return content;
}