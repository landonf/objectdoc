/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "PLSourceLocation.h"

@interface PLClangDiagnostic : NSObject

/** The corresponding source location. */
@property(nonatomic, readonly) PLSourceLocation *sourceLocation;

@end