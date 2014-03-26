/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <ObjectDoc/ObjectDoc.h>
#import "PLClangTestCase.h"

@interface PLClangTranslationUnitTests : PLClangTestCase @end

@implementation PLClangTranslationUnitTests {
    NSString *_tempDirectory;
}

- (void) setUp {
    [super setUp];
    NSString *bundleId = [[NSBundle bundleForClass: [self class]] bundleIdentifier];
    _tempDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent: bundleId];
    [[NSFileManager defaultManager] removeItemAtPath: _tempDirectory error: nil];
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath: _tempDirectory withIntermediateDirectories: YES attributes: nil error: nil];
    XCTAssertTrue(result, @"Failed to create temporary directory");
}

- (void) tearDown {
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath: _tempDirectory error: nil];
    XCTAssertTrue(result, @"Failed to remove temporary directory");
    [super tearDown];
}

/**
 * Test basic parsing
 */
- (void) testParsing {
    NSError *error = nil;
    NSData *test = [@"int main (int argc, char *argv[]) { return 0; }" dataUsingEncoding: NSUTF8StringEncoding];
    PLClangTranslationUnit *tu = [_index addTranslationUnitWithSourcePath: @"test.c" fileData: test compilerArguments: @[] options: 0 error: &error];
    XCTAssertNotNil(tu, @"Failed to parse", nil);
    XCTAssertNil(error, @"Received error for successful parse");
    XCTAssertEqualObjects(tu.spelling, @"test.c");
    XCTAssertNotNil(tu.cursor, @"Translation unit should have a cursor");
    XCTAssertEqual(tu.cursor.kind, PLClangCursorKindTranslationUnit, @"Cursor should be a translation unit cursor");

    XCTAssertFalse(tu.didFail, @"Should be marked as non-failed: %@", tu.diagnostics);
    XCTAssertTrue([tu.diagnostics count] == 0, @"No diagnostics should be returned");
}

/**
 * Test extraction of compiler diagnostics.
 */
- (void) testExtractDiagnostics {
    NSError *error = nil;
    NSData *test = [@"PARSE ERROR int main (int argc, char *argv[]) { return 0; }" dataUsingEncoding: NSUTF8StringEncoding];
    PLClangTranslationUnit *tu = [_index addTranslationUnitWithSourcePath: @"test.c" fileData: test compilerArguments: @[] options: 0 error: &error];
    XCTAssertNotNil(tu, @"Failed to parse", nil);
    XCTAssertNil(error, @"Received error for successful parse");
    XCTAssertEqualObjects(tu.spelling, @"test.c");
    XCTAssertNotNil(tu.cursor, @"Translation unit should have a cursor");
    XCTAssertEqual(tu.cursor.kind, PLClangCursorKindTranslationUnit, @"Cursor should be a translation unit cursor");

    XCTAssertTrue(tu.didFail, @"Should be marked as failed");
    XCTAssertTrue([tu.diagnostics count] > 0, @"No diagnostics returned");
    for (PLClangDiagnostic *diag in tu.diagnostics) {
        XCTAssertNotNil(diag.formattedErrorMessage, @"No error message returned");
    }
}

/**
 * Test that macro definitions are included when the detailed preprocessing record is enabled.
 */
- (void) testDetailedPreprocessing {
    NSError *error = nil;
    NSData *test = [@"#define MACRO 1" dataUsingEncoding: NSUTF8StringEncoding];
    PLClangTranslationUnit *tu = [_index addTranslationUnitWithSourcePath: @"test.c" fileData: test compilerArguments: @[] options: 0 error: &error];
    XCTAssertNotNil(tu, @"Failed to parse", nil);
    XCTAssertNil(error, @"Received error for successful parse");
    XCTAssertEqualObjects(tu.spelling, @"test.c");
    XCTAssertNotNil(tu.cursor, @"Translation unit should have a cursor");
    XCTAssertEqual(tu.cursor.kind, PLClangCursorKindTranslationUnit, @"Cursor should be a translation unit cursor");
    XCTAssertNil([tu cursorWithSpelling: @"MACRO"], @"Should not have found macro definition without detailed preprocessing record");

    tu = [_index addTranslationUnitWithSourcePath: @"test.c" fileData: test compilerArguments: @[] options: PLClangTranslationUnitCreationDetailedPreprocessingRecord error: &error];
    XCTAssertNotNil(tu, @"Failed to parse", nil);
    XCTAssertNil(error, @"Received error for successful parse");
    XCTAssertEqualObjects(tu.spelling, @"test.c");
    XCTAssertNotNil(tu.cursor, @"Translation unit should have a cursor");
    XCTAssertEqual(tu.cursor.kind, PLClangCursorKindTranslationUnit, @"Cursor should be a translation unit cursor");
    XCTAssertNotNil([tu cursorWithSpelling: @"MACRO"], @"Should have found macro definition with detailed preprocessing record");
}

/**
 * Test that a cursor can be obtained from a source location.
 */
- (void) testCursorForLocation {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;" path: @"test.c"];
    PLClangSourceLocation *location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                                        file: @"test.c"
                                                                                      offset: 4];
    XCTAssertNotNil(location, @"Could not create source location");
    PLClangCursor *cursor = [tu cursorForSourceLocation: location];
    XCTAssertNotNil(cursor, @"Could not map cursor");
    XCTAssertEqual(cursor.kind, PLClangCursorKindVariableDeclaration, @"Cursor should be a variable declaration");
}

/**
 * Tests that a translation unit can be saved to an AST file and a new translation unit created from it.
 */
- (void) testASTFileSaveAndLoad {
    NSError *error = nil;
    NSString *path = [_tempDirectory stringByAppendingPathComponent: @"test.pch"];

    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f();"
                                                            path: @"test.h"
                                                         options: PLClangTranslationUnitCreationIncomplete |
                                                                  PLClangTranslationUnitCreationForSerialization];
    BOOL result = [tu writeToFile: path error: &error];
    XCTAssertTrue(result, @"Failed to save translation unit");
    XCTAssertNil(error, @"Received error for translation unit save");

    PLClangSourceIndex *index = [PLClangSourceIndex new];
    tu = [index addTranslationUnitWithASTPath: path error: &error];
    XCTAssertNotNil(tu, @"Failed to parse", nil);
    XCTAssertNil(error, @"Received error for successful parse");
    XCTAssertFalse(tu.didFail, @"Should be marked as non-failed: %@", tu.diagnostics);
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    XCTAssertNotNil(cursor, @"Failed to locate cursor in translation unit loaded from AST file");
}

- (void) testASTFileWriteToInvalidPath {
    NSError *error = nil;
    NSString *path = [_tempDirectory stringByAppendingPathComponent: @"notfound/test.pch"];

    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f();"
                                                            path: @"test.h"
                                                         options: PLClangTranslationUnitCreationIncomplete |
                                                                  PLClangTranslationUnitCreationForSerialization];
    BOOL result = [tu writeToFile: path error: &error];
    XCTAssertFalse(result, @"Translation unit save should have failed");
    XCTAssertNotNil(error, @"Should have received error for translation unit save");
    XCTAssertEqualObjects(error.domain, PLClangErrorDomain);
    XCTAssertEqual(error.code, PLClangErrorSaveFailed);
}

@end
