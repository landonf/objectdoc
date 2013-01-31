/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLSourceLocation.h"
#import "PLAdditions.h"

/**
 * PLSourceLocation represents a specific source location based on file name,
 * line number, and column number.
 */
@implementation PLSourceLocation {
@private
}

/**
 * Initialize a new source location instance.
 *
 * @param filePath The file's reported path. This is simply the path as provided to the compiler, and may
 * be relative to an arbitrary build root.
 * @param lineNumber The line position (0-indexed).
 * @param columnNumber The column position (0-indexed).
 */
- (id) initWithFilePath: (NSString *) filePath lineNumber: (NSUInteger) lineNumber columnNumber: (NSUInteger) columnNumber {
    PLSuperInit();

    _filePath = filePath;
    _lineNumber = lineNumber;
    _columnNumber = columnNumber;

    return self;
}

@end