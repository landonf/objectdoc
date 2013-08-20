/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLClang.h"
#import "PLClangNSString.h"

/**
 * The PLClang error domain.
 */
NSString * const PLClangErrorDomain = @"PLClangErrorDomain";

/**
 * Returns the Clang version as a string.
 *
 * @return The Clang version as a string suitable for displaying to the user. The string
 *         is not suitable for parsing as the format is not guaranteed to be stable.
 */
NSString *PLClangGetVersionString() {
    return plclang_convert_and_dispose_cxstring(clang_getClangVersion());
}
