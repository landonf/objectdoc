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
#import "PLClangCursorPrivate.h"
#import "PLClangDiagnostic.h"
#import "PLClangDiagnosticPrivate.h"
#import "PLClangSourceRangePrivate.h"
#import "PLClangTokenPrivate.h"
#import "PLClangTokenSet.h"

@implementation PLClangTranslationUnit {
@private
    /**
     * A reference to the owning object (the index), held so that the CXIndex
     * remains valid for the lifetime of the translation unit.
     */
    id _owner;

    /** Backing clang translation unit. */
    CXTranslationUnit _tu;
}

/**
 * @internal
 * Note that once a translation unit has been disposed all clang objects derived from it become
 * invalid. This includes comments, cursors, locations, and tokens.
 */
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

/*
 * The cursor holds a strong reference to the translation unit so that the backing CXTranslationUnit
 * remains valid for the lifetime of the cursor. To avoid a retain cycle the translation unit does
 * not retain its cursor.
 */
- (PLClangCursor *) cursor {
    return [[PLClangCursor alloc] initWithOwner: self cxCursor: clang_getTranslationUnitCursor(_tu)];
}

/**
 * Tokenize the source code described by the given range into raw lexical tokens.
 *
 * @param range The source range in which text should be tokenized.
 *
 * @return An array of PLClangToken objects that occur within the given source range.
 */
- (NSArray *) tokensForSourceRange: (PLClangSourceRange *) range {
    CXToken *cxTokens = NULL;
    unsigned int tokenCount = 0;
    clang_tokenize(_tu, [range cxSourceRange], &cxTokens, &tokenCount);

    NSMutableArray *tokens = [NSMutableArray arrayWithCapacity: tokenCount];
    if (tokenCount < 1)
        return tokens;

    CXCursor* cxCursors = (CXCursor *)calloc(tokenCount, sizeof(CXCursor));
    clang_annotateTokens(_tu, cxTokens, tokenCount, cxCursors);

    // The token set is retained by each token so that clang_disposeTokens() is only called
    // when the last PLClangToken is deallocated.
    PLClangTokenSet *tokenSet = [[PLClangTokenSet alloc] initWithTranslationUnit: self cxTokens: cxTokens count: tokenCount];

    for (unsigned int i = 0; i < tokenCount; i++) {
        PLClangCursor *cursor = [[PLClangCursor alloc] initWithOwner: self cxCursor: cxCursors[i]];
        [tokens addObject: [[PLClangToken alloc] initWithOwner: tokenSet
                                               translationUnit: self
                                                        cursor: cursor
                                                       cxToken: cxTokens[i]]];
    }

    free(cxCursors);
    return tokens;
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
 * @param owner A reference to the owner of the clang translation unit. This reference will be
 * retained to ensure that the clang translation unit survives for the lifetime of this instance.
 * @param tu Backing clang translation unit. The receiver will assume ownership over the value.
 */
- (instancetype) initWithOwner: (id) owner cxTranslationUnit: (CXTranslationUnit) tu {
    PLSuperInit();

    _owner = owner;
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

- (CXTranslationUnit) cxTranslationUnit {
    return _tu;
}

@end