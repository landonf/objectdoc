/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLSourceIndexer.h"

#include <clang-c/Index.h>
#include <clang-c/CXCompilationDatabase.h>

/**
 * Implements clang-based documentation indexing of source file(s).
 */
@implementation PLSourceIndexer {
@private
}

- (void) parseSomething {
    CXIndex idx;
    CXTranslationUnit tu;

    idx = clang_createIndex(1, 0);
    tu = clang_createTranslationUnitFromSourceFile(idx, "testing.m", 0, NULL, 0, NULL);

}

@end