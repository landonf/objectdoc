#import "PLClangTestCase.h"

@interface PLClangTypeTests : PLClangTestCase
@end

@implementation PLClangTypeTests

- (void) testInt {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;"];
    PLClangType *type = [[tu cursorWithSpelling: @"t"] type];
    XCTAssertNotNil(type);
    XCTAssertEqual(type.kind, PLClangTypeKindInt);
    XCTAssertEqualObjects(type.spelling, @"int");
    XCTAssertNil(type.declaration);
    XCTAssertNil(type.resultType);
    XCTAssertNil(type.pointeeType);
    XCTAssertNil(type.elementType);
    XCTAssertNil(type.argumentTypes);
    XCTAssertTrue(type.numberOfElements == -1, @"Should not have had an element count, not a constant array type");

    XCTAssertEqualObjects(type.canonicalType, type, @"Type should have been its canonical type");
}

- (void) testConstantArray {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t[2];"];
    PLClangType *type = [[tu cursorWithSpelling: @"t"] type];
    XCTAssertNotNil(type);
    XCTAssertEqual(type.kind, PLClangTypeKindConstantArray);
    XCTAssertEqualObjects(type.spelling, @"int [2]");
    XCTAssertNil(type.declaration);
    XCTAssertNil(type.resultType);
    XCTAssertNil(type.pointeeType);
    XCTAssertNotNil(type.elementType);
    XCTAssertNil(type.argumentTypes);
    XCTAssertTrue(type.numberOfElements == 2, @"Constant array should have had 2 elements");

    XCTAssertEqualObjects(type.canonicalType, type, @"Type should have been its canonical type");
    XCTAssertEqual(type.elementType.kind, PLClangTypeKindInt);
}

- (void) testPointer {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int *t;"];
    PLClangType *type = [[tu cursorWithSpelling: @"t"] type];
    XCTAssertNotNil(type);
    XCTAssertEqual(type.kind, PLClangTypeKindPointer);
    XCTAssertEqualObjects(type.spelling, @"int *");
    XCTAssertNil(type.declaration);
    XCTAssertNil(type.resultType);
    XCTAssertNotNil(type.pointeeType);
    XCTAssertNil(type.elementType);
    XCTAssertNil(type.argumentTypes);
    XCTAssertTrue(type.numberOfElements == -1, @"Should not have had an element count, not a constant array type");

    XCTAssertEqualObjects(type.canonicalType, type, @"Type should have been its canonical type");
    XCTAssertEqual(type.pointeeType.kind, PLClangTypeKindInt);
}

- (void) testTypedef {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"typedef int type; type t; int o;"];
    PLClangType *type = [[tu cursorWithSpelling: @"t"] type];
    XCTAssertEqual(type.kind, PLClangTypeKindTypedef);
    XCTAssertEqualObjects(type.spelling, @"type");
    XCTAssertNotNil(type.declaration);
    XCTAssertNil(type.resultType);
    XCTAssertNil(type.pointeeType);
    XCTAssertNil(type.elementType);
    XCTAssertNil(type.argumentTypes);
    XCTAssertTrue(type.numberOfElements == -1, @"Should not have had an element count, not a constant array type");
    XCTAssertFalse([type.canonicalType isEqual: type], @"Typedef should not have been its canonical type");

    XCTAssertEqual(type.canonicalType.kind, PLClangTypeKindInt, @"Typedef's canonical type should have been int");

    PLClangType *intType = [[tu cursorWithSpelling: @"o"] type];
    XCTAssertNotNil(type);
    XCTAssertEqualObjects(type.canonicalType, intType, @"Canonical type should have been equal to non-typedefed int type");
}

- (void) testMultiLevelTypedef {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"typedef int base; typedef base type; type t;"];
    PLClangType *type = [[tu cursorWithSpelling: @"t"] type];
    XCTAssertEqual(type.kind, PLClangTypeKindTypedef);
    XCTAssertEqualObjects(type.spelling, @"type");
    XCTAssertEqual(type.canonicalType.kind, PLClangTypeKindInt, @"Multi-level typedef's canonical type should have been int");
}

- (void) testFunction {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f(int p);"];
    PLClangType *type = [[tu cursorWithSpelling: @"f"] type];
    XCTAssertEqual(type.kind, PLClangTypeKindFunctionPrototype);
    XCTAssertEqualObjects(type.spelling, @"void (int)");
    XCTAssertNil(type.declaration);
    XCTAssertNotNil(type.resultType);
    XCTAssertNil(type.pointeeType);
    XCTAssertNil(type.elementType);
    XCTAssertNotNil(type.argumentTypes);
    XCTAssertTrue(type.numberOfElements == -1, @"Should not have had an element count, not a constant array type");

    XCTAssertEqualObjects(type.canonicalType, type, @"Type should have been its canonical type");
    XCTAssertEqual(type.resultType.kind, PLClangTypeKindVoid);

    XCTAssertTrue([type.argumentTypes count] == 1, @"Function type should have had an argument type");

    PLClangType *argType = type.argumentTypes[0];
    XCTAssertEqual(argType.kind, PLClangTypeKindInt);
}

- (void) testQualifiers {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;"];
    PLClangType *type = [[tu cursorWithSpelling: @"t"] type];
    XCTAssertNotNil(type);
    XCTAssertFalse(type.isConstQualified);
    XCTAssertFalse(type.isRestrictQualified);
    XCTAssertFalse(type.isVolatileQualified);

    tu = [self translationUnitWithSource: @"const int t = 1;"];
    type = [[tu cursorWithSpelling: @"t"] type];
    XCTAssertNotNil(type);
    XCTAssertTrue(type.isConstQualified);
    XCTAssertFalse(type.isRestrictQualified);
    XCTAssertFalse(type.isVolatileQualified);

    tu = [self translationUnitWithSource: @"int * restrict t;"];
    type = [[tu cursorWithSpelling: @"t"] type];
    XCTAssertNotNil(type);
    XCTAssertFalse(type.isConstQualified);
    XCTAssertTrue(type.isRestrictQualified);
    XCTAssertFalse(type.isVolatileQualified);

    tu = [self translationUnitWithSource: @"volatile int t;"];
    type = [[tu cursorWithSpelling: @"t"] type];
    XCTAssertNotNil(type);
    XCTAssertFalse(type.isConstQualified);
    XCTAssertFalse(type.isRestrictQualified);
    XCTAssertTrue(type.isVolatileQualified);
}

- (void) testPOD {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"class T {};" path: @"test.cpp"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"T"];
    XCTAssertNotNil(cursor);
    XCTAssertTrue(cursor.type.isPOD, @"Class should have been a POD type");

    tu = [self translationUnitWithSource: @"class T { ~T() {} };" path: @"test.cpp"];
    cursor = [tu cursorWithSpelling: @"T"];
    XCTAssertNotNil(cursor);
    XCTAssertFalse(cursor.type.isPOD, @"Class should not have been a POD type");
}

- (void) testVariadic {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f(int p, ...);"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    XCTAssertNotNil(cursor);
    XCTAssertTrue(cursor.type.isVariadic, @"Function should have been variadic");

    tu = [self translationUnitWithSource: @"void f(int p);"];
    cursor = [tu cursorWithSpelling: @"f"];
    XCTAssertNotNil(cursor);
    XCTAssertFalse(cursor.type.isVariadic, @"Function should not have been variadic");
}

@end
