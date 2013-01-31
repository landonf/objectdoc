/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface PLSourceLocation : NSObject

- (id) initWithFilePath: (NSString *) filePath lineNumber: (NSUInteger) lineNumber columnNumber: (NSUInteger) columnNumber;

/**
 * The file's reported path. This is simply the path as provided to the compiler, and may
 * be relative to an arbitrary build root.
 */
@property(nonatomic, readonly) NSString *filePath;

/**
 * The line position (0-indexed).
 */
@property(nonatomic, readonly) NSUInteger lineNumber;

/**
 * The column position (0-indexed).
 */
@property(nonatomic, readonly) NSUInteger columnNumber;

@end