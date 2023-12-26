const std = @import("std");

const ColumnType = enum {
    u64,
    i64,
    f64,
    bool
};

pub const Column = struct {
    name: []const u8,
    columnType: ColumnType
};

pub const Table = struct {
    columns: []Column,
    file: std.fs.File
};

pub const Database = struct {
    tables: []Table,
};