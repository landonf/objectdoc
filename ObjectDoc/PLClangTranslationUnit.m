/*
 * Author: Landon Fuller <landonf@plausible.coop>
 *
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#import <clang-c/Index.h>

#import "PLAdditions.h"

#import "PLClangTranslationUnit.h"
#import "PLClangDiagnostic.h"
#import "PLClangDiagnosticPrivate.h"

@implementation PLClangTranslationUnit {
@private
    /** Backing clang translation unit. */
    CXTranslationUnit _tu;
}

- (void) dealloc {
    if (_tu != NULL)
        clang_disposeTranslationUnit(_tu);
}

// property getter
- (BOOL) didFail {
    for (PLClangDiagnostic *d in _diagnostics) {
        if (d.severity == PLClangDiagnosticSeverityError || d.severity == PLClangDiagnosticSeverityFatal)
            return YES;
    }

    return NO;
}

@end

/**
 * @internal
 * Package-private methods.
 */
@implementation PLClangTranslationUnit (PackagePrivate)

/**
 * Initialize with the given translation unit.
 *
 * @param tu Backing clang translation unit. The receiver will assume ownership over the value.
 */
- (instancetype) initWithCXTranslationUnit: (CXTranslationUnit) tu {
    PLSuperInit();

    _tu = tu;

    /* Extract all diagnostics */
    CXDiagnosticSet diagnosticSet = clang_getDiagnosticSetFromTU(tu);
    unsigned int count = clang_getNumDiagnosticsInSet(diagnosticSet);
    NSMutableArray *diagnostics = [NSMutableArray arrayWithCapacity: count];
    for (unsigned int i = 0; i < count; i++) {
        CXDiagnostic diagnostic = clang_getDiagnosticInSet(diagnosticSet, i);
        if (clang_getDiagnosticSeverity(diagnostic) == CXDiagnostic_Note) {
            // TODO: Handle note diagnostics.
            continue;
        }

        [diagnostics addObject: [[PLClangDiagnostic alloc] initWithCXDiagnostic: diagnostic]];
    }
    _diagnostics = diagnostics;

    // TODO: Verify that clang does not dispose backing storage required by the CXDiagnostic instances.
    clang_disposeDiagnosticSet(diagnosticSet);

    return self;
}

@end