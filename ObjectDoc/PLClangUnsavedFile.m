/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLClangUnsavedFile.h"
#import "PLAdditions.h"

/**
 * The contents of a file within a translation unit that has not yet been saved to disk.
 */
@implementation PLClangUnsavedFile

- (instancetype) initWithPath: (NSString *) path data: (NSData *) data {
    PLSuperInit();

    _path = path;
    _data = data;

    return self;
}

/**
 * Creates and returns an unsaved file with the specified expected path and data.
 *
 * @param path The path where the file is expected to be saved. This is used when
 * evaluating inclusion directives within the translation unit.
 * @param data The unsaved data for this file.
 */
+ (instancetype) unsavedFileWithPath: (NSString *) path data: (NSData *) data {
    return [[self alloc] initWithPath: path data: data];
}

@end
