/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <SenTestingKit/SenTestingKit.h>
#import <ObjectDoc/ObjectDoc.h>
#import "PLClangDiagnostic.h"

@interface PLClangTranslationUnitTests : SenTestCase @end

@implementation PLClangTranslationUnitTests {
@private
    PLClangSourceIndex *_idx;
}

- (void) setUp {
    _idx = [[PLClangSourceIndex alloc] init];
}

/**
 * Test basic parsing
 */
- (void) testParsing {
    NSData *test = [@"int main (int argc, char *argv[]) { return 0; }" dataUsingEncoding: NSUTF8StringEncoding];
    PLClangTranslationUnit *tu = [_idx addTranslationUnitWithSourcePath: @"test.c" fileData: test compilerArguments: @[]];
    STAssertNotNil(tu, @"Failed to parse", nil);

    STAssertFalse(tu.didFail, @"Should be marked as non-failed");
    STAssertTrue([tu.diagnostics count] == 0, @"No diagnostics should be returned");
}

/**
 * Test extraction of compiler diagnostics.
 */
- (void) testExtractDiagnostics {
    NSData *test = [@"PARSE ERROR int main (int argc, char *argv[]) { return 0; }" dataUsingEncoding: NSUTF8StringEncoding];
    PLClangTranslationUnit *tu = [_idx addTranslationUnitWithSourcePath: @"test.c" fileData: test compilerArguments: @[]];
    STAssertNotNil(tu, @"Failed to parse", nil);

    STAssertTrue(tu.didFail, @"Should be marked as failed");
    STAssertTrue([tu.diagnostics count] > 0, @"No diagnostics returned");
    for (PLClangDiagnostic *diag in tu.diagnostics) {
        STAssertNotNil(diag.formattedErrorMessage, @"No error message returned");
    }
}

@end