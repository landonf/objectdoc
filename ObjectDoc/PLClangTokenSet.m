#import "PLClangTokenSet.h"
#import "PLClangTranslationUnit.h"
#import "PLClangTranslationUnitPrivate.h"
#import "PLAdditions.h"

/**
 * @internal
 * Manages the lifetime of a set of CXTokens.
 *
 * A set of tokens returned by clang_tokenize() must be disposed at once
 * when the application is finished using all tokens in the set. This is
 * accomplished by having each PLClangToken retain an instance of this
 * object.
 */
@implementation PLClangTokenSet {
    /**
     * A reference to the owning translation unit, held so that the
     * CXTokens remains valid for the lifetime of the token set, and
     * because the translation unit is needed to dispose the tokens.
     */
    PLClangTranslationUnit *_tu;

    /** The backing CXToken set. */
    CXToken *_tokens;

    /** The number of tokens in the backing CXToken set. */
    unsigned _count;
}

/**
 * Initialize a newly-created token set with the specified clang tokens.
 *
 * @param tu The translation unit in which the tokens reside.
 * @param tokens Pointer to the array of CXTokens this set should take ownership of.
 * @param count The number of CXTokens in the array.
 * @return An initialized token set.
 */
- (instancetype) initWithTranslationUnit: (PLClangTranslationUnit *) tu cxTokens: (CXToken *) tokens count: (unsigned) count {
    PLSuperInit();

    _tu = tu;
    _tokens = tokens;
    _count = count;

    return self;
}

- (void) dealloc {
    if (_tokens) {
        clang_disposeTokens([_tu cxTranslationUnit], _tokens, _count);
    }
}

@end
