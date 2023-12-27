const std = @import("std");
const fs = std.fs;
const Dir = fs.Dir;
const File = std.fs.File;
const Types = @import("./types/types.zig");
const Schema = Types.Schema;
const Table = Types.Table;
const Column = Types.Column;

fn createFile(name: []const u8) !File{
    var buff: [50]u8 = undefined;
    const cwd = fs.cwd();

    const file_format = ".json";
    const file_name = try std.fmt.bufPrint(&buff, "{s}{s}", .{name, file_format});

    var databasesDir = try cwd.makeOpenPath("databases", .{});
    var databaseDir = try databasesDir.makeOpenPath(name, .{});
    var database = try databaseDir.createFile(file_name, .{});

    _ = std.json.writeStream(database, .{});
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