/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLClangVersion.h"
#import "PLClangVersionPrivate.h"
#import "PLAdditions.h"

/**
 * A version number.
 */
@implementation PLClangVersion

- (NSString *) description {
    NSMutableString *string = [NSMutableString stringWithFormat:@"%d", self.major];

    if (self.minor >= 0) {
        [string appendFormat:@".%d", self.minor];
    }

    if (self.patch >= 0) {
        [string appendFormat:@".%d", self.patch];
    }

    return string;
}

@end

/**
 * @internal
 * Package-private methods.
 */
@implementation PLClangVersion (PackagePrivate)

/**
 * Initialize a newly-created version with the specified clang version.
 *
 * @param version The clang version that will provide version information.
 * @return An initialized version.
 */
- (instancetype) initWithCXVersion: (CXVersion) version {
    PLSuperInit();

    // A negative major verison indicates that no version information was specified
    if (version.Major < 0)
        return nil;

    _major = version.Major;
    _minor = version.Minor;
    _patch = version.Subminor;

    return self;
}

@end
