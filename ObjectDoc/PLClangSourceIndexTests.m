/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <XCTest/XCTest.h>
#import "PLClangSourceIndex.h"
#import "PLClang.h"

@interface PLClangSourceIndexTests : XCTestCase @end

@implementation PLClangSourceIndexTests {
@private
}

- (void) testClangVersion {
    XCTAssertTrue([PLClangGetVersionString() length] > 0, @"A non-empty string should be returned for the clang version");
}

- (void) testAddTranslationUnitWithSourcePath {
    NSError *error = nil;
    NSData *test = [@"int main (int argc, char *argv[]) { return 0; }" dataUsingEncoding: NSUTF8StringEncoding];
    PLClangSourceIndex *idx = [PLClangSourceIndex new];
    PLClangTranslationUnit *tu = [idx addTranslationUnitWithSourcePath: @"test.c" fileData: test compilerArguments: @[] options: 0 error: &error];
    XCTAssertNotNil(tu, @"Failed to parse", nil);
    XCTAssertNil(error, @"Received error for successful parse");
}

- (void) testAddTranslationUnitWithMultipleUnsavedFiles {
    NSError *error = nil;
    NSData *header = [@"int f();" dataUsingEncoding: NSUTF8StringEncoding];
    NSData *source = [@"#include \"test.h\"\nint f () { return 0; }" dataUsingEncoding: NSUTF8StringEncoding];

    // Absolute paths are needed for clang to be able to resolve the include directive

    NSArray *files = @[
       [PLClangUnsavedFile unsavedFileWithPath: @"/tmp/test.h" data: header],
       [PLClangUnsavedFile unsavedFileWithPath: @"/tmp/test.c" data: source]
    ];

    PLClangSourceIndex *idx = [PLClangSourceIndex new];
    PLClangTranslationUnit *tu = [idx addTranslationUnitWithSourcePath: @"/tmp/test.c" unsavedFiles: files compilerArguments: @[] options: 0 error: &error];
    XCTAssertNotNil(tu, @"Failed to parse", nil);
    XCTAssertNil(error, @"Received error for successful parse");

    XCTAssertFalse(tu.didFail, @"Should be marked as non-failed: %@", tu.diagnostics);
    XCTAssertTrue([tu.diagnostics count] == 0, @"No diagnostics should be returned");
}

- (void) testFailedTranslationUnitCreation {
    NSError *error = nil;
    PLClangSourceIndex *idx = [PLClangSourceIndex new];
    PLClangTranslationUnit *tu = [idx addTranslationUnitWithSourcePath: @"notfound.c" fileData: nil compilerArguments: @[] options: 0 error: &error];
    XCTAssertNil(tu, @"Received a translation unit for a file that should not exist", nil);
    XCTAssertNotNil(error, @"No error received for failed parse");
    XCTAssertEqual(error.code, PLClangErrorCompiler);

    tu = [idx addTranslationUnitWithSourcePath: @"notfound.c" compilerArguments: @[] options: 0 error: &error];
    XCTAssertNil(tu, @"Received a translation unit for a file that should not exist", nil);
    XCTAssertNotNil(error, @"No error received for failed parse");
    XCTAssertEqual(error.code, PLClangErrorCompiler);

    tu = [idx addTranslationUnitWithASTPath: @"notfound.pch" error: &error];
    XCTAssertNil(tu, @"Received a translation unit for a file that should not exist", nil);
    XCTAssertNotNil(error, @"No error received for failed parse");
    XCTAssertEqual(error.code, PLClangErrorCompiler);
}

@end
