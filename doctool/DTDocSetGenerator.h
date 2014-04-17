/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "DTHTMLGenerator.h"

@interface DTDocSetGenerator : DTHTMLGenerator

@property(nonatomic, copy) NSString *bundleIdentifier;
@property(nonatomic, copy) NSString *bundleName;
@property(nonatomic, copy) NSString *bundleVersion;
@property(nonatomic, copy) NSString *publisherIdentifier;
@property(nonatomic, copy) NSString *publisherName;

@end
