/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */
#import <Foundation/Foundation.h>
#import <clang-c/Index.h>

#import "PLClangSourceLocation.h"

@interface PLClangSourceLocation (PackagePrivate)

- (instancetype) initWithOwner: (id) owner cxSourceLocation: (CXSourceLocation) sourceLocation;

@end