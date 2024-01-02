const std = @import("std");
const Types = @import("./types/Types.zig");
const Vocabulary = Types.Vocabulary;
const Token = Types.Token;
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

pub fn parser(input: []const u8) ![]Token {
    var allocator = gpa.allocator();
    var tokens = std.ArrayList(Token).init(allocator);
    var input_splited = std.mem.splitAny(u8, input, " ");

    while(input_splited.next()) |word| {
        const token = tokenizer(word);
        tokens.append(token);
    }

    return tokens.toOwnedSlice();
}