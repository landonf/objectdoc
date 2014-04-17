/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "DTLibrary.h"
#import "DTDoxygenCommands.h"
#import "PLAdditions.h"

@implementation DTLibrary

- (instancetype) initWithNodes: (NSDictionary *) nodes classes: (NSSet *) classes protocols: (NSSet *) protocols categories: (NSSet *) categories functions: (NSSet *) functions constants: (NSSet *) constants {
    PLSuperInit();

    _nodes = nodes;
    _classes = classes;
    _protocols = protocols;
    _categories = categories;
    _functions = functions;
    _constants = constants;

    return self;
}

// TODO: Think on a better way to do this, the unwinding is too complex. Ideally we would not
// add the undocumented nodes at all, but when parsing we don't know if we're only going to
// see declarations or both declarations and implementations, and comments could be attached to
// either.
- (instancetype) filteredLibraryForConfiguration: (DTConfiguration *) config {
    if (config.showUndocumentedEntities) {
        // If everything is being shown there's no need to filter
        return self;
    }

    return [[[self class] alloc] initWithNodes: _nodes
                                       classes: [self filterSet: _classes forConfiguration: config]
                                     protocols: [self filterSet: _protocols forConfiguration: config]
                                    categories: [self filterSet: _categories forConfiguration: config]
                                     functions: [self filterSet: _functions forConfiguration: config]
                                     constants: [self filterSet: _constants forConfiguration: config]];
}

- (NSSet *) filterSet: (NSSet *) set forConfiguration: (DTConfiguration *) config {
    NSMutableSet *filteredSet = [NSMutableSet set];

    for (DTNode *node in set) {
        [self filterNode: node forConfiguration: config];

        if ([self node: node isVisibleForConfiguration: config] == NO) {
            // TOOD: Remove from node lookup as well
        } else {
            [filteredSet addObject: node];
        }
    }

    return filteredSet;
}

- (NSArray *) filterArray: (NSArray *) array forConfiguration: (DTConfiguration *) config {
    NSMutableArray *filteredArray = [NSMutableArray array];

    for (DTNode *node in array) {
        if ([self node: node isVisibleForConfiguration: config] == NO) {
            // TOOD: Remove from node lookup as well
        } else {
            [filteredArray addObject: node];
        }
    }

    return filteredArray;
}

- (void) filterNode: (DTNode *) node forConfiguration: (DTConfiguration *) config {
    node.classMethods = [self filterArray: node.classMethods forConfiguration: config];
    node.instanceMethods = [self filterArray: node.instanceMethods forConfiguration: config];
    node.constants = [self filterArray: node.constants forConfiguration: config];
}

- (BOOL) node: (DTNode *) node isVisibleForConfiguration: (DTConfiguration *) config {
    if (node.comment == nil)
        return NO;

    if (config.showInternalComments == NO) {
        // Parse enough of the comment to determine if the node has any non-internal content

        BOOL inInternal = NO;

        for (PLClangComment *comment in node.comment.children) {
            if (comment.kind != PLClangCommentKindParagraph && !inInternal)
                return YES;

            for (PLClangComment *child in comment.children) {
                if (child.isWhitespace)
                    continue;

                switch (child.kind) {
                    case PLClangCommentKindInlineCommand:
                        if ([child.commandName isEqualToString: DTCommandNameInternal]) {
                            inInternal = YES;
                        } else if ([comment.commandName isEqualToString: DTCommandNameEndInternal]) {
                            inInternal = NO;
                        } else if (!inInternal) {
                            return YES;
                        }
                        break;
                    default:
                        if (!inInternal) {
                            return YES;
                        }
                        break;
                }
            }
        }

        return NO;
    }

    return YES;
}

@end
