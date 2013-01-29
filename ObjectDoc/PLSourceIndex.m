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

/**
 * Add a new translation unit to the receiver.
 *
 * @param The on-disk path to the source file.
 * @param data The source file's data.
 * @param arguments Any additional clang compiler arguments to be used when parsing the translation unit.
 *
 * @todo Investigate support for providing multiple in-memory files (pchs?)
 */
- (PLTranslationUnit *) addTranslationUnitWithSourcePath: (NSString *) path fileData: (NSData *) data compilerArguments: (NSArray *) arguments {
    /* NOTE: This implementation fetches backing data/string pointers from the passed in Objective-C arguments; these values
     * are not guaranteed to survive past the lifetime of the current autorelease pool. */
    CXTranslationUnit tu;
    char **argv = calloc(sizeof(char *), [arguments count]);
    const char *cPath = NULL;
    struct CXUnsavedFile unsavedFile;
    unsigned int unsavedFileCount = 0;

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

    tu = clang_parseTranslationUnit(_cIndex,
            [path fileSystemRepresentation],
            (const char **) argv,
            [arguments count],
            unsavedFileCount ? &unsavedFile : NULL,
            unsavedFileCount,
            CXTranslationUnit_DetailedPreprocessingRecord);

    free(argv);

    if (tu == NULL) {
        // TODO - report error?
        return nil;
    }

    // XXX hack in error/diagnostic checking
    CXDiagnosticSet diagnosticSet = clang_getDiagnosticSetFromTU(tu);
    unsigned int count = clang_getNumDiagnosticsInSet(diagnosticSet);
    for (unsigned int i = 0; i < count; i++) {
        CXDiagnostic diagnostic = clang_getDiagnosticInSet(diagnosticSet, i);
        unsigned int line, column, offset;
        CXSourceLocation loc;
        CXString spelling;
        CXString fileName;
        CXFile file;

        spelling = clang_getDiagnosticSpelling(diagnostic);
        loc = clang_getDiagnosticLocation(diagnostic);
        clang_getExpansionLocation(loc, &file, &line, &column, &offset);
        fileName = clang_getFileName(file);

        NSLog(@"%s:%d:%d: (severity=%d) %s",
                clang_getCString(fileName),
                line,
                column,
                clang_getDiagnosticSeverity(diagnostic),
                clang_getCString(spelling));

        clang_disposeString(fileName);

        // TODO - recursively handle child diagnostics?
    }
    clang_disposeDiagnosticSet(diagnosticSet);


    PLTranslationUnit *pltu = [[PLTranslationUnit alloc] initWithCXTranslationUnit: tu];
    [_translationUnits addObject: pltu];

    return pltu;
}

/**
 * Add a new translation unit to the receiver.
 *
 * @param arguments Clang compiler arguments to be used when reading the translation unit. The path to
 * the source file must be provided as a compiler argument.
 */
- (PLTranslationUnit *) addTranslationUnitWithCompilerArguments: (NSArray *) arguments {
    return [self addTranslationUnitWithSourcePath: nil fileData: nil compilerArguments: arguments];
}

/**
 * Add a new translation unit to the receiver.
 *
 * @param The on-disk path to the source file.
 * @param arguments Any additional clang compiler arguments to be used when parsing the translation unit.
 */
- (PLTranslationUnit *) addTranslationUnitWithSourcePath: (NSString *) path compilerArguments: (NSArray *) arguments {
    return [self addTranslationUnitWithSourcePath: path fileData: nil compilerArguments: arguments];
}


- (void) dealloc {
    if (_cIndex != NULL)
        clang_disposeIndex(_cIndex);
}

@end