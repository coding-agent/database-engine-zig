const std = @import("std");
const Types = @import("./tokens.zig");
const Vocabulary = Types.Vocabulary;
const Token = Types.Token;
const Ast = Types.Ast;
const AstNode = Types.AstNode;
const Allocator = std.mem.Allocator;
const stringToEnum = std.meta.stringToEnum;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

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

pub fn parse(input: [][]const u8) ![]Token {
    var allocator = gpa.allocator();
    var tokens = std.ArrayList(Token).init(allocator);
    defer allocator.free(Token);

    for(input) |word| {
        const token = tokenizer(word);
        tokens.append(token);
    }

    return tokens.toOwnedSlice();
}