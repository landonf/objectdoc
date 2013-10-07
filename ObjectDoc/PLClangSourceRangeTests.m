#import "PLClangTestCase.h"

@interface PLClangSourceRangeTests : PLClangTestCase
@end

@implementation PLClangSourceRangeTests

- (void) testRange {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;" path: @"test.c"];
    PLClangSourceRange *range = [[tu cursorWithSpelling: @"t"] extent];
    XCTAssertNotNil(range, @"Cursor should have an extent");
    XCTAssertNotNil(range.startLocation);
    XCTAssertNotNil(range.endLocation);

    XCTAssertEqualObjects(range.startLocation.path, @"test.c");
    XCTAssertEqual(range.startLocation.fileOffset, (off_t)0);
    XCTAssertEqual(range.startLocation.lineNumber, (NSUInteger)1);
    XCTAssertEqual(range.startLocation.columnNumber, (NSUInteger)1);

    XCTAssertEqualObjects(range.endLocation.path, @"test.c");
    XCTAssertEqual(range.endLocation.fileOffset, (off_t)5);
    XCTAssertEqual(range.endLocation.lineNumber, (NSUInteger)1);
    XCTAssertEqual(range.endLocation.columnNumber, (NSUInteger)6);
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
    XCTAssertNotNil(location1, @"Failed to create location");
    XCTAssertNotNil(location2, @"Failed to create location");

    range1 = [[PLClangSourceRange alloc] initWithStartLocation: location1 endLocation: location2];

    location1 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                                offset: 0];
    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                                offset: 1];
    XCTAssertNotNil(location1, @"Failed to create location");
    XCTAssertNotNil(location2, @"Failed to create location");

    range2 = [[PLClangSourceRange alloc] initWithStartLocation: location1 endLocation: location2];
    XCTAssertEqualObjects(range1, range2, @"Ranges should be equal");

    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                                offset: 0];
    XCTAssertNotNil(location2, @"Failed to create location");

    range2 = [[PLClangSourceRange alloc] initWithStartLocation: location1 endLocation: location2];
    XCTAssertFalse([range1 isEqual: range2], @"Ranges should not be equal");
}

- (void) testInvalidRange {
    PLClangSourceRange *range;
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;" path: @"test.c"];
    PLClangSourceLocation *location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                                        file: @"test.c"
                                                                                      offset: 0];

    range = [[PLClangSourceRange alloc] initWithStartLocation: nil endLocation: nil];
    XCTAssertNil(range);

    range = [[PLClangSourceRange alloc] initWithStartLocation: location endLocation: nil];
    XCTAssertNil(range);

    range = [[PLClangSourceRange alloc] initWithStartLocation: nil endLocation: location];
    XCTAssertNil(range);
}

@end
