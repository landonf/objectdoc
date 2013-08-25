/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLClangSourceIndex.h"
#import "PLAdditions.h"
#import "PLClang.h"
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
}

- (id) init {
    PLSuperInit();

    _cIndex = clang_createIndex(0, 0);

    return self;
}

/**
 * Add a new translation unit to the receiver.
 *
 * @param The on-disk path to the source file. May be nil if the path to the file is provided via compiler arguments.
 * @param files An array of PLClangUnsavedFile objects representing unsaved data for files within the translation unit.
 * This can include the main source file as well as any dependent headers. May be nil.
 * @param arguments Any additional clang compiler arguments to be used when parsing the translation unit.
 * @param options The options to use when creating the translation unit.
 * @param error If an error occurs, upon return contains an NSError object that describes the problem.
 * If you are not interested in possible errors, pass in nil.
 */
- (PLClangTranslationUnit *) addTranslationUnitWithSourcePath: (NSString *) path unsavedFiles: (NSArray *) files compilerArguments: (NSArray *) arguments options: (PLClangTranslationUnitCreationOptions) options error: (NSError **)error; {
    /* NOTE: This implementation fetches backing data/string pointers from the passed in Objective-C arguments; these values
     * are not guaranteed to survive past the lifetime of the current autorelease pool. */
    CXTranslationUnit tu;
    char **argv = calloc(sizeof(char *), [arguments count]);
    const char *cPath = NULL;
    struct CXUnsavedFile *unsavedFiles = NULL;
    unsigned int unsavedFileCount = 0;
    unsigned int creationOptions = 0;

    if (error)
        *error = nil;

    if (path != nil)
        cPath = [path fileSystemRepresentation];

    if ([files count] > 0) {
        unsavedFileCount = [files count];
        unsavedFiles = (struct CXUnsavedFile *)calloc(unsavedFileCount, sizeof(struct CXUnsavedFile));

        for (unsigned int i = 0; i < unsavedFileCount; i++) {
            PLClangUnsavedFile *file = files[i];
            if (![file isKindOfClass: [PLClangUnsavedFile class]])
                continue;

            unsavedFiles[i].Contents = [file.data bytes];
            unsavedFiles[i].Length = [file.data length];
            unsavedFiles[i].Filename = [file.path fileSystemRepresentation];
        }
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
            unsavedFiles,
            unsavedFileCount,
            creationOptions);

    free(argv);
    free(unsavedFiles);

    if (tu == NULL) {
        // libclang does not currently report why creation of a translation unit failed or provide
        // access to the associated diagnostics, so for now we can only return a generic failure.
        if (error) {
            *error = [NSError errorWithDomain: PLClangErrorDomain code: PLClangErrorCompiler userInfo: @{
                NSLocalizedDescriptionKey: NSLocalizedString(@"An unrecoverable compiler error occurred.", nil)
            }];
        }
        return nil;
    }

    return [[PLClangTranslationUnit alloc] initWithOwner: self cxTranslationUnit: tu];
}

/**
 * Add a new translation unit to the receiver.
 *
 * @param The on-disk path to the source file.
 * @param data The source file's data.
 * @param arguments Any additional clang compiler arguments to be used when parsing the translation unit.
 * @param options The options to use when creating the translation unit.
 * @param error If an error occurs, upon return contains an NSError object that describes the problem.
 * If you are not interested in possible errors, pass in nil.
 */
- (PLClangTranslationUnit *) addTranslationUnitWithSourcePath: (NSString *) path fileData: (NSData *) data compilerArguments: (NSArray *) arguments options: (PLClangTranslationUnitCreationOptions) options error: (NSError **)error; {
    NSArray *files = nil;
    if (data != nil) {
        PLClangUnsavedFile *file = [PLClangUnsavedFile unsavedFileWithPath: path data: data];
        files = @[file];
    }
    return [self addTranslationUnitWithSourcePath: path unsavedFiles: files compilerArguments: arguments options: options error: error];
}

/**
 * Add a new translation unit to the receiver.
 *
 * @param arguments Clang compiler arguments to be used when reading the translation unit. The path to
 * the source file must be provided as a compiler argument.
 * @param options The options to use when creating the translation unit.
 * @param error If an error occurs, upon return contains an NSError object that describes the problem.
 * If you are not interested in possible errors, pass in nil.
 */
- (PLClangTranslationUnit *) addTranslationUnitWithCompilerArguments: (NSArray *) arguments options: (PLClangTranslationUnitCreationOptions) options error: (NSError **)error; {
    return [self addTranslationUnitWithSourcePath: nil fileData: nil compilerArguments: arguments options: options error: error];
}

/**
 * Add a new translation unit to the receiver.
 *
 * @param The on-disk path to the source file.
 * @param arguments Any additional clang compiler arguments to be used when parsing the translation unit.
 * @param options The options to use when creating the translation unit.
 * @param error If an error occurs, upon return contains an NSError object that describes the problem.
 * If you are not interested in possible errors, pass in nil.
 */
- (PLClangTranslationUnit *) addTranslationUnitWithSourcePath: (NSString *) path compilerArguments: (NSArray *) arguments options: (PLClangTranslationUnitCreationOptions) options error: (NSError **)error; {
    return [self addTranslationUnitWithSourcePath: path fileData: nil compilerArguments: arguments options: options error: error];
}


- (void) dealloc {
    if (_cIndex != NULL)
        clang_disposeIndex(_cIndex);
}

@end