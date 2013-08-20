/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "PLClangVersion.h"

#import <clang-c/Index.h>

@interface PLClangVersion (PackagePrivate)

- (instancetype) initWithCXVersion: (CXVersion) version;

@end