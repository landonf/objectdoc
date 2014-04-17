/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "DTTask.h"
#import "PLAdditions.h"

@implementation DTTask

- (instancetype) initWithName: (NSString *) name methods: (NSArray *) methods {
    PLSuperInit();

    _name = name;
    _methods = methods;

    return self;
}

@end
