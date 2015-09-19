/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "PLClangComment.h"

#import <clang-c/Index.h>
#import <clang-c/Documentation.h>

@interface PLClangComment (PackagePrivate)

- (instancetype) initWithOwner: (id) owner cxComment: (CXComment) comment;

@end
