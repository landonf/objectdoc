/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLClangSourceRange.h"
#import "PLClangSourceLocationPrivate.h"
#import "PLAdditions.h"

/**
 * A source range within a translation unit.
 */
@implementation PLClangSourceRange

/**
 * Initialize a newly-created source range with the specified start and end locations.
 *
 * @param startLocation The source location to mark the start of the range.
 * @param endLocation The source location to mark the end of the range.
 * @return An initialized source range or nil if the start or end locations were invalid.
 */
- (instancetype) initWithStartLocation: (PLClangSourceLocation *) startLocation endLocation: (PLClangSourceLocation *) endLocation {
    PLSuperInit();

    if (startLocation == nil || endLocation == nil)
        return nil;

    _startLocation = startLocation;
    _endLocation = endLocation;

    return self;
}

- (BOOL) isEqual: (id) object {
    if (![object isKindOfClass: [PLClangSourceRange class]])
        return NO;

    return [self.startLocation isEqual: [object startLocation]] &&
           [self.endLocation isEqual: [object endLocation]];
}

- (NSUInteger) hash {
    return [self.startLocation hash] ^ [self.endLocation hash];
}

- (NSString *) description {
    return [NSString stringWithFormat: @"{ %@, %@ }",
            self.startLocation,
            self.endLocation];
}

@end

/**
 * @internal
 * Package-private methods.
 */
@implementation PLClangSourceRange (PackagePrivate)

/**
 * Initialize a newly-created source range with the specified clang source range.
 *
 * @param owner A reference to the owner of the clang source range. This reference will be retained
 * to ensure that the clang source range survives for the lifetime of this source range instance.
 * @param sourceRange The clang source range that will back this object.
 * @return An initialized source range or nil if a null clang source range was provided.
 */
- (instancetype) initWithOwner: (id) owner cxSourceRange: (CXSourceRange) sourceRange {
    if (clang_Range_isNull(sourceRange))
        return nil;

    PLClangSourceLocation* startLocation = [[PLClangSourceLocation alloc] initWithOwner: owner cxSourceLocation: clang_getRangeStart(sourceRange)];
    PLClangSourceLocation* endLocation = [[PLClangSourceLocation alloc] initWithOwner: owner cxSourceLocation: clang_getRangeEnd(sourceRange)];

    return [self initWithStartLocation: startLocation endLocation: endLocation];
}

- (CXSourceRange) cxSourceRange {
    return clang_getRange([self.startLocation cxSourceLocation], [self.endLocation cxSourceLocation]);
}

@end
