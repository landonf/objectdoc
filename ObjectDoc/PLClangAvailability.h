/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "PLClangPlatformAvailability.h"

@interface PLClangAvailability : NSObject

/**
 * A Boolean value indicating whether the entity is deprecated on all platforms.
 */
@property(nonatomic, readonly) BOOL isDeprecated;

/**
 * The message provided along with the unconditional deprecation of the entity, or nil if no message was provided.
 */
@property(nonatomic, readonly) NSString *deprecationMessage;

/**
 * A Boolean value indicating whether the entity is unavailable on all platforms.
 */
@property(nonatomic, readonly) BOOL isUnavailable;

/**
 * The message provided along with the unconditional unavailability of the entity, or nil if no message was provided.
 */
@property(nonatomic, readonly) NSString *unavailabilityMessage;

/**
 * An array of PLClangPlatformAvailability objects with plaform-specific availability information.
 */
@property(nonatomic, readonly) NSArray *platformAvailabilityEntries;

@end
