#import "PLClangTestCase.h"

@interface PLClangAvailabilityTests : PLClangTestCase
@end

@implementation PLClangAvailabilityTests

- (void) testNoAvailability {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f();"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.availability.kind, PLClangAvailabilityKindAvailable);
    XCTAssertFalse(cursor.availability.isUnconditionallyDeprecated);
    XCTAssertFalse(cursor.availability.isUnconditionallyUnavailable);
    XCTAssertEqualObjects(cursor.availability.unconditionalDeprecationMessage, @"");
    XCTAssertEqualObjects(cursor.availability.unconditionalUnavailabilityMessage, @"");
    XCTAssertTrue([cursor.availability.platformAvailabilityEntries count] == 0);
}

- (void) testDeprecatedAttribute {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f() __attribute__((deprecated(\"message\")));"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.availability.kind, PLClangAvailabilityKindDeprecated);
    XCTAssertTrue(cursor.availability.isUnconditionallyDeprecated);
    XCTAssertFalse(cursor.availability.isUnconditionallyUnavailable);
    XCTAssertEqualObjects(cursor.availability.unconditionalDeprecationMessage, @"message");
    XCTAssertEqualObjects(cursor.availability.unconditionalUnavailabilityMessage, @"");
    XCTAssertTrue([cursor.availability.platformAvailabilityEntries count] == 0);

    tu = [self translationUnitWithSource: @"void f() __attribute__((deprecated));"];
    cursor = [tu cursorWithSpelling: @"f"];
    XCTAssertNotNil(cursor);
    XCTAssertTrue(cursor.availability.isUnconditionallyDeprecated);
    XCTAssertEqualObjects(cursor.availability.unconditionalDeprecationMessage, @"");
}

- (void) testUnavailableAttribute {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f() __attribute__((unavailable(\"message\")));"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.availability.kind, PLClangAvailabilityKindUnavailable);
    XCTAssertFalse(cursor.availability.isUnconditionallyDeprecated);
    XCTAssertTrue(cursor.availability.isUnconditionallyUnavailable);
    XCTAssertEqualObjects(cursor.availability.unconditionalDeprecationMessage, @"");
    XCTAssertEqualObjects(cursor.availability.unconditionalUnavailabilityMessage, @"message");
    XCTAssertTrue([cursor.availability.platformAvailabilityEntries count] == 0);

    tu = [self translationUnitWithSource: @"void f() __attribute__((unavailable));"];
    cursor = [tu cursorWithSpelling: @"f"];
    XCTAssertNotNil(cursor);
    XCTAssertTrue(cursor.availability.isUnconditionallyUnavailable);
    XCTAssertEqualObjects(cursor.availability.unconditionalUnavailabilityMessage, @"");
}

- (void) testDeprecatedAndUnavailable {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f() __attribute__((deprecated(\"deprecated\"))) __attribute__((unavailable(\"unavailable\")));"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.availability.kind, PLClangAvailabilityKindUnavailable);
    XCTAssertTrue(cursor.availability.isUnconditionallyDeprecated);
    XCTAssertTrue(cursor.availability.isUnconditionallyUnavailable);
    XCTAssertEqualObjects(cursor.availability.unconditionalDeprecationMessage, @"deprecated");
    XCTAssertEqualObjects(cursor.availability.unconditionalUnavailabilityMessage, @"unavailable");
    XCTAssertTrue([cursor.availability.platformAvailabilityEntries count] == 0);
}

- (void) testAvailabilityAttribute {
    PLClangTranslationUnit *tu = [self translationUnitWithSource: @"void f() __attribute__((availability(macos,introduced=10.4.3,deprecated=10.6,obsoleted=10.7,message=\"message\")));"];
    PLClangCursor *cursor = [tu cursorWithSpelling: @"f"];
    XCTAssertNotNil(cursor);
    XCTAssertEqual(cursor.availability.kind, PLClangAvailabilityKindUnavailable);
    XCTAssertFalse(cursor.availability.isUnconditionallyDeprecated, @"Cursor should not be unconditionally deprecated");
    XCTAssertFalse(cursor.availability.isUnconditionallyUnavailable, @"Cursor should not be unconditionally unavailable");
    XCTAssertTrue([cursor.availability.platformAvailabilityEntries count] == 1);

    PLClangPlatformAvailability *availability = cursor.availability.platformAvailabilityEntries[0];
    XCTAssertEqualObjects(availability.platformName, @"macos");
    XCTAssertEqualObjects(availability.message, @"message");

    XCTAssertEqual(availability.introducedVersion.major, 10);
    XCTAssertEqual(availability.introducedVersion.minor,  4);
    XCTAssertEqual(availability.introducedVersion.patch,  3);
    XCTAssertEqualObjects([availability.introducedVersion description], @"10.4.3");

    XCTAssertEqual(availability.deprecatedVersion.major, 10);
    XCTAssertEqual(availability.deprecatedVersion.minor,  6);
    XCTAssertEqual(availability.deprecatedVersion.patch, -1);
    XCTAssertEqualObjects([availability.deprecatedVersion description], @"10.6");

    XCTAssertEqual(availability.obsoletedVersion.major, 10);
    XCTAssertEqual(availability.obsoletedVersion.minor,  7);
    XCTAssertEqual(availability.obsoletedVersion.patch, -1);
    XCTAssertEqualObjects([availability.obsoletedVersion description], @"10.7");
}

@end
