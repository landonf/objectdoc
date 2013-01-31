/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "PLClangSourceIndex.h"

@interface PLClangSourceIndexTests : SenTestCase @end

@implementation PLClangSourceIndexTests {
@private
}

- (void) testAddTranslationUnitWithSourcePath {
    NSData *test = [@"sdfdsf int main (int argc, char *argv[]) { return 0; }" dataUsingEncoding: NSUTF8StringEncoding];
    PLClangSourceIndex *idx = [PLClangSourceIndex new];
    PLClangTranslationUnit *tu = [idx addTranslationUnitWithSourcePath: @"test.c" fileData: test compilerArguments: @[
        @"-std=c99"
    ]];
    STAssertNotNil(tu, @"Failed to parse", nil);
}

@end