const std = @import("std");
const Types = @import("./tokens.zig");
const Vocabulary = Types.Vocabulary;
const Token = Types.Token;
const Ast = Types.Ast;
const AstNode = Types.AstNode;
const Allocator = std.mem.Allocator;
const stringToEnum = std.meta.stringToEnum;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

fn allocate(comptime T: type, allocator: Allocator) !*T{
    return allocator.create(T);
}

fn tokenizer(word: []const u8) Token {
    const statement = stringToEnum(Vocabulary, word) orelse return Token {
        .keyword = .VALUE,
        .value = word,
    };

    return Token {
        .keyword = statement,
        .value = null,
    };
}

fn parse(input: [][]const u8) ![]Token {
    var allocator = gpa.allocator();
    var tokens = std.ArrayList(Token).init(allocator);
    defer allocator.free(Token);

    for(input) |word| {
        const token = tokenizer(word);
        tokens.append(token);
    }

    return tokens.toOwnedSlice();
}

fn ast_recursive(tokens: []Token, ast: *Ast, allocator: Allocator) !Ast {
    const curr_token = tokens[0];
    try switch (curr_token.keyword) {
        .VALUE => {

            var node = try allocate(AstNode, allocator);

            node.*.statement = curr_token.keyword;
            node.*.value = true;

            return ast.*;
        },

        .SELECT, .USE => {
            var node = try allocate(AstNode, allocator);

            node.*.statement = curr_token.keyword;
            node.*.value = tokens[1];

            node.*.statement = curr_token.keyword;
            node.*.value = try ast_recursive(tokens[1..], &ast , allocator);

            return ;
        },

        else => {}
    };
}

pub fn buildAST(input: [][]const u8, allocator: Allocator) !Ast {
    const tokens = try parse(input);

    var initial_ast = allocate(Ast, allocator);

    const ast = try ast_recursive(tokens, &initial_ast, allocator);

    return ast;
}