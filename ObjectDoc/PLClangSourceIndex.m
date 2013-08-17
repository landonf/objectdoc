/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLClangSourceIndex.h"
#import "PLAdditions.h"
#import "PLClangTranslationUnitPrivate.h"

#import <clang-c/Index.h>

/**
 * Maintains a set of PLTranslationUnits that would typically be linked together into
 * a single executable or library.
 */
@implementation PLClangSourceIndex {
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

/**
 * Add a new translation unit to the receiver.
 *
 * @param The on-disk path to the source file.
 * @param data The source file's data.
 * @param arguments Any additional clang compiler arguments to be used when parsing the translation unit.
 * @param options The options to use when creating the translation unit.
 *
 * @todo Investigate support for providing multiple in-memory files (pchs?)
 */
- (PLClangTranslationUnit *) addTranslationUnitWithSourcePath: (NSString *) path fileData: (NSData *) data compilerArguments: (NSArray *) arguments options: (PLClangTranslationUnitCreationOptions) options {
    /* NOTE: This implementation fetches backing data/string pointers from the passed in Objective-C arguments; these values
     * are not guaranteed to survive past the lifetime of the current autorelease pool. */
    CXTranslationUnit tu;
    char **argv = calloc(sizeof(char *), [arguments count]);
    const char *cPath = NULL;
    struct CXUnsavedFile unsavedFile;
    unsigned int unsavedFileCount = 0;
    unsigned int creationOptions = 0;

    if (path != nil)
        cPath = [path fileSystemRepresentation];

    if (data != nil) {
        unsavedFileCount = 1;
        unsavedFile.Contents = [data bytes];
        unsavedFile.Length = [data length];
        unsavedFile.Filename = [path fileSystemRepresentation];
    }

    for (NSUInteger i = 0; i < [arguments count]; i++)
        argv[i] = (char *) [[arguments objectAtIndex: i] UTF8String];

    if (options & PLClangTranslationUnitCreationDetailedPreprocessingRecord)
        creationOptions |= CXTranslationUnit_DetailedPreprocessingRecord;

    if (options & PLClangTranslationUnitCreationIncomplete)
        creationOptions |= CXTranslationUnit_Incomplete;

    if (options & PLClangTranslationUnitCreationPrecompilePreamble)
        creationOptions |= CXTranslationUnit_PrecompiledPreamble;

    if (options & PLClangTranslationUnitCreationCacheCodeCompletionResults)
        creationOptions |= CXTranslationUnit_CacheCompletionResults;

    if (options & PLClangTranslationUnitCreationForSerialization)
        creationOptions |= CXTranslationUnit_ForSerialization;

    if (options & PLClangTranslationUnitCreationSkipFunctionBodies)
        creationOptions |= CXTranslationUnit_SkipFunctionBodies;

    if (options & PLClangTranslationUnitCreationIncludeBriefCommentsInCodeCompletion)
        creationOptions |= CXTranslationUnit_IncludeBriefCommentsInCodeCompletion;

    tu = clang_parseTranslationUnit(_cIndex,
            [path fileSystemRepresentation],
            (const char **) argv,
            [arguments count],
            unsavedFileCount ? &unsavedFile : NULL,
            unsavedFileCount,
            creationOptions);

    free(argv);

    if (tu == NULL) {
        // TODO - report error?
        return nil;
    }

    PLClangTranslationUnit *pltu = [[PLClangTranslationUnit alloc] initWithCXTranslationUnit: tu];
    [_translationUnits addObject: pltu];

    return pltu;
}

/**
 * Add a new translation unit to the receiver.
 *
 * @param arguments Clang compiler arguments to be used when reading the translation unit. The path to
 * the source file must be provided as a compiler argument.
 * @param options The options to use when creating the translation unit.
 */
- (PLClangTranslationUnit *) addTranslationUnitWithCompilerArguments: (NSArray *) arguments options: (PLClangTranslationUnitCreationOptions) options {
    return [self addTranslationUnitWithSourcePath: nil fileData: nil compilerArguments: arguments options: options];
}

/**
 * Add a new translation unit to the receiver.
 *
 * @param The on-disk path to the source file.
 * @param arguments Any additional clang compiler arguments to be used when parsing the translation unit.
 * @param options The options to use when creating the translation unit.
 */
- (PLClangTranslationUnit *) addTranslationUnitWithSourcePath: (NSString *) path compilerArguments: (NSArray *) arguments options: (PLClangTranslationUnitCreationOptions) options {
    return [self addTranslationUnitWithSourcePath: path fileData: nil compilerArguments: arguments options: options];
}


- (void) dealloc {
    if (_cIndex != NULL)
        clang_disposeIndex(_cIndex);
}

@end