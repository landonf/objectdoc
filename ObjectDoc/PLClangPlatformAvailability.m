/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLClangPlatformAvailability.h"
#import "PLClangPlatformAvailabilityPrivate.h"
#import "PLClangVersionPrivate.h"
#import "PLClangNSString.h"
#import "PLAdditions.h"

/**
 * Platform-specific availability information for an entity.
 */
@implementation PLClangPlatformAvailability

- (NSString *) description {
    NSMutableString *string = [NSMutableString stringWithString: self.platformName];

    if (self.introducedVersion) {
        [string appendFormat: @" introduced: %@", self.introducedVersion];
    }

    if (self.deprecatedVersion) {
        [string appendFormat: @" deprecated: %@", self.deprecatedVersion];
    }

    if (self.obsoletedVersion) {
        [string appendFormat: @" obsoleted: %@", self.obsoletedVersion];
    }

    if ([self.message length] > 0) {
        [string appendFormat: @" \"%@\"", self.message];
    }

    return string;
}

@end

/**
 * @internal
 * Package-private methods.
 */
@implementation PLClangPlatformAvailability (PackagePrivate)

/**
 * Initialize a newly-created platform availability instance with the specified clang platform availability information.
 *
 * @param availability The clang availability structure that will provide platform availability information.
 * @return An initialized availability instance.
 */
- (instancetype) initWithCXPlatformAvailability: (CXPlatformAvailability) availability {
    PLSuperInit();

    // The strings in CXPlatformAvailability are disposed via clang_disposeCXPlatformAvailability(), just convert them
    _platformName = plclang_convert_cxstring(availability.Platform);
    _message = plclang_convert_cxstring(availability.Message);
    _introducedVersion = [[PLClangVersion alloc] initWithCXVersion: availability.Introduced];
    _deprecatedVersion = [[PLClangVersion alloc] initWithCXVersion: availability.Deprecated];
    _obsoletedVersion = [[PLClangVersion alloc] initWithCXVersion: availability.Obsoleted];

    return self;
}

@end
