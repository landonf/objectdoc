/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "PLSourceIndex.h"

@interface PLSourceIndexTests : SenTestCase @end

@implementation PLSourceIndexTests {
@private
}

- (void) testAddTranslationUnitWithSourcePath {
    NSData *test = [@"sdfdsf int main (int argc, char *argv[]) { return 0; }" dataUsingEncoding: NSUTF8StringEncoding];
    PLSourceIndex *idx = [PLSourceIndex new];
    PLTranslationUnit *tu = [idx addTranslationUnitWithSourcePath: @"test.c" fileData: test compilerArguments: @[
        @"-std=c99"
    ]];
    STAssertNotNil(tu, @"Failed to parse", nil);
}

@end