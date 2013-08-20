#import "PLClangTestCase.h"

@interface PLClangAvailabilityTests : PLClangTestCase
@end

@implementation PLClangAvailabilityTests

- (void) testNoAvailability {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f();"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    STAssertNotNil(cursor, nil);
    STAssertFalse(cursor.availability.isDeprecated, nil);
    STAssertFalse(cursor.availability.isUnavailable, nil);
    STAssertEqualObjects(cursor.availability.deprecationMessage, @"", nil);
    STAssertEqualObjects(cursor.availability.unavailabilityMessage, @"", nil);
    STAssertTrue([cursor.availability.platformAvailabilityEntries count] == 0, nil);
}

- (void) testDeprecatedAttribute {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f() __attribute__((deprecated(\"message\")));"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    STAssertNotNil(cursor, nil);
    STAssertTrue(cursor.availability.isDeprecated, nil);
    STAssertFalse(cursor.availability.isUnavailable, nil);
    STAssertEqualObjects(cursor.availability.deprecationMessage, @"message", nil);
    STAssertEqualObjects(cursor.availability.unavailabilityMessage, @"", nil);
    STAssertTrue([cursor.availability.platformAvailabilityEntries count] == 0, nil);

    tu = [self translationUnitWithSource: @"void f() __attribute__((deprecated));"];
    cursor = [tu cursorWithSpelling: @"f"];
    STAssertNotNil(cursor, nil);
    STAssertTrue(cursor.availability.isDeprecated, nil);
    STAssertEqualObjects(cursor.availability.deprecationMessage, @"", nil);
}

- (void) testUnavailableAttribute {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f() __attribute__((unavailable(\"message\")));"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    STAssertNotNil(cursor, nil);
    STAssertFalse(cursor.availability.isDeprecated, nil);
    STAssertTrue(cursor.availability.isUnavailable, nil);
    STAssertEqualObjects(cursor.availability.deprecationMessage, @"", nil);
    STAssertEqualObjects(cursor.availability.unavailabilityMessage, @"message", nil);
    STAssertTrue([cursor.availability.platformAvailabilityEntries count] == 0, nil);

    tu = [self translationUnitWithSource: @"void f() __attribute__((unavailable));"];
    cursor = [tu cursorWithSpelling: @"f"];
    STAssertNotNil(cursor, nil);
    STAssertTrue(cursor.availability.isUnavailable, nil);
    STAssertEqualObjects(cursor.availability.unavailabilityMessage, @"", nil);
}

- (void) testDeprecatedAndUnavailable {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f() __attribute__((deprecated(\"deprecated\"))) __attribute__((unavailable(\"unavailable\")));"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    STAssertNotNil(cursor, nil);
    STAssertTrue(cursor.availability.isDeprecated, nil);
    STAssertTrue(cursor.availability.isUnavailable, nil);
    STAssertEqualObjects(cursor.availability.deprecationMessage, @"deprecated", nil);
    STAssertEqualObjects(cursor.availability.unavailabilityMessage, @"unavailable", nil);
    STAssertTrue([cursor.availability.platformAvailabilityEntries count] == 0, nil);
}

- (void) testAvailabilityAttribute {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f() __attribute__((availability(macosx,introduced=10.4.3,deprecated=10.6,obsoleted=10.7,message=\"message\")));"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    STAssertNotNil(cursor, nil);
    STAssertFalse(cursor.availability.isDeprecated, @"Cursor should not be unconditionally deprecated");
    STAssertFalse(cursor.availability.isUnavailable, @"Cursor should not be unconditionally unavailable");
    STAssertTrue([cursor.availability.platformAvailabilityEntries count] == 1, nil);

    PLClangPlatformAvailability *availability = cursor.availability.platformAvailabilityEntries[0];
    STAssertEqualObjects(availability.platformName, @"macosx", nil);
    STAssertEqualObjects(availability.message, @"message", nil);

    STAssertEquals(availability.introducedVersion.major, 10, nil);
    STAssertEquals(availability.introducedVersion.minor,  4, nil);
    STAssertEquals(availability.introducedVersion.patch,  3, nil);
    STAssertEqualObjects([availability.introducedVersion description], @"10.4.3", nil);

    STAssertEquals(availability.deprecatedVersion.major, 10, nil);
    STAssertEquals(availability.deprecatedVersion.minor,  6, nil);
    STAssertEquals(availability.deprecatedVersion.patch, -1, nil);
    STAssertEqualObjects([availability.deprecatedVersion description], @"10.6", nil);

    STAssertEquals(availability.obsoletedVersion.major, 10, nil);
    STAssertEquals(availability.obsoletedVersion.minor,  7, nil);
    STAssertEquals(availability.obsoletedVersion.patch, -1, nil);
    STAssertEqualObjects([availability.obsoletedVersion description], @"10.7", nil);
}

@end
