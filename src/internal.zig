const std = @import("std");
const fs = std.fs;
const Dir = fs.Dir;
const File = std.fs.File;
const Types = @import("./types/types.zig");
const Schema = Types.Schema;

fn createDir(name: []const u8)!Dir{
    const cwd = fs.cwd();
    var databasesDir = try cwd.makeOpenPath("databases", .{});
    var databaseDir = try databasesDir.makeOpenPath(name, .{});
    return databaseDir;
}

pub fn createDatabase(name: []const u8) !void{
    var databaseDir = try createDir(name);
    var database: File = try databaseDir.createFile(name, .{});
    defer database.close();
}