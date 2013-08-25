/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "PLClangSourceRange.h"

#import <clang-c/Index.h>

@interface PLClangSourceRange (PackagePrivate)

- (instancetype) initWithOwner: (id) owner cxSourceRange: (CXSourceRange) sourceRange;

@end
