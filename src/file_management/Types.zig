const std = @import("std");
const Dir = std.fs.Dir;
const File = std.fs.File;

pub const DatabaseFileOptions = struct{
    path:?Dir,
    file:?File
};