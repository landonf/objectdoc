/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface DTConfiguration : NSObject

- (instancetype) initWithPropertyList: (NSDictionary *) plist error: (NSError **) error;

@property(nonatomic, readonly) NSArray *compilerArguments;
@property(nonatomic, readonly) BOOL showUndocumentedEntities;
@property(nonatomic, readonly) BOOL showInternalComments;

@property(nonatomic, readonly) NSString *frameworkName;
@property(nonatomic, readonly) NSArray *paths;
@property(nonatomic, readonly) NSArray *excludePatterns;
@property(nonatomic, readonly) NSSet *fileTypes;

@property(nonatomic, readonly) NSString *outputPath;
@property(nonatomic, readonly) BOOL htmlOutputEnabled;
@property(nonatomic, readonly) BOOL docSetOutputEnabled;

@property(nonatomic, readonly) NSString *docSetBundleId;
@property(nonatomic, readonly) NSString *docSetBundleVersion;
@property(nonatomic, readonly) NSString *docSetPublisherIdentifier;
@property(nonatomic, readonly) NSString *docSetPublisherName;

@end
