#import "PLClangTestCase.h"

@interface PLClangTokenTests : PLClangTestCase
@end

@implementation PLClangTokenTests

- (void) testTokenization {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t = 1;"];
    NSArray *tokens = [tu tokensForSourceRange: tu.cursor.extent];
    XCTAssertNotNil(tokens, @"Failed to create tokens array");
    XCTAssertEqual([tokens count], (NSUInteger)5, @"Source range should contain 5 tokens");

    PLClangToken *token = tokens[0];
    XCTAssertEqual(token.kind, PLClangTokenKindKeyword, @"Token should be the int keyword");
    XCTAssertEqualObjects(token.spelling, @"int");
    XCTAssertEqual(token.location.fileOffset, (off_t)0);
    XCTAssertEqual(token.extent.startLocation.fileOffset, (off_t)0);
    XCTAssertEqual(token.extent.endLocation.fileOffset, (off_t)3);
    XCTAssertEqual(token.cursor.kind, PLClangCursorKindVariableDeclaration, @"Token should be part of represent a variable definition");

    token = tokens[1];
    XCTAssertEqual(token.kind, PLClangTokenKindIdentifier, @"Token should be the t identifier");
    XCTAssertEqualObjects(token.spelling, @"t");
    XCTAssertEqual(token.location.fileOffset, (off_t)4);
    XCTAssertEqual(token.extent.startLocation.fileOffset, (off_t)4);
    XCTAssertEqual(token.extent.endLocation.fileOffset, (off_t)5);
    XCTAssertEqual(token.cursor.kind, PLClangCursorKindVariableDeclaration, @"Token should be part of represent a variable definition");

    token = tokens[2];
    XCTAssertEqual(token.kind, PLClangTokenKindPunctuation, @"Token should be the assignement operator");
    XCTAssertEqualObjects(token.spelling, @"=");
    XCTAssertEqual(token.location.fileOffset, (off_t)6);
    XCTAssertEqual(token.extent.startLocation.fileOffset, (off_t)6);
    XCTAssertEqual(token.extent.endLocation.fileOffset, (off_t)7);
    XCTAssertEqual(token.cursor.kind, PLClangCursorKindVariableDeclaration, @"Token should be part of represent a variable definition");

    token = tokens[3];
    XCTAssertEqual(token.kind, PLClangTokenKindLiteral, @"Token should be the numeric literal");
    XCTAssertEqualObjects(token.spelling, @"1");
    XCTAssertEqual(token.location.fileOffset, (off_t)8);
    XCTAssertEqual(token.extent.startLocation.fileOffset, (off_t)8);
    XCTAssertEqual(token.extent.endLocation.fileOffset, (off_t)9);
    XCTAssertEqual(token.cursor.kind, PLClangCursorKindIntegerLiteral, @"Token should be the integer literal");

    token = tokens[4];
    XCTAssertEqual(token.kind, PLClangTokenKindPunctuation, @"Token should be the semicolon");
    XCTAssertEqualObjects(token.spelling, @";");
    XCTAssertEqual(token.location.fileOffset, (off_t)9);
    XCTAssertEqual(token.extent.startLocation.fileOffset, (off_t)9);
    XCTAssertEqual(token.extent.endLocation.fileOffset, (off_t)10);
    XCTAssertNil(token.cursor, @"Semicolon should not have a cursor");
}

- (void) testComment {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"/** A comment. */\n"];
    NSArray *tokens = [tu tokensForSourceRange: tu.cursor.extent];
    XCTAssertNotNil(tokens, @"Failed to create tokens array");
    XCTAssertEqual([tokens count], (NSUInteger)1, @"Source range should contain 1 tokens");

    PLClangToken *token = tokens[0];
    XCTAssertEqual(token.kind, PLClangTokenKindComment, @"Token should be a comment");
    XCTAssertEqualObjects(token.spelling, @"/** A comment. */");
    XCTAssertEqual(token.location.fileOffset, (off_t)0);
    XCTAssertEqual(token.extent.startLocation.fileOffset, (off_t)0);
    XCTAssertEqual(token.extent.endLocation.fileOffset, (off_t)17);
    XCTAssertNil(token.cursor, @"Comment should not have a cursor");
}

@end
