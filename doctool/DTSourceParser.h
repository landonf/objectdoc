/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "DTLibrary.h"

@interface DTSourceParser : NSObject

- (instancetype) initWithCachePath: (NSString *) cachePath;

@property(nonatomic, readonly) DTLibrary *library;

- (BOOL) parseSourceFiles: (NSSet *) sourceFiles withCompilerArguments: (NSArray *) compilerArguments;

@end
