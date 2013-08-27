/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLClangToken.h"
#import "PLClangTokenPrivate.h"
#import "PLClangSourceLocationPrivate.h"
#import "PLClangSourceRangePrivate.h"
#import "PLClangTranslationUnitPrivate.h"
#import "PLClangNSString.h"
#import "PLAdditions.h"

/**
 * A preprocessing token.
 */
@implementation PLClangToken {
    /**
     * A reference to the owning object (the token set), held so that the
     * CXToken remains valid for the lifetime of the token.
     */
    id _owner;

    /** The backing clang token. */
    CXToken _token;

    /**
     * The translation unit in which this token resides, used to access
     * token attributes.
     */
    PLClangTranslationUnit *_tu;

    /** The source location for this token. */
    PLClangSourceLocation *_location;

    /** The source range for the extent of this token. */
    PLClangSourceRange *_extent;
}

- (PLClangTokenKind) kind {
    switch (clang_getTokenKind(_token)) {
        case CXToken_Punctuation:
            return PLClangTokenKindPunctuation;

        case CXToken_Keyword:
            return PLClangTokenKindKeyword;

        case CXToken_Identifier:
            return PLClangTokenKindIdentifier;

        case CXToken_Literal:
            return PLClangTokenKindLiteral;

        case CXToken_Comment:
            return PLClangTokenKindComment;
    }

    // Token has an unknown kind
    abort();
}

- (PLClangSourceLocation *) location {
    return _location ?: (_location = [[PLClangSourceLocation alloc] initWithOwner: _tu cxSourceLocation: clang_getTokenLocation([_tu cxTranslationUnit], _token)]);
}

- (PLClangSourceRange *) extent {
    return _extent ?: (_extent = [[PLClangSourceRange alloc] initWithOwner: _tu cxSourceRange: clang_getTokenExtent([_tu cxTranslationUnit], _token)]);
}

- (NSString *) description {
    return self.spelling;
}

- (NSString *) debugDescription {
    return [NSString stringWithFormat: @"<%@: %p> %@", [self class], self, [self description]];
}

@end

/**
 * @internal
 * Package-private methods.
 */
@implementation PLClangToken (PackagePrivate)

/**
 * Initialize a newly-created token with the specified clang token.
 *
 * @param owner A reference to the owner of the clang token. This reference will be retained
 * to ensure that the clang token survives for the lifetime of this instance.
 * @param translationUnit The translation in which this token resides.
 * @param cursor The cursor associated with this token, or nil if there is no associated cursor.
 * @param token The clang token that will back this object.
 * @return An initialized token.
 */
- (instancetype) initWithOwner: (id) owner translationUnit: (PLClangTranslationUnit *) translationUnit cursor: (PLClangCursor *) cursor cxToken: (CXToken) token {
    PLSuperInit();

    _owner = owner;
    _tu = translationUnit;
    _token = token;
    _cursor = cursor;
    _spelling = plclang_convert_and_dispose_cxstring(clang_getTokenSpelling([_tu cxTranslationUnit], _token));

    return self;
}

@end
