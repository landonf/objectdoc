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
    STAssertNil(cursor.type, nil);
    STAssertNil(cursor.resultType, nil);
    STAssertNil(cursor.enumIntegerType, nil);
    STAssertEquals(cursor.enumConstantValue, LONG_LONG_MIN, nil);
    STAssertEquals(cursor.enumConstantUnsignedValue, ULONG_LONG_MAX, nil);
    STAssertEquals(cursor.bitFieldWidth, -1, nil);
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
    STAssertNotNil(cursor.type, nil);
    STAssertNil(cursor.resultType, nil);
    STAssertNil(cursor.enumIntegerType, nil);
    STAssertEquals(cursor.enumConstantValue, LONG_LONG_MIN, nil);
    STAssertEquals(cursor.enumConstantUnsignedValue, ULONG_LONG_MAX, nil);
    STAssertEquals(cursor.bitFieldWidth, -1, nil);
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
    STAssertNotNil(cursor.type, nil);
    STAssertNil(cursor.resultType, nil);
    STAssertNil(cursor.enumIntegerType, nil);
    STAssertEquals(cursor.enumConstantValue, LONG_LONG_MIN, nil);
    STAssertEquals(cursor.enumConstantUnsignedValue, ULONG_LONG_MAX, nil);
    STAssertEquals(cursor.bitFieldWidth, -1, nil);
    STAssertNil(cursor.arguments, nil);
    STAssertNil(cursor.overloadedDeclarations, nil);

    STAssertEqualObjects(cursor, cursor.canonicalCursor, @"Cursor should have been its canonical cursor");
    STAssertEqualObjects(cursor.semanticParent, tu.cursor, @"Semantic parent should have been the translation unit");
    STAssertEqualObjects(cursor.lexicalParent, tu.cursor, @"Lexical parent should have been the translation unit");
    STAssertEqualObjects(cursor.referencedCursor, cursor, @"Cursor should have been a self reference");
    STAssertEqualObjects(cursor, cursor.definition, @"Cursor should have also been its definition");
}

- (void) testFunctionDeclaration {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f(int param);"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    STAssertNotNil(cursor, nil);

    STAssertEquals(cursor.kind, PLClangCursorKindFunctionDeclaration, nil);
    STAssertEquals(cursor.language, PLClangLanguageC, nil);
    STAssertEquals(cursor.linkage, PLClangLinkageExternal, nil);
    STAssertEqualObjects(cursor.USR, @"c:@F@f", nil);
    STAssertEqualObjects(cursor.spelling, @"f", nil);
    STAssertEqualObjects(cursor.displayName, @"f(int)", nil);
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
    STAssertNotNil(cursor.type, nil);
    STAssertNotNil(cursor.resultType, nil);
    STAssertNil(cursor.enumIntegerType, nil);
    STAssertEquals(cursor.enumConstantValue, LONG_LONG_MIN, nil);
    STAssertEquals(cursor.enumConstantUnsignedValue, ULONG_LONG_MAX, nil);
    STAssertEquals(cursor.bitFieldWidth, -1, nil);
    STAssertNotNil(cursor.arguments, nil);
    STAssertNil(cursor.overloadedDeclarations, nil);

    STAssertEqualObjects(cursor, cursor.canonicalCursor, @"Cursor should have been its canonical cursor");
    STAssertEqualObjects(cursor.semanticParent, tu.cursor, @"Semantic parent should have been the translation unit");
    STAssertEqualObjects(cursor.lexicalParent, tu.cursor, @"Lexical parent should have been the translation unit");
    STAssertEqualObjects(cursor.referencedCursor, cursor, @"Cursor should have been a self reference");

    STAssertTrue([cursor.arguments count] == 1, @"Should have had an argument");

    PLClangCursor *param = cursor.arguments[0];
    STAssertEquals(param.kind, PLClangCursorKindParameterDeclaration, nil);
    STAssertEqualObjects(param.spelling, @"param", nil);
    STAssertEqualObjects(param.displayName, @"param", nil);

    STAssertEqualObjects(param, param.canonicalCursor, @"Cursor should have been its canonical cursor");
    STAssertEqualObjects(param.semanticParent, cursor, @"Semantic parent should have been the function declaration");
    STAssertEqualObjects(param.lexicalParent, cursor, @"Lexical parent should have been the function declaration");
    STAssertEqualObjects(cursor.referencedCursor, cursor, @"Cursor should have been a self reference");
}

- (void) testLanguage {
    PLClangTranslationUnit *tu;
    PLClangCursor *cursor;

    tu = [self translationUnitWithSource: @"void f();"];
    cursor = [tu cursorWithSpelling: @"f"];
    STAssertNotNil(cursor, nil);
    STAssertEquals(cursor.language, PLClangLanguageC, nil);

    tu = [self translationUnitWithSource: @"@interface T @end"];
    cursor = [tu cursorWithSpelling: @"T"];
    STAssertNotNil(cursor, nil);
    STAssertEquals(cursor.language, PLClangLanguageObjC, nil);

    tu = [self translationUnitWithSource: @"class T {};" path: @"test.cpp"];
    cursor = [tu cursorWithSpelling: @"T"];
    STAssertNotNil(cursor, nil);
    STAssertEquals(cursor.language, PLClangLanguageCPlusPlus, nil);
}

- (void) testLinkage {
    PLClangTranslationUnit *tu;
    PLClangCursor *cursor;

    tu = [self translationUnitWithSource: @"void f() { int t; }"];
    cursor = tu.cursor;
    STAssertNotNil(cursor, nil);
    STAssertEquals(cursor.linkage, PLClangLinkageInvalid, nil);

    cursor = [tu cursorWithSpelling: @"t"];
    STAssertNotNil(cursor, nil);
    STAssertEquals(cursor.linkage, PLClangLinkageNone, nil);

    tu = [self translationUnitWithSource: @"static int t;"];
    cursor = [tu cursorWithSpelling: @"t"];
    STAssertNotNil(cursor, nil);
    STAssertEquals(cursor.linkage, PLClangLinkageInternal, nil);

    tu = [self translationUnitWithSource: @"int t;"];
    cursor = [tu cursorWithSpelling: @"t"];
    STAssertNotNil(cursor, nil);
    STAssertEquals(cursor.linkage, PLClangLinkageExternal, nil);

    tu = [self translationUnitWithSource: @"namespace { int t; }" path: @"test.cpp"];
    cursor = [tu cursorWithSpelling: @"t"];
    STAssertNotNil(cursor, nil);
    STAssertEquals(cursor.linkage, PLClangLinkageUniqueExternal, nil);
}

- (void) testResultType {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"@interface T - (int)t; @end"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"t"];
    STAssertNotNil(cursor, nil);
    STAssertNil(cursor.type, @"The method should not have a type");
    STAssertNotNil(cursor.resultType, @"The method should have a result type");
    STAssertEquals(cursor.resultType.kind, PLClangTypeKindInt, @"The method's result type should have been int");

    tu = [self translationUnitWithSource: @"int f();"];
    cursor = [tu cursorWithSpelling: @"f"];
    STAssertNotNil(cursor, nil);
    STAssertNotNil(cursor.type, @"The function should have a type");
    STAssertEquals(cursor.type.kind, PLClangTypeKindFunctionNoPrototype, nil);
    STAssertNotNil(cursor.resultType, @"The function should have a result type");
    STAssertEquals(cursor.resultType.kind, PLClangTypeKindInt, @"The function's result type should have been int");
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
    NSString *source = [NSString stringWithFormat:@"@interface Test\n"
    "@property (%@) id prop;\n"
    "@end", attributes];
    PLClangTranslationUnit *tu = [self translationUnitWithSource: source];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"prop"];
    STAssertNotNil(cursor, nil);
    STAssertEquals(cursor.objCPropertyAttributes, expected, @"Property attributes do not match \"%@\"", attributes);
}

- (void) testEnumIntegerType {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"enum t { TEST = 0 };"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"t"];
    STAssertNotNil(cursor, nil);
    STAssertNotNil(cursor.enumIntegerType, @"Should have had an integer type");
    STAssertEquals(cursor.enumIntegerType.kind, PLClangTypeKindUnsignedInt, nil);

    tu = [self translationUnitWithSource: @"enum t : long { TEST = 0 };"];
    cursor = [tu cursorWithSpelling: @"t"];
    STAssertNotNil(cursor, nil);
    STAssertNotNil(cursor.enumIntegerType, @"Should have had an integer type");
    STAssertEquals(cursor.enumIntegerType.kind, PLClangTypeKindLong, nil);
}

- (void) testEnumConstantValue {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"enum t : int { TEST = 1, TEST_NEG = -2 };"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"TEST"];
    STAssertNotNil(cursor, nil);
    STAssertEquals(cursor.enumConstantValue, 1LL, nil);
    STAssertEquals(cursor.enumConstantUnsignedValue, 1ULL, nil);

    cursor = [tu cursorWithSpelling: @"TEST_NEG"];
    STAssertNotNil(cursor, nil);
    STAssertEquals(cursor.enumConstantValue, -2LL, nil);
    STAssertEquals(cursor.enumConstantUnsignedValue, (unsigned long long)(unsigned int)-2, @"Unsigned value should have been a conversion to unsigned int");
}

- (void) testBitFieldWidth {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"struct t { int f1 : 1; int f2 : 2; int f3; };"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f1"];
    STAssertNotNil(cursor, nil);
    STAssertEquals(cursor.bitFieldWidth, 1, nil);

    cursor = [tu cursorWithSpelling: @"f2"];
    STAssertNotNil(cursor, nil);
    STAssertEquals(cursor.bitFieldWidth, 2, nil);

    cursor = [tu cursorWithSpelling: @"f3"];
    STAssertNotNil(cursor, nil);
    STAssertEquals(cursor.bitFieldWidth, -1, nil);
}

/**
 * Test that extended identifiers are properly converted to NSStrings.
 */
- (void) testExtendedIdentifiers {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int à;"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"à"];
    STAssertNotNil(cursor, nil);

    tu = [self translationUnitWithSource: @"int \u00e0;"];
    cursor = [tu cursorWithSpelling: @"à"];
    STAssertNotNil(cursor, nil);
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
        STAssertNotNil(tuCursor, @"Failed to create translation unit");
    }

    [tuCursor visitChildrenUsingBlock: ^PLClangCursorVisitResult(PLClangCursor *child) {
        if ([child.spelling isEqualToString: @"t"]) {
            cursor = child;
            return PLClangCursorVisitBreak;
        }
        return PLClangCursorVisitContinue;
    }];

    STAssertNotNil(cursor, @"Could not find cursor for variable");
    STAssertEqualObjects(cursor.spelling, @"t", nil);
    STAssertEqualObjects(cursor.canonicalCursor, cursor, @"Should be able to access the canonical cursor");

    PLClangType *type = cursor.type;
    STAssertNotNil(type, nil);
    STAssertEqualObjects(type.canonicalType, type, @"Should be able to access the canonical type");
}

@end
