/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>

#import "PLClangTranslationUnit.h"

@interface PLClangSourceIndex : NSObject

- (PLClangTranslationUnit *) addTranslationUnitWithSourcePath: (NSString *) path
                                                fileData: (NSData *) data
                                       compilerArguments: (NSArray *) arguments;

- (PLClangTranslationUnit *) addTranslationUnitWithCompilerArguments: (NSArray *) arguments;

- (PLClangTranslationUnit *) addTranslationUnitWithSourcePath: (NSString *) path
                                       compilerArguments: (NSArray *) arguments;

@end