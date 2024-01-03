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


pub const AstNode = struct {
    statement: Vocabulary,
    value: []const u8,
};

pub const Ast = struct {
    node: *AstNode,
    next: ?*Ast
};
