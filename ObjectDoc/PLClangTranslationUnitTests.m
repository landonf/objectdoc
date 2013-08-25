/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <ObjectDoc/ObjectDoc.h>
#import "PLClangTestCase.h"

@interface PLClangTranslationUnitTests : PLClangTestCase @end

@implementation PLClangTranslationUnitTests

/**
 * Test basic parsing
 */
- (void) testParsing {
    NSError *error = nil;
    NSData *test = [@"int main (int argc, char *argv[]) { return 0; }" dataUsingEncoding: NSUTF8StringEncoding];
    PLClangTranslationUnit *tu = [_index addTranslationUnitWithSourcePath: @"test.c" fileData: test compilerArguments: @[] options: 0 error: &error];
    STAssertNotNil(tu, @"Failed to parse", nil);
    STAssertNil(error, @"Received error for successful parse");
    STAssertEqualObjects(tu.spelling, @"test.c", nil);
    STAssertNotNil(tu.cursor, @"Translation unit should have a cursor");
    STAssertEquals(tu.cursor.kind, PLClangCursorKindTranslationUnit, @"Cursor should be a translation unit cursor");

    STAssertFalse(tu.didFail, @"Should be marked as non-failed: %@", tu.diagnostics);
    STAssertTrue([tu.diagnostics count] == 0, @"No diagnostics should be returned");
}

/**
 * Test extraction of compiler diagnostics.
 */
- (void) testExtractDiagnostics {
    NSError *error = nil;
    NSData *test = [@"PARSE ERROR int main (int argc, char *argv[]) { return 0; }" dataUsingEncoding: NSUTF8StringEncoding];
    PLClangTranslationUnit *tu = [_index addTranslationUnitWithSourcePath: @"test.c" fileData: test compilerArguments: @[] options: 0 error: &error];
    STAssertNotNil(tu, @"Failed to parse", nil);
    STAssertNil(error, @"Received error for successful parse");
    STAssertEqualObjects(tu.spelling, @"test.c", nil);
    STAssertNotNil(tu.cursor, @"Translation unit should have a cursor");
    STAssertEquals(tu.cursor.kind, PLClangCursorKindTranslationUnit, @"Cursor should be a translation unit cursor");

    STAssertTrue(tu.didFail, @"Should be marked as failed");
    STAssertTrue([tu.diagnostics count] > 0, @"No diagnostics returned");
    for (PLClangDiagnostic *diag in tu.diagnostics) {
        STAssertNotNil(diag.formattedErrorMessage, @"No error message returned");
    }
}

/**
 * Test that macro definitions are included when the detailed preprocessing record is enabled.
 */
- (void) testDetailedPreprocessing {
    NSError *error = nil;
    NSData *test = [@"#define MACRO 1" dataUsingEncoding: NSUTF8StringEncoding];
    PLClangTranslationUnit *tu = [_index addTranslationUnitWithSourcePath: @"test.c" fileData: test compilerArguments: @[] options: 0 error: &error];
    STAssertNotNil(tu, @"Failed to parse", nil);
    STAssertNil(error, @"Received error for successful parse");
    STAssertEqualObjects(tu.spelling, @"test.c", nil);
    STAssertNotNil(tu.cursor, @"Translation unit should have a cursor");
    STAssertEquals(tu.cursor.kind, PLClangCursorKindTranslationUnit, @"Cursor should be a translation unit cursor");
    STAssertNil([tu cursorWithSpelling: @"MACRO"], @"Should not have found macro definition without detailed preprocessing record");

    tu = [_index addTranslationUnitWithSourcePath: @"test.c" fileData: test compilerArguments: @[] options: PLClangTranslationUnitCreationDetailedPreprocessingRecord error: &error];
    STAssertNotNil(tu, @"Failed to parse", nil);
    STAssertNil(error, @"Received error for successful parse");
    STAssertEqualObjects(tu.spelling, @"test.c", nil);
    STAssertNotNil(tu.cursor, @"Translation unit should have a cursor");
    STAssertEquals(tu.cursor.kind, PLClangCursorKindTranslationUnit, @"Cursor should be a translation unit cursor");
    STAssertNotNil([tu cursorWithSpelling: @"MACRO"], @"Should have found macro definition with detailed preprocessing record");
}

@end
