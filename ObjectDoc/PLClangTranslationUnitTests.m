/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "PLClangSourceIndex.h"

@interface PLClangTranslationUnitTests : SenTestCase @end

@implementation PLClangTranslationUnitTests {
@private
    PLClangSourceIndex *_idx;
}

- (void) setUp {
    _idx = [[PLClangSourceIndex alloc] init];
}

/**
 * Test extraction of compiler diagnostics.
 */
- (void) testExtractDiagnostics {
    NSData *test = [@"PARSE ERROR int main (int argc, char *argv[]) { return 0; }" dataUsingEncoding: NSUTF8StringEncoding];
    PLClangTranslationUnit *tu = [_idx addTranslationUnitWithSourcePath: @"test.c" fileData: test compilerArguments: @[]];
    STAssertNotNil(tu, @"Failed to parse", nil);
    STAssertTrue([tu.diagnostics count] > 0, @"No diagnostics returned");
}

@end