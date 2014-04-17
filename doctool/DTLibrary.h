/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "DTConfiguration.h"
#import "DTNode.h"

@interface DTLibrary : NSObject

- (instancetype) initWithNodes: (NSDictionary *) nodes
                       classes: (NSSet *) classes
                     protocols: (NSSet *) protocols
                    categories: (NSSet *) categories
                     functions: (NSSet *) functions
                     constants: (NSSet *) constants;

@property(nonatomic) NSDictionary *nodes;
@property(nonatomic) NSSet *classes;
@property(nonatomic) NSSet *protocols;
@property(nonatomic) NSSet *categories;
@property(nonatomic) NSSet *functions;
@property(nonatomic) NSSet *constants;

- (instancetype) filteredLibraryForConfiguration: (DTConfiguration *) config;

@end
