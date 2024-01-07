const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;
const Dir = fs.Dir;
const File = fs.File;

pub fn main() !void {
}

fn Database(name: []const u8) !type {

    return struct {
        const Self = @This();
        const db_name = name;
        allocator: Allocator,
        tables: ?[]Table,
        dir: Dir,

        pub fn connect(allocator: Allocator) !Self {
            return Self {
                .allocator = allocator
            };
        }

        pub fn disconnect(self: *Self) void{
            _ = self;
        }

        pub fn executeQuery(query: []const u8) !Database{
            _ = query;
        }
    };
}

const Table = struct {
    id: UUID,
    name: []const u8,
    column: []Column,
};

const Column = struct {
    index: u8,
    name: []const u8,
    ColumnType: type,
    pk: bool,
    references: ?UUID,
};

const UUID = u128;

fn newUUIDv4() !UUID {
    var uuid = std.rand.Random.int(u128);
    uuid &= 0xffffffffffffff3fff0fffffffffffff;
    uuid |= 0x00000000000000800040000000000000;
    return uuid;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
