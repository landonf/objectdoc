/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "PLClangAvailability.h"

#import <clang-c/Index.h>

@interface PLClangAvailability (PackagePrivate)

- (instancetype) initWithCXCursor: (CXCursor) cursor;

@end
