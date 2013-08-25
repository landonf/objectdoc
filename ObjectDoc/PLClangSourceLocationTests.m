#import "PLClangTestCase.h"

@interface PLClangSourceLocationTests : PLClangTestCase
@end

@implementation PLClangSourceLocationTests

- (void) testLocation {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;" path: @"test.c"];
    PLClangSourceLocation *location = [[tu cursorWithSpelling: @"t"] location];
    STAssertNotNil(location, @"Cursor should have a source location");

    STAssertEqualObjects(location.path, @"test.c", nil);
    STAssertEquals(location.fileOffset, (off_t)4, nil);
    STAssertEquals(location.lineNumber, (NSUInteger)1, nil);
    STAssertEquals(location.columnNumber, (NSUInteger)5, nil);
}

- (void) testLocationContainment {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"#include <stdio.h>\nint t;"];
    PLClangSourceLocation *location = [[tu cursorWithSpelling: @"printf"] location];
    STAssertNotNil(location, @"Cursor should have a source location");

    STAssertTrue(location.isInSystemHeader, nil);
    STAssertFalse(location.isInMainFile, nil);

    location = [[tu cursorWithSpelling: @"t"] location];
    STAssertNotNil(location, @"Cursor should have a source location");

    STAssertFalse(location.isInSystemHeader, nil);
    STAssertTrue(location.isInMainFile, nil);
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
    STAssertNotNil(location1, @"Failed to create location");
    STAssertNotNil(location2, @"Failed to create location");
    STAssertEqualObjects(location1, location2, @"Locations should be equal");

    location1 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 1
                                                          columnNumber: 1];
    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 1
                                                          columnNumber: 1];
    STAssertNotNil(location1, @"Failed to create location");
    STAssertNotNil(location2, @"Failed to create location");
    STAssertEqualObjects(location1, location2, @"Locations should be equal");

    location1 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                                offset: 0];
    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 1
                                                          columnNumber: 1];
    STAssertNotNil(location1, @"Failed to create location");
    STAssertNotNil(location2, @"Failed to create location");
    STAssertEqualObjects(location1, location2, @"Locations should be equal");

    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 1
                                                          columnNumber: 2];
    STAssertNotNil(location2, @"Failed to create location");
    STAssertFalse([location1 isEqual: location2], @"Locations should not be equal");

    location1 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 1
                                                          columnNumber: 1];
    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 2
                                                          columnNumber: 1];
    STAssertNotNil(location1, @"Failed to create location");
    STAssertNotNil(location2, @"Failed to create location");
    STAssertFalse([location1 isEqual: location2], @"Locations should not be equal");

    location1 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 1
                                                          columnNumber: 1];
    location2 = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                  file: @"test.c"
                                                            lineNumber: 1
                                                          columnNumber: 2];
    STAssertNotNil(location1, @"Failed to create location");
    STAssertNotNil(location2, @"Failed to create location");
    STAssertFalse([location1 isEqual: location2], @"Locations should not be equal");
}

- (void) testLocationCreation {
    PLClangSourceLocation *location;
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;" path: @"test.c"];
    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: @"test.c"
                                                               offset: 1];
    STAssertNotNil(location, @"Failed to create location");
    STAssertEqualObjects(location.path, @"test.c", nil);
    STAssertEquals(location.fileOffset, (off_t)1, nil);
    STAssertEquals(location.lineNumber, (NSUInteger)1, nil);
    STAssertEquals(location.columnNumber, (NSUInteger)2, nil);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: @"test.c"
                                                           lineNumber: 1
                                                         columnNumber: 3];
    STAssertNotNil(location, @"Failed to create location");
    STAssertEqualObjects(location.path, @"test.c", nil);
    STAssertEquals(location.fileOffset, (off_t)2, nil);
    STAssertEquals(location.lineNumber, (NSUInteger)1, nil);
    STAssertEquals(location.columnNumber, (NSUInteger)3, nil);
}

- (void) testInvalidLocations {
    PLClangSourceLocation *location;
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"int t;" path: @"test.c"];

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: nil
                                                                 file: @"test.c"
                                                               offset: 0];
    STAssertNil(location, nil);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: nil
                                                                 file: @"test.c"
                                                           lineNumber: 1
                                                         columnNumber: 1];
    STAssertNil(location, nil);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: nil
                                                               offset: 0];
    STAssertNil(location, nil);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: nil
                                                           lineNumber: 1
                                                         columnNumber: 1];
    STAssertNil(location, nil);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: @"test.c"
                                                               offset: 1000];
    STAssertNil(location, nil);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: @"test.c"
                                                           lineNumber: 1
                                                         columnNumber: 1000];
    STAssertNil(location, nil);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: @"test.c"
                                                           lineNumber: 1000
                                                         columnNumber: 1];
    STAssertNil(location, nil);

    location = [[PLClangSourceLocation alloc] initWithTranslationUnit: tu
                                                                 file: @"test.c"
                                                           lineNumber: 1000
                                                         columnNumber: 1000];
    STAssertNil(location, nil);
}

@end
