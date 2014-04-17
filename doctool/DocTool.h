/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>

extern NSString * const DTErrorDomain;

/**
 * Error codes in the DTErrorDomain.
 */
typedef NS_ENUM(NSInteger, DTErrorCode) {
    /**
     * An unknown error occurred.
     *
     * If this error code is received it is a bug and should be reported.
     */
    DTErrorUnknown = 0,

    /**
     * A configuration error occurred.
     */
    DTErrorConfiguration = 1,

    /**
     * An error occurred during generation of HTML output.
     */
    DTErrorHTMLOutputGeneration = 2
};
