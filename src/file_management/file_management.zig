const std = @import("std");
const Types = @import("./Types.zig");
const fs = std.fs;
const Dir = fs.Dir;
const File = std.fs.File;
const Schema = Types.Schema;
const Table = Types.Table;
const Column = Types.Column;
const ColumnType = Types.ColumnType;
const Schema = Types.Schema;
const DatabaseFileOptions = Types.DatabaseFileOptions;
const Metadata = File.Metadata;
const Allocator = std.mem.Allocator;
const stringToEnum = std.meta.stringToEnum;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
std.ArrayList(Metadata),

pub fn DatabaseFile(name: []const u8) !type {
    return struct {
        const Self = @This();
        file: ?File,
        path: ?Dir,
        allocator: Allocator,

        //optionally can decide where to save the file
        //or find it in case of not in default cwd path
        pub fn init(allocator: Allocator, options: DatabaseFileOptions) !Self{
            const dir = try defaultDir(name);
            return Self {
                .file = options.file,
                .path = options.path,
                .allocator = allocator,
            };
        }

        pub fn createFile(self: *Self) !File {
            if (self.*.file) {
                return self.*.file;
            }

            var buff: [50]u8 = undefined;
            const cwd = fs.cwd();
            const file_format = ".json";
            const file_name = try std.fmt.bufPrint(&buff, "{s}{s}", .{name, file_format});
            var databaseDir = try defaultDir(name);
            var databaseFile = try databaseDir.createFile(file_name, .{});

            var initialContentObject = Database{
                .name = name,
                .tables = null
            };
            const content_string = try stringify(&initialContentObject, Self.*.allocator);

            _ = try databaseFile.write(content_string);
            return database;
        }

        fn defaultDir(name: []const u8) !Dir {
            const cwd = fs.cwd();
            const defaultDatabaseFolder = "database";
            var defaultDatabasesDir = try cwd.makeOpenPath(defaultDatabaseFolder, .{});
            var defaultDatabaseDir = try defaultDatabasesDir.makeOpenPath(name, .{});
            //var database = try defaultDatabaseDir.createFile(file_name, .{});
            return defaultDatabaseDir;
        }

        //name should include format
        pub fn getDatabase(self: *Self) ?File {
            return self.*.file.?;
        }

        pub fn deleteDatabase(self: *Self) !void{
            try self.*.path.?.deleteTree(name);
        }

        fn readFile(file: File, allocator: Allocator) ![]const u8{
            const content = file.readToEndAlloc(allocator, 5_000_000);
            return content;
        }

        fn toColumnType(input: ColumnType) !type {
            switch (input) {
                .string => []const u8,
                .integer => i32,
                .float => f64,
                .bool => bool,
                else => return error.unsupported_type
            }
        }
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


