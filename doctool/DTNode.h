/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "PLClangCursor.h"

@interface DTNode : NSObject

@property(nonatomic) PLClangCursor *cursor;
@property(nonatomic) PLClangComment *comment;

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *appleRef;
@property(nonatomic, copy) NSString *briefComment;
@property(nonatomic, copy) NSString *expandedComment;
@property(nonatomic, copy) NSString *fullComment;
@property(nonatomic, copy) NSString *declaration;
@property(nonatomic, copy) NSString *declarationHTML;
@property(nonatomic, copy) NSString *returnValueComment;
@property(nonatomic, getter=isDeprecated) BOOL deprecated;
@property(nonatomic, copy) NSString *deprecationComment;
@property(nonatomic, copy) NSString *path;

@property(nonatomic) DTNode *superclass;
@property(nonatomic, copy) NSArray *tasks;
@property(nonatomic, copy) NSArray *protocols;
@property(nonatomic, copy) NSArray *properties;
@property(nonatomic, copy) NSArray *classMethods;
@property(nonatomic, copy) NSArray *instanceMethods;
@property(nonatomic, copy) NSArray *implicitMethods;
@property(nonatomic, copy) NSArray *constants;
@property(nonatomic, copy) NSArray *fields;
@property(nonatomic, readonly) NSOrderedSet *allSuperClasses;
@property(nonatomic, readonly) NSOrderedSet *allProtocols;

@property(nonatomic, copy) NSArray *parameters;
@property(nonatomic, readonly) BOOL isClassMethod;
@property(nonatomic, readonly) BOOL isInstanceMethod;
@property(nonatomic, readonly) BOOL isProperty;
@property(nonatomic, readonly, getter=isRequiredMethod) BOOL requiredMethod;
@property(nonatomic, readonly, getter=isReadOnly) BOOL readOnly;
@property(nonatomic) BOOL isImplicitMethod;

@property(nonatomic, weak) DTNode *parent;

/** A UUID string that uniquely identifies the document containing this node. */
@property(nonatomic, readonly) NSString *UUID;

/** A node reference number, used for cross-referencing within a docset. */
@property (nonatomic, readonly) NSUInteger referenceNumber;

/** The relative path to the HTML file containing this node. */
@property(nonatomic, copy) NSString *HTMLPath;

@property(nonatomic, readonly, getter=isDocumented) BOOL documented;
@property(nonatomic, readonly) BOOL hasCommentedMethods;
@property(nonatomic, readonly) BOOL hasCommentedParameters;
@property(nonatomic, readonly) BOOL hasCommentedConstants;
@property(nonatomic, readonly) BOOL hasCommentedFields;

@end
