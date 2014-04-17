/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "DTGenerator.h"

@interface DTHTMLGenerator : NSObject <DTGenerator>

@property(nonatomic, copy) NSString *outputDirectory;
@property(nonatomic, copy) NSString *templatesDirectory;
@property(nonatomic, copy) NSString *frameworkName;
@property(nonatomic) BOOL showInternalComments;

@end
