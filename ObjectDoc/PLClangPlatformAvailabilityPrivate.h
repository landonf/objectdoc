/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "PLClangPlatformAvailability.h"

#import <clang-c/Index.h>

@interface PLClangPlatformAvailability (PackagePrivate)

- (instancetype) initWithCXPlatformAvailability: (CXPlatformAvailability) availability;

@end
