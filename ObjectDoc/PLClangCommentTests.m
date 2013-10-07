#import "PLClangTestCase.h"

@interface PLClangCommentTests : PLClangTestCase
@end

@implementation PLClangCommentTests

- (void) testSimpleComment {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @""
    "/** A function. */\n"
    "void f();"
    ];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    PLClangComment *comment = cursor.comment;
    XCTAssertNotNil(cursor, @"Cursor was not found");
    XCTAssertNotNil(comment, @"Cursor did not have a comment");

    XCTAssertEqualObjects(cursor.briefComment, @"A function.");

    XCTAssertEqual(comment.kind, PLClangCommentKindFullComment, @"Comment attached to declaration should have been a full comment");
    XCTAssertEqual(comment.renderKind, PLClangCommentRenderKindNormal, @"Comment should not have had any special render hint");
    XCTAssertNil(comment.commandName);
    XCTAssertNil(comment.arguments);
    XCTAssertFalse(comment.isParameterIndexValid);
    XCTAssertEqual(comment.parameterIndex, NSUIntegerMax, @"Comment should not have a parameter index");
    XCTAssertNil(comment.parameterName);
    XCTAssertNil(comment.paragraph);
    XCTAssertFalse(comment.isWhitespace);
    XCTAssertNil(comment.text);
    XCTAssertNotNil(comment.children);
    XCTAssertTrue([comment.children count] == 1, @"Comment should have a single paragraph child");

    PLClangComment *paragraph = comment.children[0];
    XCTAssertEqual(paragraph.kind, PLClangCommentKindParagraph, @"Child comment should have been a paragraph");
    XCTAssertFalse(paragraph.isWhitespace);
    XCTAssertNil(paragraph.text);
    XCTAssertNotNil(paragraph.children);
    XCTAssertTrue([paragraph.children count] == 1, @"Paragraph should have a single text child");

    PLClangComment *text = paragraph.children[0];
    XCTAssertEqual(text.kind, PLClangCommentKindText, @"Child comment should have been text");
    XCTAssertNil(text.children, @"Text should not have any children");
    XCTAssertFalse(text.isWhitespace);
    XCTAssertEqualObjects(text.text, @" A function. ");
}

- (void) testParamCommand {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @""
    "/**\n"
    " * A function.\n"
    " * @param p A parameter.\n"
    " * @param i Invalid.\n"
    " */\n"
    "void f(int p);"
    ];
    PLClangComment *comment = [[tu cursorWithSpelling: @"f"] comment];
    XCTAssertNotNil(comment, @"Comment was not found");
    XCTAssertTrue([comment.children count] == 3, @"Comment should have a paragraph and two parameters");

    PLClangComment *paragraph = comment.children[0];
    XCTAssertEqual(paragraph.kind, PLClangCommentKindParagraph, @"Child comment should have been a paragraph");

    PLClangComment *param = comment.children[1];
    XCTAssertEqual(param.kind, PLClangCommentKindParamCommand, @"Child comment should have been a @param command");
    XCTAssertEqualObjects(param.parameterName, @"p");
    XCTAssertTrue(param.isParameterIndexValid);
    XCTAssertTrue(param.parameterIndex == 0);

    param = comment.children[2];
    XCTAssertEqual(param.kind, PLClangCommentKindParamCommand, @"Child comment should have been a @param command");
    XCTAssertEqualObjects(param.parameterName, @"i");
    XCTAssertFalse(param.isParameterIndexValid);
    XCTAssertTrue(param.parameterIndex == NSUIntegerMax);
}

- (void) testInlineCommand {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @""
    "/** A @a function. */\n"
    "void f();"
    ];
    PLClangComment *comment = [[tu cursorWithSpelling: @"f"] comment];
    XCTAssertNotNil(comment, @"Comment was not found");
    XCTAssertTrue([comment.children count] == 1, @"Comment should have a paragraph");

    PLClangComment *paragraph = comment.children[0];
    XCTAssertEqual(paragraph.kind, PLClangCommentKindParagraph, @"Child comment should have been a paragraph");
    XCTAssertTrue([paragraph.children count] == 3, @"Paragraph should have a command and two text children");

    PLClangComment *text = paragraph.children[0];
    XCTAssertEqual(text.kind, PLClangCommentKindText, @"Child comment should have been text");
    XCTAssertFalse(text.isWhitespace);
    XCTAssertEqualObjects(text.text, @" A ");

    PLClangComment *command = paragraph.children[1];
    XCTAssertEqual(command.kind, PLClangCommentKindInlineCommand, @"Child comment should have been an inline command");
    XCTAssertEqualObjects(command.commandName, @"a");
    XCTAssertEqual(command.renderKind, PLClangCommentRenderKindEmphasized, @"Render kind should be emphasized");
    XCTAssertTrue([command.arguments count] == 1, @"Command should have one argument");
    XCTAssertEqualObjects(command.arguments[0], @"function.");

    text = paragraph.children[2];
    XCTAssertEqual(text.kind, PLClangCommentKindText, @"Child comment should have been text");
    XCTAssertTrue(text.isWhitespace);
    XCTAssertEqualObjects(text.text, @" ");
}

- (void) testHTMLTag {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @""
    "/** <a href=\"#anchor\">text</a> */\n"
    "void f();"
    ];
    PLClangComment *comment = [[tu cursorWithSpelling: @"f"] comment];
    XCTAssertNotNil(comment, @"Comment was not found");
    XCTAssertTrue([comment.children count] == 1, @"Comment should have a paragraph");

    PLClangComment *paragraph = comment.children[0];
    XCTAssertEqual(paragraph.kind, PLClangCommentKindParagraph, @"Child comment should have been a paragraph");
    XCTAssertTrue([paragraph.children count] == 5, @"Paragraph should have html start/end tags and three text children");

    PLClangComment *text = paragraph.children[0];
    XCTAssertEqual(text.kind, PLClangCommentKindText, @"Child comment should have been text");
    XCTAssertTrue(text.isWhitespace);
    XCTAssertEqualObjects(text.text, @" ");

    PLClangComment *tag = paragraph.children[1];
    XCTAssertEqual(tag.kind, PLClangCommentKindHTMLStartTag, @"Child comment should have been an HTML start tag");
    XCTAssertEqualObjects(tag.text, @"<a href=\"#anchor\">");

    text = paragraph.children[2];
    XCTAssertEqual(text.kind, PLClangCommentKindText, @"Child comment should have been text");
    XCTAssertFalse(text.isWhitespace);
    XCTAssertEqualObjects(text.text, @"text");

    tag = paragraph.children[3];
    XCTAssertEqual(tag.kind, PLClangCommentKindHTMLEndTag, @"Child comment should have been an HTML end tag");
    XCTAssertEqualObjects(tag.text, @"</a>");

    text = paragraph.children[4];
    XCTAssertEqual(text.kind, PLClangCommentKindText, @"Child comment should have been text");
    XCTAssertTrue(text.isWhitespace);
    XCTAssertEqualObjects(text.text, @" ");
}

- (void) testBlockCommand {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @""
    "/**\n"
    " * A function.\n"
    " * @note A note.\n"
    " */\n"
    "void f();"
    ];
    PLClangComment *comment = [[tu cursorWithSpelling: @"f"] comment];
    XCTAssertNotNil(comment, @"Comment was not found");
    XCTAssertTrue([comment.children count] == 2, @"Comment should have a paragraph and a block command");

    PLClangComment *paragraph = comment.children[0];
    XCTAssertEqual(paragraph.kind, PLClangCommentKindParagraph, @"Child comment should have been a paragraph");

    PLClangComment *command = comment.children[1];
    XCTAssertEqual(command.kind, PLClangCommentKindBlockCommand, @"Child comment should have been a block command");
    XCTAssertEqualObjects(command.commandName, @"note");
    XCTAssertNotNil(command.paragraph);
    XCTAssertEqual(command.paragraph.kind, PLClangCommentKindParagraph, @"Should have been a paragraph");
    XCTAssertNotNil(command.paragraph.children);
    XCTAssertTrue([command.paragraph.children count] > 0, @"Paragraph should not be empty");

    PLClangComment *text = command.paragraph.children[0];
    XCTAssertEqual(text.kind, PLClangCommentKindText, @"Child comment should have been text");
    XCTAssertFalse(text.isWhitespace);
    XCTAssertEqualObjects(text.text, @" A note.");
}

- (void) testVerbatimBlockCommand {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @""
    "/**\n"
    " * A function.\n"
    " * @code\n"
    " * t\n"
    " * @endcode\n"
    " */\n"
    "void f();"
    ];
    PLClangComment *comment = [[tu cursorWithSpelling: @"f"] comment];
    XCTAssertNotNil(comment, @"Comment was not found");
    XCTAssertTrue([comment.children count] == 3, @"Comment should have a two paragraphs and a verbatim block command");

    PLClangComment *paragraph = comment.children[0];
    XCTAssertEqual(paragraph.kind, PLClangCommentKindParagraph, @"Child comment should have been a paragraph");

    PLClangComment *command = comment.children[1];
    XCTAssertEqual(command.kind, PLClangCommentKindVerbatimBlockCommand, @"Child comment should have been a block command");
    XCTAssertEqualObjects(command.commandName, @"code");
    XCTAssertNil(command.paragraph);
    XCTAssertNotNil(command.children);
    XCTAssertTrue([command.children count] == 1, @"Command should have a verbatim block line child");

    PLClangComment *line = command.children[0];
    XCTAssertEqual(line.kind, PLClangCommentKindVerbatimBlockLine, @"Should have been a verbatim block line");
    XCTAssertEqualObjects(line.text, @" t");
}

@end
