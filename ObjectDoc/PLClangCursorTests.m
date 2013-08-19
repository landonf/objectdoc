#import "PLClangTestCase.h"

@interface PLClangCursorTests : PLClangTestCase
@end

@implementation PLClangCursorTests

/**
 * Verify that cursors can be created for everything in the Foundation headers.
 */
- (void) testFoundationRecursion {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"#import <Foundation/Foundation.h>"];
    [tu.cursor visitChildrenUsingBlock:^PLClangCursorVisitResult(PLClangCursor *cursor) {
        if (!cursor) {
            STFail(@"Could not create cursor for %@", cursor.spelling);
            return PLClangCursorVisitBreak;
        }
        return PLClangCursorVisitRecurse;
    }];
}

- (void) testTranslationUnitCursor {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;"];
    PLClangCursor *cursor = tu.cursor;
    STAssertNotNil(cursor, nil);

    STAssertEquals(cursor.kind, PLClangCursorKindTranslationUnit, nil);
    STAssertEquals(cursor.language, PLClangLanguageInvalid, nil);
    STAssertEquals(cursor.linkage, PLClangLinkageInvalid, nil);
    STAssertEqualObjects(cursor.USR, @"", nil);
    STAssertEqualObjects(cursor.spelling, @"test.m", nil);
    STAssertEqualObjects(cursor.displayName, @"test.m", nil);
    STAssertFalse(cursor.isAttribute, nil);
    STAssertFalse(cursor.isDeclaration, nil);
    STAssertFalse(cursor.isExpression, nil);
    STAssertFalse(cursor.isPreprocessing, nil);
    STAssertFalse(cursor.isReference, nil);
    STAssertFalse(cursor.isStatement, nil);
    STAssertFalse(cursor.isUnexposed, nil);
    STAssertFalse(cursor.isObjCOptional, nil);
    STAssertFalse(cursor.isVariadic, nil);
    STAssertNotNil(cursor.canonicalCursor, nil);
    STAssertNil(cursor.semanticParent, nil);
    STAssertNil(cursor.lexicalParent, nil);
    STAssertNil(cursor.referencedCursor, nil);
    STAssertNil(cursor.definition, nil);
    STAssertNil(cursor.arguments, nil);
    STAssertNil(cursor.overloadedDeclarations, nil);

    STAssertEqualObjects(cursor, cursor.canonicalCursor, @"Translation unit cursor should have been its canonical cursor");
}

- (void) testVariableDeclaration {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"t"];
    STAssertNotNil(cursor, nil);

    STAssertEquals(cursor.kind, PLClangCursorKindVariableDeclaration, nil);
    STAssertEquals(cursor.language, PLClangLanguageC, nil);
    STAssertEquals(cursor.linkage, PLClangLinkageExternal, nil);
    STAssertEqualObjects(cursor.USR, @"c:@t", nil);
    STAssertEqualObjects(cursor.spelling, @"t", nil);
    STAssertEqualObjects(cursor.displayName, @"t", nil);
    STAssertFalse(cursor.isAttribute, nil);
    STAssertTrue(cursor.isDeclaration, nil);
    STAssertFalse(cursor.isExpression, nil);
    STAssertFalse(cursor.isPreprocessing, nil);
    STAssertFalse(cursor.isReference, nil);
    STAssertFalse(cursor.isStatement, nil);
    STAssertFalse(cursor.isUnexposed, nil);
    STAssertFalse(cursor.isObjCOptional, nil);
    STAssertFalse(cursor.isVariadic, nil);
    STAssertNotNil(cursor.canonicalCursor, nil);
    STAssertNotNil(cursor.semanticParent, nil);
    STAssertNotNil(cursor.lexicalParent, nil);
    STAssertNotNil(cursor.referencedCursor, nil);
    STAssertNil(cursor.definition, nil);
    STAssertNil(cursor.arguments, nil);
    STAssertNil(cursor.overloadedDeclarations, nil);

    STAssertEqualObjects(cursor, cursor.canonicalCursor, @"Cursor should have been its canonical cursor");
    STAssertEqualObjects(cursor.semanticParent, tu.cursor, @"Semantic parent should have been the translation unit");
    STAssertEqualObjects(cursor.lexicalParent, tu.cursor, @"Lexical parent should have been the translation unit");
    STAssertEqualObjects(cursor.referencedCursor, cursor, @"Cursor should have been a self reference");
}

- (void) testVariableDefinition {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t = 7;"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"t"];
    STAssertNotNil(cursor, nil);

    STAssertEquals(cursor.kind, PLClangCursorKindVariableDeclaration, nil);
    STAssertEquals(cursor.language, PLClangLanguageC, nil);
    STAssertEquals(cursor.linkage, PLClangLinkageExternal, nil);
    STAssertEqualObjects(cursor.USR, @"c:@t", nil);
    STAssertEqualObjects(cursor.spelling, @"t", nil);
    STAssertEqualObjects(cursor.displayName, @"t", nil);
    STAssertFalse(cursor.isAttribute, nil);
    STAssertTrue(cursor.isDeclaration, nil);
    STAssertFalse(cursor.isExpression, nil);
    STAssertFalse(cursor.isPreprocessing, nil);
    STAssertFalse(cursor.isReference, nil);
    STAssertFalse(cursor.isStatement, nil);
    STAssertFalse(cursor.isUnexposed, nil);
    STAssertFalse(cursor.isObjCOptional, nil);
    STAssertFalse(cursor.isVariadic, nil);
    STAssertNotNil(cursor.canonicalCursor, nil);
    STAssertNotNil(cursor.semanticParent, nil);
    STAssertNotNil(cursor.lexicalParent, nil);
    STAssertNotNil(cursor.referencedCursor, nil);
    STAssertNotNil(cursor.definition, nil);
    STAssertNil(cursor.arguments, nil);
    STAssertNil(cursor.overloadedDeclarations, nil);

    STAssertEqualObjects(cursor, cursor.canonicalCursor, @"Cursor should have been its canonical cursor");
    STAssertEqualObjects(cursor.semanticParent, tu.cursor, @"Semantic parent should have been the translation unit");
    STAssertEqualObjects(cursor.lexicalParent, tu.cursor, @"Lexical parent should have been the translation unit");
    STAssertEqualObjects(cursor.referencedCursor, cursor, @"Cursor should have been a self reference");
    STAssertEqualObjects(cursor, cursor.definition, @"Cursor should have also been its definition");
}

@end
