#import "PLClangTestCase.h"

@interface PLClangSourceLocationTests : PLClangTestCase
@end

@implementation PLClangSourceLocationTests

- (void) testLocation {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;" path: @"test.c"];
    PLClangSourceLocation *location = [[tu cursorWithSpelling: @"t"] location];
    XCTAssertNotNil(location, @"Cursor should have a source location");

    XCTAssertEqualObjects(location.path, @"test.c");
    XCTAssertEqual(location.fileOffset, (off_t)4);
    XCTAssertEqual(location.lineNumber, (NSUInteger)1);
    XCTAssertEqual(location.columnNumber, (NSUInteger)5);
}

- (void) testLocationContainment {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"#include <stdio.h>\nint t;"];
    PLClangSourceLocation *location = [[tu cursorWithSpelling: @"printf"] location];
    XCTAssertNotNil(location, @"Cursor should have a source location");

    XCTAssertTrue(location.isInSystemHeader);
    XCTAssertFalse(location.isInMainFile);

    location = [[tu cursorWithSpelling: @"t"] location];
    XCTAssertNotNil(location, @"Cursor should have a source location");

    XCTAssertFalse(location.isInSystemHeader);
    XCTAssertTrue(location.isInMainFile);
}

- (void) testEquality {
    PLClangSourceLocation *location1, *location2;
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;\nt = 1;" path: @"test.c"];
    location1 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                                offset: 0];
    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                                offset: 0];
    XCTAssertNotNil(location1, @"Failed to create location");
    XCTAssertNotNil(location2, @"Failed to create location");
    XCTAssertEqualObjects(location1, location2, @"Locations should be equal");

    location1 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 1
                                                          columnNumber: 1];
    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 1
                                                          columnNumber: 1];
    XCTAssertNotNil(location1, @"Failed to create location");
    XCTAssertNotNil(location2, @"Failed to create location");
    XCTAssertEqualObjects(location1, location2, @"Locations should be equal");

    location1 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                                offset: 0];
    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 1
                                                          columnNumber: 1];
    XCTAssertNotNil(location1, @"Failed to create location");
    XCTAssertNotNil(location2, @"Failed to create location");
    XCTAssertEqualObjects(location1, location2, @"Locations should be equal");

    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 1
                                                          columnNumber: 2];
    XCTAssertNotNil(location2, @"Failed to create location");
    XCTAssertFalse([location1 isEqual: location2], @"Locations should not be equal");

    location1 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 1
                                                          columnNumber: 1];
    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 2
                                                          columnNumber: 1];
    XCTAssertNotNil(location1, @"Failed to create location");
    XCTAssertNotNil(location2, @"Failed to create location");
    XCTAssertFalse([location1 isEqual: location2], @"Locations should not be equal");

    location1 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 1
                                                          columnNumber: 1];
    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 1
                                                          columnNumber: 2];
    XCTAssertNotNil(location1, @"Failed to create location");
    XCTAssertNotNil(location2, @"Failed to create location");
    XCTAssertFalse([location1 isEqual: location2], @"Locations should not be equal");
}

- (void) testLocationCreation {
    PLClangSourceLocation *location;
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;" path: @"test.c"];
    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: @"test.c"
                                                               offset: 1];
    XCTAssertNotNil(location, @"Failed to create location");
    XCTAssertEqualObjects(location.path, @"test.c");
    XCTAssertEqual(location.fileOffset, (off_t)1);
    XCTAssertEqual(location.lineNumber, (NSUInteger)1);
    XCTAssertEqual(location.columnNumber, (NSUInteger)2);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: @"test.c"
                                                           lineNumber: 1
                                                         columnNumber: 3];
    XCTAssertNotNil(location, @"Failed to create location");
    XCTAssertEqualObjects(location.path, @"test.c");
    XCTAssertEqual(location.fileOffset, (off_t)2);
    XCTAssertEqual(location.lineNumber, (NSUInteger)1);
    XCTAssertEqual(location.columnNumber, (NSUInteger)3);
}

- (void) testInvalidLocations {
    PLClangSourceLocation *location;
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;" path: @"test.c"];

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: nil
                                                                 file: @"test.c"
                                                               offset: 0];
    XCTAssertNil(location);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: nil
                                                                 file: @"test.c"
                                                           lineNumber: 1
                                                         columnNumber: 1];
    XCTAssertNil(location);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: nil
                                                               offset: 0];
    XCTAssertNil(location);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: nil
                                                           lineNumber: 1
                                                         columnNumber: 1];
    XCTAssertNil(location);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: @"test.c"
                                                               offset: 1000];
    XCTAssertNil(location);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: @"test.c"
                                                           lineNumber: 1
                                                         columnNumber: 1000];
    XCTAssertNil(location);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: @"test.c"
                                                           lineNumber: 1000
                                                         columnNumber: 1];
    XCTAssertNil(location);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: @"test.c"
                                                           lineNumber: 1000
                                                         columnNumber: 1000];
    XCTAssertNil(location);
}

@end
