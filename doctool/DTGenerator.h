/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "DTLibrary.h"

@protocol DTGenerator <NSObject>

- (void) generateDocumentationForLibrary: (DTLibrary *) library error: (NSError **) error;

@end
