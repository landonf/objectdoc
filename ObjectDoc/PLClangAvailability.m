/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLClangAvailability.h"
#import "PLClangAvailabilityPrivate.h"
#import "PLClangPlatformAvailabilityPrivate.h"
#import "PLClangNSString.h"
#import "PLAdditions.h"

/**
 * Availability information for an entity.
 */
@implementation PLClangAvailability

- (NSString *) description {
    NSMutableString *string = [NSMutableString string];

    if (!self.isDeprecated && !self.isUnavailable)
        [string appendString: @"available"];

    if (self.isDeprecated) {
        [string appendString: @"deprecated"];
        if ([self.deprecationMessage length] > 0) {
            [string appendFormat: @": \"%@\"", self.deprecationMessage];
        }
    }

    if (self.isUnavailable) {
        if ([string length] > 0) {
            [string appendString: @"\n"];
        }

        [string appendString: @"unavailable"];
        if ([self.unavailabilityMessage length] > 0) {
            [string appendFormat: @": \"%@\"", self.unavailabilityMessage];
        }
    }

    if ([self.platformAvailabilityEntries count] > 0) {
        [string appendFormat: @"\n%@", self.platformAvailabilityEntries];
    }

    return string;
}

@end

/**
 * @internal
 * Package-private methods.
 */
@implementation PLClangAvailability (PackagePrivate)

/**
 * Initialize a newly-created availability instance with the specified clang cursor.
 *
 * @param cursor The clang cursor that will provide availability information.
 * @return An initialized availability instance.
 */
- (instancetype) initWithCXCursor: (CXCursor) cursor {
    PLSuperInit();

    // Get the number of platform availability entries
    int platformCount = clang_getCursorPlatformAvailability(cursor, NULL, NULL, NULL, NULL, NULL, 0);
    NSAssert(platformCount >= 0, @"clang_getCursorPlatformAvailability() returned a negative number of platforms");

    int always_deprecated = 0;
    int always_unavailable = 0;
    CXString deprecationString = {};
    CXString unavilableString = {};
    CXPlatformAvailability *platformAvailability = calloc((unsigned int)platformCount, sizeof(CXPlatformAvailability));
    clang_getCursorPlatformAvailability(cursor,
                                        &always_deprecated,
                                        &deprecationString,
                                        &always_unavailable,
                                        &unavilableString,
                                        platformAvailability,
                                        platformCount);

    _isDeprecated = always_deprecated;
    _isUnavailable = always_unavailable;
    _deprecationMessage = plclang_convert_and_dispose_cxstring(deprecationString);
    _unavailabilityMessage = plclang_convert_and_dispose_cxstring(unavilableString);

    NSMutableArray *entries = [NSMutableArray array];

    for (int i = 0; i < platformCount; i++) {
        PLClangPlatformAvailability *availability = [[PLClangPlatformAvailability alloc] initWithCXPlatformAvailability: platformAvailability[i]];
        [entries addObject: availability];
        clang_disposeCXPlatformAvailability(&platformAvailability[i]);
    }

    _platformAvailabilityEntries = [entries copy];
    free(platformAvailability);

    return self;
}

@end
