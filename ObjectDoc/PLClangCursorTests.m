#import "PLClangTestCase.h"

@interface PLClangCursorTests : PLClangTestCase
@end

@implementation PLClangCursorTests

/**
 * Verify that cursors can be created for everything in the Foundation headers.
 */
- (void) testFoundationRecursion {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"#import <Foundation/Foundation.h>"];
    [tu.cursor visitChildrenUsingBlock: ^PLClangCursorVisitResult(PLClangCursor *cursor) {
        if (!cursor) {
            XCTFail(@"Could not create cursor for %@", cursor.spelling);
            return PLClangCursorVisitBreak;
        }
        return PLClangCursorVisitRecurse;
    }];
}

- (void) testTranslationUnitCursor {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;"];
    PLClangCursor *cursor = tu.cursor;
    XCTAssertNotNil(cursor);

    XCTAssertEqual(cursor.kind, PLClangCursorKindTranslationUnit);
    XCTAssertEqual(cursor.language, PLClangLanguageInvalid);
    XCTAssertEqual(cursor.linkage, PLClangLinkageInvalid);
    XCTAssertEqualObjects(cursor.USR, @"");
    XCTAssertEqualObjects(cursor.spelling, @"test.m");
    XCTAssertEqualObjects(cursor.displayName, @"test.m");
    XCTAssertNil(cursor.location);
    XCTAssertNotNil(cursor.extent);
    XCTAssertFalse(cursor.isAttribute);
    XCTAssertFalse(cursor.isDeclaration);
    XCTAssertFalse(cursor.isDefinition);
    XCTAssertFalse(cursor.isExpression);
    XCTAssertFalse(cursor.isPreprocessing);
    XCTAssertFalse(cursor.isReference);
    XCTAssertFalse(cursor.isStatement);
    XCTAssertFalse(cursor.isUnexposed);
    XCTAssertFalse(cursor.isObjCOptional);
    XCTAssertFalse(cursor.isVariadic);
    XCTAssertNotNil(cursor.canonicalCursor);
    XCTAssertNil(cursor.semanticParent);
    XCTAssertNil(cursor.lexicalParent);
    XCTAssertNil(cursor.referencedCursor);
    XCTAssertNil(cursor.definition);
    XCTAssertNil(cursor.type);
    XCTAssertNil(cursor.resultType);
    XCTAssertNil(cursor.enumIntegerType);
    XCTAssertEqual(cursor.enumConstantValue, LONG_LONG_MIN);
    XCTAssertEqual(cursor.enumConstantUnsignedValue, ULONG_LONG_MAX);
    XCTAssertEqual(cursor.bitFieldWidth, -1);
    XCTAssertNil(cursor.arguments);
    XCTAssertNil(cursor.overloadedDeclarations);
    XCTAssertNil(cursor.comment);
    XCTAssertNil(cursor.briefComment);

    XCTAssertEqualObjects(cursor, cursor.canonicalCursor, @"Translation unit cursor should have been its canonical cursor");
}

- (void) testVariableDeclaration {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"t"];
    XCTAssertNotNil(cursor);

    XCTAssertEqual(cursor.kind, PLClangCursorKindVariableDeclaration);
    XCTAssertEqual(cursor.language, PLClangLanguageC);
    XCTAssertEqual(cursor.linkage, PLClangLinkageExternal);
    XCTAssertEqualObjects(cursor.USR, @"c:@t");
    XCTAssertEqualObjects(cursor.spelling, @"t");
    XCTAssertEqualObjects(cursor.displayName, @"t");
    XCTAssertNotNil(cursor.location);
    XCTAssertNotNil(cursor.extent);
    XCTAssertFalse(cursor.isAttribute);
    XCTAssertTrue(cursor.isDeclaration);
    XCTAssertFalse(cursor.isDefinition);
    XCTAssertFalse(cursor.isExpression);
    XCTAssertFalse(cursor.isPreprocessing);
    XCTAssertFalse(cursor.isReference);
    XCTAssertFalse(cursor.isStatement);
    XCTAssertFalse(cursor.isUnexposed);
    XCTAssertFalse(cursor.isObjCOptional);
    XCTAssertFalse(cursor.isVariadic);
    XCTAssertNotNil(cursor.canonicalCursor);
    XCTAssertNotNil(cursor.semanticParent);
    XCTAssertNotNil(cursor.lexicalParent);
    XCTAssertNotNil(cursor.referencedCursor);
    XCTAssertNil(cursor.definition);
    XCTAssertNotNil(cursor.type);
    XCTAssertNil(cursor.resultType);
    XCTAssertNil(cursor.enumIntegerType);
    XCTAssertEqual(cursor.enumConstantValue, LONG_LONG_MIN);
    XCTAssertEqual(cursor.enumConstantUnsignedValue, ULONG_LONG_MAX);
    XCTAssertEqual(cursor.bitFieldWidth, -1);
    XCTAssertNil(cursor.arguments);
    XCTAssertNil(cursor.overloadedDeclarations);
    XCTAssertNil(cursor.comment);
    XCTAssertNil(cursor.briefComment);

    XCTAssertEqualObjects(cursor, cursor.canonicalCursor, @"Cursor should have been its canonical cursor");
    XCTAssertEqualObjects(cursor.semanticParent, tu.cursor, @"Semantic parent should have been the translation unit");
    XCTAssertEqualObjects(cursor.lexicalParent, tu.cursor, @"Lexical parent should have been the translation unit");
    XCTAssertEqualObjects(cursor.referencedCursor, cursor, @"Cursor should have been a self reference");
}

- (void) testVariableDefinition {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t = 7;"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"t"];
    XCTAssertNotNil(cursor);

    XCTAssertEqual(cursor.kind, PLClangCursorKindVariableDeclaration);
    XCTAssertEqual(cursor.language, PLClangLanguageC);
    XCTAssertEqual(cursor.linkage, PLClangLinkageExternal);
    XCTAssertEqualObjects(cursor.USR, @"c:@t");
    XCTAssertEqualObjects(cursor.spelling, @"t");
    XCTAssertEqualObjects(cursor.displayName, @"t");
    XCTAssertNotNil(cursor.location);
    XCTAssertNotNil(cursor.extent);
    XCTAssertFalse(cursor.isAttribute);
    XCTAssertTrue(cursor.isDeclaration);
    XCTAssertTrue(cursor.isDefinition);
    XCTAssertFalse(cursor.isExpression);
    XCTAssertFalse(cursor.isPreprocessing);
    XCTAssertFalse(cursor.isReference);
    XCTAssertFalse(cursor.isStatement);
    XCTAssertFalse(cursor.isUnexposed);
    XCTAssertFalse(cursor.isObjCOptional);
    XCTAssertFalse(cursor.isVariadic);
    XCTAssertNotNil(cursor.canonicalCursor);
    XCTAssertNotNil(cursor.semanticParent);
    XCTAssertNotNil(cursor.lexicalParent);
    XCTAssertNotNil(cursor.referencedCursor);
    XCTAssertNotNil(cursor.definition);
    XCTAssertNotNil(cursor.type);
    XCTAssertNil(cursor.resultType);
    XCTAssertNil(cursor.enumIntegerType);
    XCTAssertEqual(cursor.enumConstantValue, LONG_LONG_MIN);
    XCTAssertEqual(cursor.enumConstantUnsignedValue, ULONG_LONG_MAX);
    XCTAssertEqual(cursor.bitFieldWidth, -1);
    XCTAssertNil(cursor.arguments);
    XCTAssertNil(cursor.overloadedDeclarations);
    XCTAssertNil(cursor.comment);
    XCTAssertNil(cursor.briefComment);

    XCTAssertEqualObjects(cursor, cursor.canonicalCursor, @"Cursor should have been its canonical cursor");
    XCTAssertEqualObjects(cursor.semanticParent, tu.cursor, @"Semantic parent should have been the translation unit");
    XCTAssertEqualObjects(cursor.lexicalParent, tu.cursor, @"Lexical parent should have been the translation unit");
    XCTAssertEqualObjects(cursor.referencedCursor, cursor, @"Cursor should have been a self reference");
    XCTAssertEqualObjects(cursor, cursor.definition, @"Cursor should have also been its definition");
}

- (void) testFunctionDeclaration {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f(int param);"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    XCTAssertNotNil(cursor);

    XCTAssertEqual(cursor.kind, PLClangCursorKindFunctionDeclaration);
    XCTAssertEqual(cursor.language, PLClangLanguageC);
    XCTAssertEqual(cursor.linkage, PLClangLinkageExternal);
    XCTAssertEqualObjects(cursor.USR, @"c:@F@f");
    XCTAssertEqualObjects(cursor.spelling, @"f");
    XCTAssertEqualObjects(cursor.displayName, @"f(int)");
    XCTAssertNotNil(cursor.location);
    XCTAssertNotNil(cursor.extent);
    XCTAssertFalse(cursor.isAttribute);
    XCTAssertTrue(cursor.isDeclaration);
    XCTAssertFalse(cursor.isDefinition);
    XCTAssertFalse(cursor.isExpression);
    XCTAssertFalse(cursor.isPreprocessing);
    XCTAssertFalse(cursor.isReference);
    XCTAssertFalse(cursor.isStatement);
    XCTAssertFalse(cursor.isUnexposed);
    XCTAssertFalse(cursor.isObjCOptional);
    XCTAssertFalse(cursor.isVariadic);
    XCTAssertNotNil(cursor.canonicalCursor);
    XCTAssertNotNil(cursor.semanticParent);
    XCTAssertNotNil(cursor.lexicalParent);
    XCTAssertNotNil(cursor.referencedCursor);
    XCTAssertNil(cursor.definition);
    XCTAssertNotNil(cursor.type);
    XCTAssertNotNil(cursor.resultType);
    XCTAssertNil(cursor.enumIntegerType);
    XCTAssertEqual(cursor.enumConstantValue, LONG_LONG_MIN);
    XCTAssertEqual(cursor.enumConstantUnsignedValue, ULONG_LONG_MAX);
    XCTAssertEqual(cursor.bitFieldWidth, -1);
    XCTAssertNotNil(cursor.arguments);
    XCTAssertNil(cursor.overloadedDeclarations);
    XCTAssertNil(cursor.comment);
    XCTAssertNil(cursor.briefComment);

    XCTAssertEqualObjects(cursor, cursor.canonicalCursor, @"Cursor should have been its canonical cursor");
    XCTAssertEqualObjects(cursor.semanticParent, tu.cursor, @"Semantic parent should have been the translation unit");
    XCTAssertEqualObjects(cursor.lexicalParent, tu.cursor, @"Lexical parent should have been the translation unit");
    XCTAssertEqualObjects(cursor.referencedCursor, cursor, @"Cursor should have been a self reference");

    XCTAssertTrue([cursor.arguments count] == 1, @"Should have had an argument");

    PLClangCursor *param = cursor.arguments[0];
    XCTAssertEqual(param.kind, PLClangCursorKindParameterDeclaration);
    XCTAssertEqualObjects(param.spelling, @"param");
    XCTAssertEqualObjects(param.displayName, @"param");

    XCTAssertEqualObjects(param, param.canonicalCursor, @"Cursor should have been its canonical cursor");
    XCTAssertEqualObjects(param.semanticParent, cursor, @"Semantic parent should have been the function declaration");
    XCTAssertEqualObjects(param.lexicalParent, cursor, @"Lexical parent should have been the function declaration");
    XCTAssertEqualObjects(cursor.referencedCursor, cursor, @"Cursor should have been a self reference");
}

- (void) testLanguage {
    PLClangTranslationUnit *tu;
    PLClangCursor *cursor;

    tu = [self translationUnitWithSource: @"void f();"];
    cursor = [tu cursorWithSpelling: @"f"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.language, PLClangLanguageC);

    tu = [self translationUnitWithSource: @"@interface T @end"];
    cursor = [tu cursorWithSpelling: @"T"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.language, PLClangLanguageObjC);

    tu = [self translationUnitWithSource: @"class T {};" path: @"test.cpp"];
    cursor = [tu cursorWithSpelling: @"T"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.language, PLClangLanguageCPlusPlus);
}

- (void) testLinkage {
    PLClangTranslationUnit *tu;
    PLClangCursor *cursor;

    tu = [self translationUnitWithSource: @"void f() { int t; }"];
    cursor = tu.cursor;
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.linkage, PLClangLinkageInvalid);

    cursor = [tu cursorWithSpelling: @"t"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.linkage, PLClangLinkageNone);

    tu = [self translationUnitWithSource: @"static int t;"];
    cursor = [tu cursorWithSpelling: @"t"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.linkage, PLClangLinkageInternal);

    tu = [self translationUnitWithSource: @"int t;"];
    cursor = [tu cursorWithSpelling: @"t"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.linkage, PLClangLinkageExternal);

    tu = [self translationUnitWithSource: @"namespace { int t; }" path: @"test.cpp"];
    cursor = [tu cursorWithSpelling: @"t"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.linkage, PLClangLinkageUniqueExternal);
}

- (void) testResultType {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"@interface T - (int)t; @end"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"t"];
    XCTAssertNotNil(cursor);
    XCTAssertNil(cursor.type, @"The method should not have a type");
    XCTAssertNotNil(cursor.resultType, @"The method should have a result type");
    XCTAssertEqual(cursor.resultType.kind, PLClangTypeKindInt, @"The method's result type should have been int");

    tu = [self translationUnitWithSource: @"int f();"];
    cursor = [tu cursorWithSpelling: @"f"];
    XCTAssertNotNil(cursor);
    XCTAssertNotNil(cursor.type, @"The function should have a type");
    XCTAssertEqual(cursor.type.kind, PLClangTypeKindFunctionNoPrototype);
    XCTAssertNotNil(cursor.resultType, @"The function should have a result type");
    XCTAssertEqual(cursor.resultType.kind, PLClangTypeKindInt, @"The function's result type should have been int");
}

- (void) testObjCPropertyAttributes {
    [self verifyObjCPropertyWithAttributes: @"" expectedResults: PLClangObjCPropertyAttributeNone];
    [self verifyObjCPropertyWithAttributes: @"atomic" expectedResults: PLClangObjCPropertyAttributeAtomic];
    [self verifyObjCPropertyWithAttributes: @"nonatomic" expectedResults: PLClangObjCPropertyAttributeNonAtomic];
    [self verifyObjCPropertyWithAttributes: @"readonly" expectedResults: PLClangObjCPropertyAttributeReadOnly];
    [self verifyObjCPropertyWithAttributes: @"readwrite" expectedResults: PLClangObjCPropertyAttributeReadWrite];
    [self verifyObjCPropertyWithAttributes: @"assign" expectedResults: PLClangObjCPropertyAttributeAssign];
    [self verifyObjCPropertyWithAttributes: @"copy" expectedResults: PLClangObjCPropertyAttributeCopy];
    [self verifyObjCPropertyWithAttributes: @"retain" expectedResults: PLClangObjCPropertyAttributeRetain];
    [self verifyObjCPropertyWithAttributes: @"strong" expectedResults: PLClangObjCPropertyAttributeStrong];
    [self verifyObjCPropertyWithAttributes: @"unsafe_unretained" expectedResults: PLClangObjCPropertyAttributeUnsafeUnretained];
    [self verifyObjCPropertyWithAttributes: @"weak" expectedResults: PLClangObjCPropertyAttributeWeak];
    [self verifyObjCPropertyWithAttributes: @"getter=prop" expectedResults: PLClangObjCPropertyAttributeGetter];
    [self verifyObjCPropertyWithAttributes: @"setter=setProp:" expectedResults: PLClangObjCPropertyAttributeSetter];
    [self verifyObjCPropertyWithAttributes: @"nonatomic, copy, getter=prop, setter=setProp:" expectedResults:
                                            PLClangObjCPropertyAttributeNonAtomic |
                                            PLClangObjCPropertyAttributeCopy |
                                            PLClangObjCPropertyAttributeGetter |
                                            PLClangObjCPropertyAttributeSetter];
}

- (void) verifyObjCPropertyWithAttributes: (NSString *)attributes expectedResults: (PLClangObjCPropertyAttributes) expected {
    NSString *source = [NSString stringWithFormat: @"@interface Test\n"
    "@property (%@) id prop;\n"
    "@end", attributes];
    PLClangTranslationUnit *tu = [self translationUnitWithSource: source];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"prop"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.objCPropertyAttributes, expected, @"Property attributes do not match \"%@\"", attributes);
}

- (void) testEnumIntegerType {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"enum t { TEST = 0 };"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"t"];
    XCTAssertNotNil(cursor);
    XCTAssertNotNil(cursor.enumIntegerType, @"Should have had an integer type");
    XCTAssertEqual(cursor.enumIntegerType.kind, PLClangTypeKindUnsignedInt);

    tu = [self translationUnitWithSource: @"enum t : long { TEST = 0 };"];
    cursor = [tu cursorWithSpelling: @"t"];
    XCTAssertNotNil(cursor);
    XCTAssertNotNil(cursor.enumIntegerType, @"Should have had an integer type");
    XCTAssertEqual(cursor.enumIntegerType.kind, PLClangTypeKindLong);
}

- (void) testEnumConstantValue {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"enum t : int { TEST = 1, TEST_NEG = -2 };"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"TEST"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.enumConstantValue, 1LL);
    XCTAssertEqual(cursor.enumConstantUnsignedValue, 1ULL);

    cursor = [tu cursorWithSpelling: @"TEST_NEG"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.enumConstantValue, -2LL);
    XCTAssertEqual(cursor.enumConstantUnsignedValue, (unsigned long long)(unsigned int)-2, @"Unsigned value should have been a conversion to unsigned int");
}

- (void) testBitFieldWidth {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"struct t { int f1 : 1; int f2 : 2; int f3; };"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f1"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.bitFieldWidth, 1);

    cursor = [tu cursorWithSpelling: @"f2"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.bitFieldWidth, 2);

    cursor = [tu cursorWithSpelling: @"f3"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.bitFieldWidth, -1);
}

/**
 * Test that extended identifiers are properly converted to NSStrings.
 */
- (void) testExtendedIdentifiers {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int à;"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"à"];
    XCTAssertNotNil(cursor);

    tu = [self translationUnitWithSource: @"int \u00e0;"];
    cursor = [tu cursorWithSpelling: @"à"];
    XCTAssertNotNil(cursor);
}

/**
 * Test that a cursor can still function without the client holding a strong reference to the index or translation unit.
 */
- (void) testCursorWithoutTranslationUnitReference {
    PLClangCursor *tuCursor = nil;
    __block PLClangCursor *cursor = nil;

    @autoreleasepool {
        NSError *error = nil;
        NSData *source = [@"int t = 1;" dataUsingEncoding: NSUTF8StringEncoding];
        PLClangSourceIndex *index = [[PLClangSourceIndex alloc] init];
        PLClangUnsavedFile *file = [PLClangUnsavedFile unsavedFileWithPath: @"test.c" data: source];
        PLClangTranslationUnit *tu = [index addTranslationUnitWithSourcePath: @"test.c" unsavedFiles: @[file] compilerArguments: nil options: 0 error: &error];
        tuCursor = tu.cursor;
        XCTAssertNotNil(tuCursor, @"Failed to create translation unit");
    }

    [tuCursor visitChildrenUsingBlock: ^PLClangCursorVisitResult(PLClangCursor *child) {
        if ([child.spelling isEqualToString: @"t"]) {
            cursor = child;
            return PLClangCursorVisitBreak;
        }
        return PLClangCursorVisitContinue;
    }];

    XCTAssertNotNil(cursor, @"Could not find cursor for variable");
    XCTAssertEqualObjects(cursor.spelling, @"t");
    XCTAssertEqualObjects(cursor.canonicalCursor, cursor, @"Should be able to access the canonical cursor");

    PLClangType *type = cursor.type;
    XCTAssertNotNil(type);
    XCTAssertEqualObjects(type.canonicalType, type, @"Should be able to access the canonical type");
}

@end
