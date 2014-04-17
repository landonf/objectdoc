/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface DTTask : NSObject

- (instancetype) initWithName: (NSString *) name methods: (NSArray *) methods;

@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSArray *methods;

@end
