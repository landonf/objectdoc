/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "PLClangCursor.h"

#import <clang-c/Index.h>

@interface PLClangCursor (PackagePrivate)

- (instancetype) initWithOwner: (id) owner cxCursor: (CXCursor) cursor;
- (CXCursor) cxCursor;

@end