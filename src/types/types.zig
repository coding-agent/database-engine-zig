const std = @import("std");

const ColumnType = enum {
    u64,
    i64,
    f64,
    bool
};

const ForeignKey = struct {
    tableIndex: usize,
    columnIndex: usize,
};

pub const Column = struct {
    index: usize,
    name: []const u8,
    columnType: ColumnType,
    foreignKey: ?ForeignKey
};

pub const Table = struct {
    index: usize,
    name: []const u8,
    columns: []Column,
};

pub const Schema = struct {
    name: []const u8,
    tables: []Table,
    file: std.fs.File
};

pub const Buffer = struct {
    const Self = @This();
    pub const Error = std.mem.Allocator.Error;
};