/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "PLClangTranslationUnit.h"

#import <clang-c/Index.h>

@interface PLClangCursor (PackagePrivate)

- (instancetype) initWithCXCursor: (CXCursor) cursor;
- (CXCursor) cxCursor;

@end