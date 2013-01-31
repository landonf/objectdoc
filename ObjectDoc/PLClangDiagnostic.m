/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLClangDiagnostic.h"
#import "PLClangDiagnosticPrivate.h"
#import "PLAdditions.h"

/**
 * A clang diagnostic message.
 */
@implementation PLClangDiagnostic {
@private
    /** Backing clang diagnostic location. */
    CXDiagnostic *_diagnostic;
}

- (void) dealloc {
    if (_diagnostic != NULL)
        clang_disposeDiagnostic(_diagnostic);
}

@end

/**
 * @internal
 * Package-private methods.
 */
@implementation PLClangDiagnostic (PackagePrivate)

/**
 * Initialize with the given diagnostic.
 *
 * @param diagnostic Backing clang diagnostic. The receiver will assume ownership over the value.
 */
- (instancetype) initWithCXDiagnostic: (CXDiagnostic) diagnostic {
    PLSuperInit();

    _diagnostic = diagnostic;

    // XXX: Hack in printing for a quick test.
    unsigned int line, column, offset;
    CXSourceLocation loc;
    CXString spelling;
    CXString fileName;
    CXFile file;

    spelling = clang_getDiagnosticSpelling(_diagnostic);
    loc = clang_getDiagnosticLocation(_diagnostic);
    clang_getExpansionLocation(loc, &file, &line, &column, &offset);
    fileName = clang_getFileName(file);

    CXString formatted = clang_formatDiagnostic(_diagnostic, clang_defaultDiagnosticDisplayOptions());
    NSLog(@"Err: %s", clang_getCString(formatted));

    // TODO - Verify that 'formatted' requires disposal; this is unclear from clang's documentation.
    clang_disposeString(formatted);
    clang_disposeString(fileName);

    // TODO - recursively handle child diagnostics?

    return self;
}

@end