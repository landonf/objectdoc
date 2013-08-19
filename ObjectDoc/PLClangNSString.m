#import "PLClangNSString.h"

/**
 * Returns an NSString with the contents of the given CXString, or
 * nil if given a null CXString.
 */
NSString *plclang_convert_cxstring(CXString string) {
    const char *cstring = clang_getCString(string);
    return cstring ? [NSString stringWithUTF8String:cstring] : nil;
}

/**
 * Returns an NSString with the contents of the given CXString and
 * disposes the CXString.
 *
 * Returns nil if given a null CXString.
 *
 * Unless otherwise stated all CXStrings returned from clang must be
 * disposed.
 */
NSString *plclang_convert_and_dispose_cxstring(CXString string) {
    NSString *result = plclang_convert_cxstring(string);
	clang_disposeString(string);
	return result;
}
