/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "PLClangType.h"

#import <clang-c/Index.h>

@interface PLClangType (PackagePrivate)

- (instancetype) initWithCXType: (CXType) type;
- (CXType) cxType;

@end