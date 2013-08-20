#import "PLClangTestCase.h"

@interface PLClangTypeTests : PLClangTestCase
@end

@implementation PLClangTypeTests

- (void) testInt {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;"];
    PLClangType *type = [[tu cursorWithSpelling: @"t"] type];
    STAssertNotNil(type, nil);
    STAssertEquals(type.kind, PLClangTypeKindInt, nil);
    STAssertEqualObjects(type.spelling, @"int", nil);
    STAssertNil(type.declaration, nil);
    STAssertNil(type.resultType, nil);
    STAssertNil(type.pointeeType, nil);
    STAssertNil(type.elementType, nil);
    STAssertNil(type.argumentTypes, nil);
    STAssertTrue(type.numberOfElements == -1, @"Should not have had an element count, not a constant array type");

    STAssertEqualObjects(type.canonicalType, type, @"Type should have been its canonical type");
}

- (void) testConstantArray {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t[2];"];
    PLClangType *type = [[tu cursorWithSpelling: @"t"] type];
    STAssertNotNil(type, nil);
    STAssertEquals(type.kind, PLClangTypeKindConstantArray, nil);
    STAssertEqualObjects(type.spelling, @"int [2]", nil);
    STAssertNil(type.declaration, nil);
    STAssertNil(type.resultType, nil);
    STAssertNil(type.pointeeType, nil);
    STAssertNotNil(type.elementType, nil);
    STAssertNil(type.argumentTypes, nil);
    STAssertTrue(type.numberOfElements == 2, @"Constant array should have had 2 elements");

    STAssertEqualObjects(type.canonicalType, type, @"Type should have been its canonical type");
    STAssertEquals(type.elementType.kind, PLClangTypeKindInt, nil);
}

- (void) testPointer {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int *t;"];
    PLClangType *type = [[tu cursorWithSpelling: @"t"] type];
    STAssertNotNil(type, nil);
    STAssertEquals(type.kind, PLClangTypeKindPointer, nil);
    STAssertEqualObjects(type.spelling, @"int *", nil);
    STAssertNil(type.declaration, nil);
    STAssertNil(type.resultType, nil);
    STAssertNotNil(type.pointeeType, nil);
    STAssertNil(type.elementType, nil);
    STAssertNil(type.argumentTypes, nil);
    STAssertTrue(type.numberOfElements == -1, @"Should not have had an element count, not a constant array type");

    STAssertEqualObjects(type.canonicalType, type, @"Type should have been its canonical type");
    STAssertEquals(type.pointeeType.kind, PLClangTypeKindInt, nil);
}

- (void) testTypedef {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"typedef int type; type t; int o;"];
    PLClangType *type = [[tu cursorWithSpelling: @"t"] type];
    STAssertEquals(type.kind, PLClangTypeKindTypedef, nil);
    STAssertEqualObjects(type.spelling, @"type", nil);
    STAssertNotNil(type.declaration, nil);
    STAssertNil(type.resultType, nil);
    STAssertNil(type.pointeeType, nil);
    STAssertNil(type.elementType, nil);
    STAssertNil(type.argumentTypes, nil);
    STAssertTrue(type.numberOfElements == -1, @"Should not have had an element count, not a constant array type");
    STAssertFalse([type.canonicalType isEqual: type], @"Typedef should not have been its canonical type");

    STAssertEquals(type.canonicalType.kind, PLClangTypeKindInt, @"Typedef's canonical type should have been int");

    PLClangType *intType = [[tu cursorWithSpelling: @"o"] type];
    STAssertNotNil(type, nil);
    STAssertEqualObjects(type.canonicalType, intType, @"Canonical type should have been equal to non-typedefed int type");
}

- (void) testMultiLevelTypedef {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"typedef int base; typedef base type; type t;"];
    PLClangType *type = [[tu cursorWithSpelling: @"t"] type];
    STAssertEquals(type.kind, PLClangTypeKindTypedef, nil);
    STAssertEqualObjects(type.spelling, @"type", nil);
    STAssertEquals(type.canonicalType.kind, PLClangTypeKindInt, @"Multi-level typedef's canonical type should have been int");
}

- (void) testFunction {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f(int p);"];
    PLClangType *type = [[tu cursorWithSpelling: @"f"] type];
    STAssertEquals(type.kind, PLClangTypeKindFunctionPrototype, nil);
    STAssertEqualObjects(type.spelling, @"void (int)", nil);
    STAssertNil(type.declaration, nil);
    STAssertNotNil(type.resultType, nil);
    STAssertNil(type.pointeeType, nil);
    STAssertNil(type.elementType, nil);
    STAssertNotNil(type.argumentTypes, nil);
    STAssertTrue(type.numberOfElements == -1, @"Should not have had an element count, not a constant array type");

    STAssertEqualObjects(type.canonicalType, type, @"Type should have been its canonical type");
    STAssertEquals(type.resultType.kind, PLClangTypeKindVoid, nil);

    STAssertTrue([type.argumentTypes count] == 1, @"Function type should have had an argument type");

    PLClangType *argType = type.argumentTypes[0];
    STAssertEquals(argType.kind, PLClangTypeKindInt, nil);
}

- (void) testQualifiers {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;"];
    PLClangType *type = [[tu cursorWithSpelling: @"t"] type];
    STAssertNotNil(type, nil);
    STAssertFalse(type.isConstQualified, nil);
    STAssertFalse(type.isRestrictQualified, nil);
    STAssertFalse(type.isVolatileQualified, nil);

    tu = [self translationUnitWithSource: @"const int t = 1;"];
    type = [[tu cursorWithSpelling: @"t"] type];
    STAssertNotNil(type, nil);
    STAssertTrue(type.isConstQualified, nil);
    STAssertFalse(type.isRestrictQualified, nil);
    STAssertFalse(type.isVolatileQualified, nil);

    tu = [self translationUnitWithSource: @"int * restrict t;"];
    type = [[tu cursorWithSpelling: @"t"] type];
    STAssertNotNil(type, nil);
    STAssertFalse(type.isConstQualified, nil);
    STAssertTrue(type.isRestrictQualified, nil);
    STAssertFalse(type.isVolatileQualified, nil);

    tu = [self translationUnitWithSource: @"volatile int t;"];
    type = [[tu cursorWithSpelling: @"t"] type];
    STAssertNotNil(type, nil);
    STAssertFalse(type.isConstQualified, nil);
    STAssertFalse(type.isRestrictQualified, nil);
    STAssertTrue(type.isVolatileQualified, nil);
}

- (void) testPOD {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"class T {};" path: @"test.cpp"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"T"];
    STAssertNotNil(cursor, nil);
    STAssertTrue(cursor.type.isPOD, @"Class should have been a POD type");

    tu = [self translationUnitWithSource: @"class T { ~T() {} };" path: @"test.cpp"];
    cursor = [tu cursorWithSpelling: @"T"];
    STAssertNotNil(cursor, nil);
    STAssertFalse(cursor.type.isPOD, @"Class should not have been a POD type");
}

- (void) testVariadic {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f(int p, ...);"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    STAssertNotNil(cursor, nil);
    STAssertTrue(cursor.type.isVariadic, @"Function should have been variadic");

    tu = [self translationUnitWithSource: @"void f(int p);"];
    cursor = [tu cursorWithSpelling: @"f"];
    STAssertNotNil(cursor, nil);
    STAssertFalse(cursor.type.isVariadic, @"Function should not have been variadic");
}

@end
