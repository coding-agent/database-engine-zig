const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;
const Dir = fs.Dir;
const File = fs.File;

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = general_purpose_allocator.allocator();
    const args = try std.process.argsAlloc(gpa)[1..];
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    defer std.process.argsFree(gpa, args);
    Database("new-db");
}

fn Database(name: []const u8) !type {
    return struct {
        const Self = @This();
        const db_name = name;
        allocator: Allocator,
        tables: ?[]Table,
        dir: Dir,
        file: File,

        pub fn createDatabase() !Self {
            return Self {

            };
        }

        pub fn connect(allocator: Allocator, dir: Dir) !Self {
            return Self {
                .allocator = allocator,
                .dir = dir,
                .file = dir.openFile(name, .{
                    .mode = .read_write
                })
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

const ConnectOptions = struct {
    
};

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

//simple unserialized uuid
//TODO serialize UUID
fn newUUIDv4() UUID {
    var uuid = std.rand.Random.int(std.crypto.random, u128);
    uuid &= 0xffffffffffffff3fff0fffffffffffff;
    uuid |= 0x00000000000000800040000000000000;
    return uuid;
}

test "simple test" {
    var uuid = newUUIDv4();
    try std.testing.expect(@TypeOf(uuid) == u128);
}


