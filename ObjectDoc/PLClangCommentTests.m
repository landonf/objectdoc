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
    STAssertNotNil(cursor, @"Cursor was not found");
    STAssertNotNil(comment, @"Cursor did not have a comment");

    STAssertEqualObjects(cursor.briefComment, @"A function.", nil);

    STAssertEquals(comment.kind, PLClangCommentKindFullComment, @"Comment attached to declaration should have been a full comment");
    STAssertEquals(comment.renderKind, PLClangCommentRenderKindNormal, @"Comment should not have had any special render hint");
    STAssertNil(comment.commandName, nil);
    STAssertNil(comment.arguments, nil);
    STAssertFalse(comment.isParameterIndexValid, nil);
    STAssertEquals(comment.parameterIndex, NSUIntegerMax, @"Comment should not have a parameter index");
    STAssertNil(comment.parameterName, nil);
    STAssertNil(comment.paragraph, nil);
    STAssertFalse(comment.isWhitespace, nil);
    STAssertNil(comment.text, nil);
    STAssertNotNil(comment.children, nil);
    STAssertTrue([comment.children count] == 1, @"Comment should have a single paragraph child");

    PLClangComment *paragraph = comment.children[0];
    STAssertEquals(paragraph.kind, PLClangCommentKindParagraph, @"Child comment should have been a paragraph");
    STAssertFalse(paragraph.isWhitespace, nil);
    STAssertNil(paragraph.text, nil);
    STAssertNotNil(paragraph.children, nil);
    STAssertTrue([paragraph.children count] == 1, @"Paragraph should have a single text child");

    PLClangComment *text = paragraph.children[0];
    STAssertEquals(text.kind, PLClangCommentKindText, @"Child comment should have been text");
    STAssertNil(text.children, @"Text should not have any children");
    STAssertFalse(text.isWhitespace, nil);
    STAssertEqualObjects(text.text, @" A function. ", nil);
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
    STAssertNotNil(comment, @"Comment was not found");
    STAssertTrue([comment.children count] == 3, @"Comment should have a paragraph and two parameters");

    PLClangComment *paragraph = comment.children[0];
    STAssertEquals(paragraph.kind, PLClangCommentKindParagraph, @"Child comment should have been a paragraph");

    PLClangComment *param = comment.children[1];
    STAssertEquals(param.kind, PLClangCommentKindParamCommand, @"Child comment should have been a @param command");
    STAssertEqualObjects(param.parameterName, @"p", nil);
    STAssertTrue(param.isParameterIndexValid, nil);
    STAssertTrue(param.parameterIndex == 0, nil);

    param = comment.children[2];
    STAssertEquals(param.kind, PLClangCommentKindParamCommand, @"Child comment should have been a @param command");
    STAssertEqualObjects(param.parameterName, @"i", nil);
    STAssertFalse(param.isParameterIndexValid, nil);
    STAssertTrue(param.parameterIndex == NSUIntegerMax, nil);
}

- (void) testInlineCommand {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @""
    "/** A @a function. */\n"
    "void f();"
    ];
    PLClangComment *comment = [[tu cursorWithSpelling: @"f"] comment];
    STAssertNotNil(comment, @"Comment was not found");
    STAssertTrue([comment.children count] == 1, @"Comment should have a paragraph");

    PLClangComment *paragraph = comment.children[0];
    STAssertEquals(paragraph.kind, PLClangCommentKindParagraph, @"Child comment should have been a paragraph");
    STAssertTrue([paragraph.children count] == 3, @"Paragraph should have a command and two text children");

    PLClangComment *text = paragraph.children[0];
    STAssertEquals(text.kind, PLClangCommentKindText, @"Child comment should have been text");
    STAssertFalse(text.isWhitespace, nil);
    STAssertEqualObjects(text.text, @" A ", nil);

    PLClangComment *command = paragraph.children[1];
    STAssertEquals(command.kind, PLClangCommentKindInlineCommand, @"Child comment should have been an inline command");
    STAssertEqualObjects(command.commandName, @"a", nil);
    STAssertEquals(command.renderKind, PLClangCommentRenderKindEmphasized, @"Render kind should be emphasized");
    STAssertTrue([command.arguments count] == 1, @"Command should have one argument");
    STAssertEqualObjects(command.arguments[0], @"function.", nil);

    text = paragraph.children[2];
    STAssertEquals(text.kind, PLClangCommentKindText, @"Child comment should have been text");
    STAssertTrue(text.isWhitespace, nil);
    STAssertEqualObjects(text.text, @" ", nil);
}

- (void) testHTMLTag {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @""
    "/** <a href=\"#anchor\">text</a> */\n"
    "void f();"
    ];
    PLClangComment *comment = [[tu cursorWithSpelling: @"f"] comment];
    STAssertNotNil(comment, @"Comment was not found");
    STAssertTrue([comment.children count] == 1, @"Comment should have a paragraph");

    PLClangComment *paragraph = comment.children[0];
    STAssertEquals(paragraph.kind, PLClangCommentKindParagraph, @"Child comment should have been a paragraph");
    STAssertTrue([paragraph.children count] == 5, @"Paragraph should have html start/end tags and three text children");

    PLClangComment *text = paragraph.children[0];
    STAssertEquals(text.kind, PLClangCommentKindText, @"Child comment should have been text");
    STAssertTrue(text.isWhitespace, nil);
    STAssertEqualObjects(text.text, @" ", nil);

    PLClangComment *tag = paragraph.children[1];
    STAssertEquals(tag.kind, PLClangCommentKindHTMLStartTag, @"Child comment should have been an HTML start tag");
    STAssertEqualObjects(tag.text, @"<a href=\"#anchor\">", nil);

    text = paragraph.children[2];
    STAssertEquals(text.kind, PLClangCommentKindText, @"Child comment should have been text");
    STAssertFalse(text.isWhitespace, nil);
    STAssertEqualObjects(text.text, @"text", nil);

    tag = paragraph.children[3];
    STAssertEquals(tag.kind, PLClangCommentKindHTMLEndTag, @"Child comment should have been an HTML end tag");
    STAssertEqualObjects(tag.text, @"</a>", nil);

    text = paragraph.children[4];
    STAssertEquals(text.kind, PLClangCommentKindText, @"Child comment should have been text");
    STAssertTrue(text.isWhitespace, nil);
    STAssertEqualObjects(text.text, @" ", nil);
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
    STAssertNotNil(comment, @"Comment was not found");
    STAssertTrue([comment.children count] == 2, @"Comment should have a paragraph and a block command");

    PLClangComment *paragraph = comment.children[0];
    STAssertEquals(paragraph.kind, PLClangCommentKindParagraph, @"Child comment should have been a paragraph");

    PLClangComment *command = comment.children[1];
    STAssertEquals(command.kind, PLClangCommentKindBlockCommand, @"Child comment should have been a block command");
    STAssertEqualObjects(command.commandName, @"note", nil);
    STAssertNotNil(command.paragraph, nil);
    STAssertEquals(command.paragraph.kind, PLClangCommentKindParagraph, @"Should have been a paragraph");
    STAssertNotNil(command.paragraph.children, nil);
    STAssertTrue([command.paragraph.children count] == 2, @"Paragraph should have two text children");

    PLClangComment *text = command.paragraph.children[0];
    STAssertEquals(text.kind, PLClangCommentKindText, @"Child comment should have been text");
    STAssertFalse(text.isWhitespace, nil);
    STAssertEqualObjects(text.text, @" A note.", nil);

    text = command.paragraph.children[1];
    STAssertEquals(text.kind, PLClangCommentKindText, @"Child comment should have been text");
    STAssertTrue(text.isWhitespace, nil);
    STAssertEqualObjects(text.text, @" ", @"Second text segment is the space between the newline and '*'");
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
    STAssertNotNil(comment, @"Comment was not found");
    STAssertTrue([comment.children count] == 3, @"Comment should have a two paragraphs and a verbatim block command");

    PLClangComment *paragraph = comment.children[0];
    STAssertEquals(paragraph.kind, PLClangCommentKindParagraph, @"Child comment should have been a paragraph");

    PLClangComment *command = comment.children[1];
    STAssertEquals(command.kind, PLClangCommentKindVerbatimBlockCommand, @"Child comment should have been a block command");
    STAssertEqualObjects(command.commandName, @"code", nil);
    STAssertNil(command.paragraph, nil);
    STAssertNotNil(command.children, nil);
    STAssertTrue([command.children count] == 1, @"Command should have a verbatim block line child");

    PLClangComment *line = command.children[0];
    STAssertEquals(line.kind, PLClangCommentKindVerbatimBlockLine, @"Should have been a verbatim block line");
    STAssertEqualObjects(line.text, @" t", nil);
}

@end
