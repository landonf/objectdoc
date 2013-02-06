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

    /* Recursively parse child diagnostics */
    CXDiagnosticSet childSet = clang_getChildDiagnostics(_diagnostic);
    if (childSet != NULL) {
        unsigned int childCount = clang_getNumDiagnosticsInSet(childSet);
        NSMutableArray *childDiagnostics = [NSMutableArray arrayWithCapacity: childCount];
        _childDiagnostics = childDiagnostics;

        for (unsigned int i = 0; i < childCount; i++) {
            CXDiagnostic diagnostic = clang_getDiagnosticInSet(childSet, i);
            [childDiagnostics addObject: [[PLClangDiagnostic alloc] initWithCXDiagnostic: diagnostic]];
        }
        clang_disposeDiagnosticSet(childSet);
    }

    return self;
}

// property getter
- (NSString *) formattedErrorMessage {
    CXString formatted = clang_formatDiagnostic(_diagnostic, clang_defaultDiagnosticDisplayOptions());
    NSString *result = [NSString stringWithUTF8String: clang_getCString(formatted)];

    // TODO - Verify that 'formatted' requires disposal; this is unclear from clang's documentation.
    clang_disposeString(formatted);

    return result;
}

// property getter
- (PLClangDiagnosticSeverity) severity {
    switch (clang_getDiagnosticSeverity(_diagnostic)) {
        case CXDiagnostic_Ignored:
            return PLClangDiagnosticSeverityIgnored;

        case CXDiagnostic_Note:
            // XXX unsupported
            abort();

        case CXDiagnostic_Warning:
            return PLClangDiagnosticSeverityWarning;

        case CXDiagnostic_Error:
            return PLClangDiagnosticSeverityError;

        case CXDiagnostic_Fatal:
            return PLClangDiagnosticSeverityFatal;
    }
}


@end