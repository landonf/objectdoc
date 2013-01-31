/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLClangSourceLocation.h"
#import "PLClangSourceLocationPrivate.h"
#import "PLAdditions.h"

/**
 * A clang source location.
 */
@implementation PLClangSourceLocation {
@private
    /** The owner of the clang data structure backing _location. This is used
     * to ensure the lifetime of the CXSourceLocation. */
    id _owner;

    /** Backing clang source location. */
    CXSourceLocation _location;
}

@end

/**
 * @internal
 * Package-private methods.
 */
@implementation PLClangSourceLocation (PackagePrivate)

/**
 * Initialize with the source location
 *
 * @param owner An Objective-C reference to the owner of the sourceLocation value. This reference will
 * be retained, as to ensure that @a sourceLocation survives for the lifetime of the source location instance.
 * @param sourceLocation Backing clang location.
 */
- (instancetype) initWithOwner: (id) owner cxSourceLocation: (CXSourceLocation) sourceLocation {
    PLSuperInit();

    _owner = owner;
    _location = sourceLocation;

    return self;
}


@end