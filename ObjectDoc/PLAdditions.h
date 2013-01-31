/*
 * Copyright (c) 2012-2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>

/**
 * @defgroup API Additions and Extensions
 */


#ifndef PLSuperInit

/**
 * @ingroup macros
 *
 * Call the superclass' default zero-argument initializer, returning nil if the superclass' initializer
 * returns nil.
 *
 * This macro is equivalent to:
 *
 * @code
 * if ((self = [super init]) == nil)
 *     return nil;
 * @endcode
 *
 * @par Example Usage
 *
 * @code
 * - (id) initWithString {
 *     PLSuperInit();
 * }
 * @endcode
 */
#define PLSuperInit() do { \
    if ((self = [super init]) == nil) {\
        return nil; \
    } \
} while (NO)

#endif /* !PLSuperInit */