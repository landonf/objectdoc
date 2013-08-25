/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "PLClangToken.h"
@class PLClangCursor;
@class PLClangTranslationUnit;

#import <clang-c/Index.h>

@interface PLClangToken (PackagePrivate)

- (instancetype) initWithOwner: (id) owner
               translationUnit: (PLClangTranslationUnit *) translationUnit
                        cursor: (PLClangCursor *) cursor
                       cxToken: (CXToken) token;

@end
