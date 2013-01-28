/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>

#import "PLTranslationUnit.h"

@interface PLSourceIndex : NSObject

- (PLTranslationUnit *) addTranslationUnitWithSourcePath: (NSString *) path
                                                fileData: (NSData *) data
                                       compilerArguments: (NSArray *) arguments;

- (PLTranslationUnit *) addTranslationUnitWithCompilerArguments: (NSArray *) arguments;

- (PLTranslationUnit *) addTranslationUnitWithSourcePath: (NSString *) path
                                       compilerArguments: (NSArray *) arguments;

@end