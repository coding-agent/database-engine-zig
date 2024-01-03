const std = @import("std");

pub const ColumnType = enum {
    string,
    integer,
    float,
    bool,
};

//const ForeignKey = struct {
//    tableIndex: usize,
//    reference: []const u8,
//};

pub const Column = struct {
    index: usize,
    name: []const u8,
    columnType: ColumnType,
};

pub const Table = struct {
    index: usize,
    name: []const u8,
    columns: ?[]Column,
};

pub const Schema = struct {
    name: []const u8,
    tables: []Table,
    file: std.fs.File
};

pub const Database = struct {
    name: []const u8,
    tables: ?[]Table,
};

pub const Vocabulary = enum {
    CREATE,
    DROP,
    USE,
    SELECT,
    DELETE,
    ALTER,
    VALUE,
    EXIT,
};

pub const Token = struct {
    keyword: Vocabulary,
    value: ?[]const u8
};

