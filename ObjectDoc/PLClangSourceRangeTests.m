#import "PLClangTestCase.h"

@interface PLClangSourceRangeTests : PLClangTestCase
@end

@implementation PLClangSourceRangeTests

- (void) testRange {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;" path: @"test.c"];
    PLClangSourceRange *range = [[tu cursorWithSpelling: @"t"] extent];
    STAssertNotNil(range, @"Cursor should have an extent");
    STAssertNotNil(range.startLocation, nil);
    STAssertNotNil(range.endLocation, nil);

    STAssertEqualObjects(range.startLocation.path, @"test.c", nil);
    STAssertEquals(range.startLocation.fileOffset, (off_t)0, nil);
    STAssertEquals(range.startLocation.lineNumber, (NSUInteger)1, nil);
    STAssertEquals(range.startLocation.columnNumber, (NSUInteger)1, nil);

    STAssertEqualObjects(range.endLocation.path, @"test.c", nil);
    STAssertEquals(range.endLocation.fileOffset, (off_t)5, nil);
    STAssertEquals(range.endLocation.lineNumber, (NSUInteger)1, nil);
    STAssertEquals(range.endLocation.columnNumber, (NSUInteger)6, nil);
}

- (void) testEquality {
    PLClangSourceLocation *location1, *location2;
    PLClangSourceRange *range1, *range2;
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;" path: @"test.c"];
    location1 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                                offset: 0];
    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                                offset: 1];
    STAssertNotNil(location1, @"Failed to create location");
    STAssertNotNil(location2, @"Failed to create location");

    range1 = [[PLClangSourceRange alloc] initWithStartLocation: location1 endLocation: location2];

    location1 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                                offset: 0];
    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                                offset: 1];
    STAssertNotNil(location1, @"Failed to create location");
    STAssertNotNil(location2, @"Failed to create location");

    range2 = [[PLClangSourceRange alloc] initWithStartLocation: location1 endLocation: location2];
    STAssertEqualObjects(range1, range2, @"Ranges should be equal");

    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                                offset: 0];
    STAssertNotNil(location2, @"Failed to create location");

    range2 = [[PLClangSourceRange alloc] initWithStartLocation: location1 endLocation: location2];
    STAssertFalse([range1 isEqual: range2], @"Ranges should not be equal");
}

- (void) testInvalidRange {
    PLClangSourceRange *range;
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;" path: @"test.c"];
    PLClangSourceLocation *location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                                        file: @"test.c"
                                                                                      offset: 0];

    range = [[PLClangSourceRange alloc] initWithStartLocation: nil endLocation: nil];
    STAssertNil(range, nil);

    range = [[PLClangSourceRange alloc] initWithStartLocation: location endLocation: nil];
    STAssertNil(range, nil);

    range = [[PLClangSourceRange alloc] initWithStartLocation: nil endLocation: location];
    STAssertNil(range, nil);
}

@end
