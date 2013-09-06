/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "DTNode.h"
#import "PLAdditions.h"

/**
 * A documentable node.
 */
@implementation DTNode

- (id) init {
    PLSuperInit();

    _UUID = [[NSUUID UUID] UUIDString];

    _briefComment = @"";
    _expandedComment = @"";
    _fullComment = @"";
    _returnValueComment = @"";

    return self;
}

- (NSOrderedSet *) allSuperclasses {
    NSMutableOrderedSet *superclasses = [NSMutableOrderedSet orderedSet];
    DTNode *class = self;
    while ((class = class.superclass)) {
        [superclasses addObject: class];
    }

    return superclasses;
}

- (NSOrderedSet *) allProtocols {
    NSMutableOrderedSet *protocols = [NSMutableOrderedSet orderedSet];
    DTNode *class = self;
    while (class) {
        [protocols addObjectsFromArray: class.protocols];
        class = class.superclass;
    }

    return protocols;
}

- (BOOL) isClassMethod {
    return (self.cursor.kind == PLClangCursorKindObjCClassMethodDeclaration);
}

- (BOOL) isInstanceMethod {
    return (self.cursor.kind == PLClangCursorKindObjCInstanceMethodDeclaration);
}

- (BOOL) isProperty {
    return (self.cursor.kind == PLClangCursorKindObjCPropertyDeclaration);
}

- (BOOL) isRequiredMethod {
    return (self.parent.cursor.kind == PLClangCursorKindObjCProtocolDeclaration) && !self.cursor.isObjCOptional;
}

- (BOOL) isReadOnly {
    return !!(self.cursor.objCPropertyAttributes & PLClangObjCPropertyAttributeReadOnly);
}

- (BOOL) hasCommentedMethods {
    for (DTNode *node in self.classMethods) {
        if (node.documented)
            return YES;
    }

    for (DTNode *node in self.instanceMethods) {
        if (node.documented)
            return YES;
    }

    for (DTNode *node in self.properties) {
        if (node.documented)
            return YES;
    }

    // TODO: Handle commented implicit methods?

    return NO;
}

- (BOOL) hasCommentedParameters {
    for (DTNode *node in self.parameters) {
        if (node.documented)
            return YES;
    }

    return NO;
}

- (BOOL) hasCommentedConstants {
    for (DTNode *node in self.constants) {
        if (node.documented)
            return YES;
    }

    return NO;
}

- (BOOL) hasCommentedFields {
    for (DTNode *node in self.fields) {
        if (node.documented)
            return YES;
    }

    return NO;
}

- (BOOL) isDocumented {
    return ([self.fullComment length] > 0) ||
           ([self.briefComment length] > 0) ||
           self.hasCommentedMethods ||
           self.hasCommentedParameters ||
           self.hasCommentedConstants ||
           self.hasCommentedFields;
}

- (NSString * ) description {
    return [NSString stringWithFormat: @"<%@: %p> %@", [self class], self, self.name];
}

@end
