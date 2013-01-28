/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLSourceIndex.h"
#import "PLAdditions.h"
#import "PLTranslationUnitPrivate.h"

#import <clang-c/Index.h>

/**
 * Maintains a set of PLTranslationUnits that would typically be linked together into
 * a single executable or library.
 */
@implementation PLSourceIndex {
@private
    /** Backing clang index. */
    CXIndex _cIndex;

    /** Parsed translation units */
    NSMutableArray *_translationUnits;
}

- (id) init {
    PLSuperInit();

    _cIndex = clang_createIndex(0, 0);
    _translationUnits = [NSMutableArray array];

    return self;
}

- (PLTranslationUnit *) addTranslationUnitWithCompilerArguments: (NSArray *) arguments {
    // TODO
    return nil;
}

- (PLTranslationUnit *) addTranslationUnitWithSourcePath: (NSString *) path fileData: (NSData *) data compilerArguments: (NSArray *) arguments {
    // TODO
    return nil;
}

- (PLTranslationUnit *) addTranslationUnitWithSourcePath: (NSString *) path compilerArguments: (NSArray *) arguments {
    CXTranslationUnit tu;
    tu = clang_parseTranslationUnit(_cIndex, [path fileSystemRepresentation], NULL, 0, NULL, 0, CXTranslationUnit_DetailedPreprocessingRecord);
    if (tu == NULL) {
        // TODO - report error?
        return nil;
    }

    return [[PLTranslationUnit alloc] initWithCXTranslationUnit: tu];
}


- (void) dealloc {
    if (_cIndex != NULL)
        clang_disposeIndex(_cIndex);
}

@end