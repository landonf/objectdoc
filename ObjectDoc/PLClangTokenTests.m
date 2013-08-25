#import "PLClangTestCase.h"

@interface PLClangTokenTests : PLClangTestCase
@end

@implementation PLClangTokenTests

- (void) testTokenization {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t = 1;"];
    NSArray *tokens = [tu tokensForSourceRange: tu.cursor.extent];
    STAssertNotNil(tokens, @"Failed to create tokens array");
    STAssertEquals([tokens count], (NSUInteger)5, @"Source range should contain 5 tokens");

    PLClangToken *token = tokens[0];
    STAssertEquals(token.kind, PLClangTokenKindKeyword, @"Token should be the int keyword");
    STAssertEqualObjects(token.spelling, @"int", nil);
    STAssertEquals(token.location.fileOffset, (off_t)0, nil);
    STAssertEquals(token.extent.startLocation.fileOffset, (off_t)0, nil);
    STAssertEquals(token.extent.endLocation.fileOffset, (off_t)3, nil);
    STAssertEquals(token.cursor.kind, PLClangCursorKindVariableDeclaration, @"Token should be part of represent a variable definition");

    token = tokens[1];
    STAssertEquals(token.kind, PLClangTokenKindIdentifier, @"Token should be the t identifier");
    STAssertEqualObjects(token.spelling, @"t", nil);
    STAssertEquals(token.location.fileOffset, (off_t)4, nil);
    STAssertEquals(token.extent.startLocation.fileOffset, (off_t)4, nil);
    STAssertEquals(token.extent.endLocation.fileOffset, (off_t)5, nil);
    STAssertEquals(token.cursor.kind, PLClangCursorKindVariableDeclaration, @"Token should be part of represent a variable definition");

    token = tokens[2];
    STAssertEquals(token.kind, PLClangTokenKindPunctuation, @"Token should be the assignement operator");
    STAssertEqualObjects(token.spelling, @"=", nil);
    STAssertEquals(token.location.fileOffset, (off_t)6, nil);
    STAssertEquals(token.extent.startLocation.fileOffset, (off_t)6, nil);
    STAssertEquals(token.extent.endLocation.fileOffset, (off_t)7, nil);
    STAssertEquals(token.cursor.kind, PLClangCursorKindVariableDeclaration, @"Token should be part of represent a variable definition");

    token = tokens[3];
    STAssertEquals(token.kind, PLClangTokenKindLiteral, @"Token should be the numeric literal");
    STAssertEqualObjects(token.spelling, @"1", nil);
    STAssertEquals(token.location.fileOffset, (off_t)8, nil);
    STAssertEquals(token.extent.startLocation.fileOffset, (off_t)8, nil);
    STAssertEquals(token.extent.endLocation.fileOffset, (off_t)9, nil);
    STAssertEquals(token.cursor.kind, PLClangCursorKindIntegerLiteral, @"Token should be the integer literal");

    token = tokens[4];
    STAssertEquals(token.kind, PLClangTokenKindPunctuation, @"Token should be the semicolon");
    STAssertEqualObjects(token.spelling, @";", nil);
    STAssertEquals(token.location.fileOffset, (off_t)9, nil);
    STAssertEquals(token.extent.startLocation.fileOffset, (off_t)9, nil);
    STAssertEquals(token.extent.endLocation.fileOffset, (off_t)10, nil);
    STAssertNil(token.cursor, @"Semicolon should not have a cursor");
}

- (void) testComment {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"/** A comment. */\n"];
    NSArray *tokens = [tu tokensForSourceRange: tu.cursor.extent];
    STAssertNotNil(tokens, @"Failed to create tokens array");
    STAssertEquals([tokens count], (NSUInteger)1, @"Source range should contain 1 tokens");

    PLClangToken *token = tokens[0];
    STAssertEquals(token.kind, PLClangTokenKindComment, @"Token should be a comment");
    STAssertEqualObjects(token.spelling, @"/** A comment. */", nil);
    STAssertEquals(token.location.fileOffset, (off_t)0, nil);
    STAssertEquals(token.extent.startLocation.fileOffset, (off_t)0, nil);
    STAssertEquals(token.extent.endLocation.fileOffset, (off_t)17, nil);
    STAssertNil(token.cursor, @"Comment should not have a cursor");
}

@end
