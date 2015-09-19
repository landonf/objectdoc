/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */
#import <Foundation/Foundation.h>
#import <clang-c/Index.h>

#import "PLClangDiagnostic.h"

@interface PLClangDiagnostic (PackagePrivate)

- (instancetype) initWithCXDiagnostic: (CXDiagnostic) diagnostic;

@end
