/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "DTSourceParser.h"
#import "DTNode.h"
#import "DTTask.h"
#import "PLClang.h"
#import "PLAdditions.h"

@implementation DTSourceParser {
    NSString *_cachePath;
    NSSet *_sourceFiles;
    PLClangSourceIndex *_index;
    PLClangTranslationUnit *_pch;
    NSMutableDictionary *_fileHandles;

    NSMutableSet *_classes;
    NSMutableSet *_protocols;
    NSMutableSet *_categories;
    NSMutableSet *_functions;
    NSMutableSet *_constants;
    NSMutableDictionary *_nodes;

    DTNode *_currentContainer;
    NSMutableArray *_pendingConstants;
}

- (instancetype) initWithCachePath: (NSString *) cachePath {
    PLSuperInit();

    _cachePath = cachePath;
    _index = [PLClangSourceIndex indexWithOptions: PLClangIndexCreationExcludePCHDeclarations | PLClangIndexCreationDisplayDiagnostics];
    _classes = [NSMutableSet set];
    _protocols = [NSMutableSet set];
    _categories = [NSMutableSet set];
    _functions = [NSMutableSet set];
    _constants = [NSMutableSet set];
    _nodes = [NSMutableDictionary dictionary];
    _pendingConstants = [NSMutableArray array];

    return self;
}

- (DTLibrary *) library {
    return [[DTLibrary alloc] initWithNodes: _nodes
                                    classes: _classes
                                  protocols: _protocols
                                 categories: _categories
                                  functions: _functions
                                  constants: _constants];
}

- (BOOL) parseSourceFiles: (NSSet *) sourceFiles withCompilerArguments: (NSArray *) compilerArguments {
    [self loadDefaultPrecompiledHeader];

    _sourceFiles = sourceFiles;

    for (NSString *path in sourceFiles) {
        [self parseSourceFile: path withCompilerArguments: compilerArguments];

        // TODO: A fatal compiler error should probably fail the entire process.
        // In the case of a fatal error comments attached to definitions may or may not be available.
    }

    [_nodes enumerateKeysAndObjectsUsingBlock:^(NSString *USR, DTNode *node, BOOL *stop) {
        node.comment = [self commentForNode: node];
        if (!node.comment && !node.isImplicitMethod && !node.cursor.location.isInSystemHeader) {
            NSLog(@"%@:%lu: warning: '%@' is not documented", node.path, (unsigned long)node.cursor.location.lineNumber, node.name);
        }
    }];

    return YES;
}

- (BOOL) parseSourceFile: (NSString *) path withCompilerArguments: (NSArray *) compilerArguments {
    NSError *error = nil;

    // TODO: Needs to be configurable, probably using a clang compilation database
    NSMutableArray *arguments = [@[@"-x", @"objective-c", @"-include-pch", _pch.spelling] mutableCopy];
    [arguments addObjectsFromArray: compilerArguments];

    PLClangTranslationUnit *tu = [_index addTranslationUnitWithSourcePath: path
                                                             unsavedFiles: nil
                                                        compilerArguments: arguments
                                                                  options: PLClangTranslationUnitCreationDetailedPreprocessingRecord |
                                                                           PLClangTranslationUnitCreationSkipFunctionBodies
                                                                    error: &error];

    if (!tu) {
        NSLog(@"Unable to create traslation unit for %@: %@", path, error);
        return NO;
    }

    [tu.cursor visitChildrenUsingBlock: ^PLClangCursorVisitResult(PLClangCursor *cursor) {
        if (cursor.location.isInSystemHeader || [_sourceFiles containsObject: cursor.location.path] == NO)
            return PLClangCursorVisitContinue;

        switch (cursor.kind) {
            case PLClangCursorKindObjCInterfaceDeclaration:
                /* Ignore forward declarations. */
                if ([cursor isEqual: cursor.type.declaration] == NO) {
                    return PLClangCursorVisitContinue;
                }

                _currentContainer = [self parseObjCObjectAtCursor: cursor];
                [_classes addObject: _currentContainer];
                [self associatePendingConstants];
                return PLClangCursorVisitContinue;

            case PLClangCursorKindObjCProtocolDeclaration:
                /* Ignore forward declarations. */
                if (cursor.isDefinition == NO) {
                    return PLClangCursorVisitContinue;
                }

                _currentContainer = [self parseObjCObjectAtCursor: cursor];
                [_protocols addObject: _currentContainer];
                [self associatePendingConstants];
                return PLClangCursorVisitContinue;

            case PLClangCursorKindObjCCategoryDeclaration:
                // TODO
                break;

            case PLClangCursorKindFunctionDeclaration:
                [self parseFunctionAtCursor: cursor];
                break;

            case PLClangCursorKindTypedefDeclaration:
                [self parseTypedefAtCursor: cursor];
                return PLClangCursorVisitContinue;

            case PLClangCursorKindVariableDeclaration:
                [self parseVariableAtCursor: cursor];
                return PLClangCursorVisitContinue;

            case PLClangCursorKindMacroDefinition:
                // TODO: clang doesn't seem to associate comments with macro definitions, see if this can be exposed
                break;

            default:
                break;
        }

        return PLClangCursorVisitRecurse;
    }];

    return !tu.didFail;
}

BOOL PLClangSourceRangeContainsRange(PLClangSourceRange *range1, PLClangSourceRange *range2) {
    if (![range1.startLocation.path isEqual: range2.startLocation.path] ||
        ![range1.endLocation.path isEqual: range1.endLocation.path])
        return NO;

    return (range2.startLocation.fileOffset >= range1.startLocation.fileOffset &&
            range2.endLocation.fileOffset <= range1.endLocation.fileOffset);
}

- (DTNode *) parseObjCObjectAtCursor: (PLClangCursor *) classCursor {
    DTNode *class = _nodes[classCursor.USR];
    if (class) {
        if (class.cursor.definition || !classCursor.definition) {
            return class;
        }
    } else {
        class = [[DTNode alloc] init];
        [self addNode: class forCursor: classCursor];
    }

    class.cursor = classCursor;

    NSMutableArray *taskMethods = [NSMutableArray array];
    NSMutableArray *classMethods = [NSMutableArray array];
    NSMutableArray *instanceMethods = [NSMutableArray array];
    NSMutableArray *properties = [NSMutableArray array];
    NSMutableArray *protocols = [NSMutableArray array];

    [classCursor visitChildrenUsingBlock: ^PLClangCursorVisitResult(PLClangCursor *cursor) {
        DTNode *node = nil;
        switch (cursor.kind) {
            case PLClangCursorKindObjCSuperclassReference:
                class.superclass = _nodes[cursor.referencedCursor.USR];
                if (!class.superclass) {
                    class.superclass = [self parseObjCObjectAtCursor: cursor.referencedCursor];
                }
                break;

            case PLClangCursorKindObjCProtocolReference:
                [protocols addObject: cursor.spelling];
                break;

            case PLClangCursorKindObjCClassMethodDeclaration:
                node = [self parseMethodAtCursor: cursor];
                node.parent = class;
                [classMethods addObject: node];
                [taskMethods addObject: node];
                break;

            case PLClangCursorKindObjCInstanceMethodDeclaration:
                node = [self parseMethodAtCursor: cursor];
                node.parent = class;
                [instanceMethods addObject: node];
                [taskMethods addObject: node];
                break;

            case PLClangCursorKindObjCPropertyDeclaration:
                node = [self parseMethodAtCursor: cursor];
                node.parent = class;
                [properties addObject: node];
                [taskMethods addObject: node];
                break;

            default:
                break;
        }

        return PLClangCursorVisitContinue;
    }];

    NSMutableArray *methodsToRemove = [NSMutableArray array];

    // Remove implicit methods generated by properties.
    // TODO: Expose isImplicit for cursors in libclang.
    // Note that while we want to hide these methods in general we want to include them
    // in the tokens generated for a docset so a search for setFoo: will take the user to
    // the documentation for the foo property.
    for (DTNode *method in instanceMethods) {
        for (DTNode *property in properties) {
            if (PLClangSourceRangeContainsRange(property.cursor.extent, method.cursor.extent)) {
                if (property.implicitMethods) {
                    property.implicitMethods = [property.implicitMethods arrayByAddingObject: method];
                } else {
                    property.implicitMethods = @[method];
                }
                [methodsToRemove addObject: method];
                method.isImplicitMethod = YES;
            }
        }
    }

    [instanceMethods removeObjectsInArray: methodsToRemove];
    [taskMethods removeObjectsInArray: methodsToRemove];

    class.properties = properties;
    class.classMethods = classMethods;
    class.instanceMethods = instanceMethods;
    class.protocols = protocols;

    if ([taskMethods count] > 0) {
        // TODO: Actually extract tasks
        DTTask *defaultTask = [[DTTask alloc] initWithName: @"" methods: taskMethods];
        class.tasks = @[defaultTask];
    }

    return class;
}

- (DTNode *) parseMethodAtCursor: (PLClangCursor *) cursor {
    DTNode *method = [[DTNode alloc] init];

    NSMutableArray *parameters = [NSMutableArray array];

    for (PLClangCursor *argument in cursor.arguments) {
        DTNode *param = [[DTNode alloc] init];
        param.name = argument.displayName;
        [parameters addObject: param];
    }

    method.parameters = parameters;
    method.declaration = [self stringForSourceRange: cursor.extent];

    [self addNode: method forCursor: cursor];
    return method;
}

- (void) parseFunctionAtCursor: (PLClangCursor *) cursor {
    DTNode *function = _nodes[cursor.USR];
    if (function) {
        if (!function.cursor.comment && cursor.comment) {
            function.cursor = cursor;
        }
        return;
    }

    if ([self shouldDocumentCursor: cursor] == NO) {
        return;
    }

    function = [self parseMethodAtCursor: cursor];
    function.name = cursor.spelling;

    [_functions addObject: function];
}

- (void) parseTypedefAtCursor: (PLClangCursor *) cursor {
    DTNode *constant = _nodes[cursor.USR];
    if (constant) {
        if (cursor.isDefinition) {
            constant.cursor = cursor;
        }
        return;
    }

    PLClangType *underlyingType = cursor.underlyingType;
    PLClangCursor *underlyingCursor = underlyingType.declaration;

    if (underlyingCursor) {
        switch (underlyingCursor.kind) {
            case PLClangCursorKindEnumDeclaration:
                constant = [self parseEnumAtCursor: underlyingCursor];
                break;

            case PLClangCursorKindStructDeclaration:
                constant = [self parseStructAtCursor: underlyingCursor];
                break;

            default:
                break;
        }
    } else if (underlyingType) {
        switch (underlyingType.kind) {
            case PLClangTypeKindPointer:
                while (underlyingType.pointeeType) {
                    underlyingType = underlyingType.pointeeType;
                }

                underlyingType = underlyingType.canonicalType;
                if (underlyingType.kind == PLClangTypeKindFunctionPrototype) {
                    constant = [self parseFunctionPointerTypedefAtCursor: cursor];
                }
                break;

            case PLClangTypeKindBlockPointer:
                constant = [self parseFunctionPointerTypedefAtCursor: cursor];
                break;

            default:
                break;
        }

    }

    if (!constant) {
        NSLog(@"Ignoring unsupported typedef %@", cursor.spelling);
        return;
    }

    [self addNode: constant forCursor: cursor];

    if ([self shouldDocumentCursor: cursor]) {
        [_pendingConstants addObject: constant];
    }
}

- (DTNode *) parseEnumAtCursor: (PLClangCursor *) enumCursor {
    DTNode *constant = [[DTNode alloc] init];

    NSMutableArray *values = [NSMutableArray array];
    NSMutableString *declaration = [NSMutableString stringWithString: @"enum {\n"];
    [enumCursor visitChildrenUsingBlock: ^PLClangCursorVisitResult(PLClangCursor *cursor) {
        if (cursor.kind == PLClangCursorKindEnumConstantDeclaration) {
            DTNode *enumValue = [[DTNode alloc] init];
            [self addNode: enumValue forCursor: cursor];

            [values addObject: enumValue];
            [declaration appendFormat: @"    %@,\n", [self stringForSourceRange: cursor.extent]];
        }
        return PLClangCursorVisitContinue;
    }];

    if ([values count] > 0) {
        /* Remove the trailing comma */
        [declaration deleteCharactersInRange: NSMakeRange(declaration.length - 2, 1)];
    }
    [declaration appendString: @"};"];

    constant.declaration = declaration;
    constant.constants = values;

    return constant;
}

- (DTNode *) parseStructAtCursor: (PLClangCursor *) structCursor {
    DTNode *constant = [[DTNode alloc] init];

    NSMutableArray *fields = [NSMutableArray array];
    NSMutableString *declaration = [NSMutableString stringWithString: @"struct {\n"];
    [structCursor visitChildrenUsingBlock: ^PLClangCursorVisitResult(PLClangCursor *cursor) {
        if (cursor.kind == PLClangCursorKindFieldDeclaration) {
            DTNode *field = [[DTNode alloc] init];
            [self addNode: field forCursor: cursor];

            [fields addObject: field];
            [declaration appendFormat: @"    %@;\n", [self stringForSourceRange: cursor.extent]];
        }
        return PLClangCursorVisitContinue;
    }];
    [declaration appendString: @"};"];

    constant.declaration = declaration;
    constant.fields = fields;

    return constant;
}

- (DTNode *) parseFunctionPointerTypedefAtCursor: (PLClangCursor *) cursor {
    DTNode *constant = [[DTNode alloc] init];

    NSMutableArray *parameters = [NSMutableArray array];
    [cursor visitChildrenUsingBlock: ^PLClangCursorVisitResult(PLClangCursor *child) {
        if (child.kind == PLClangCursorKindParameterDeclaration) {
            DTNode *param = [[DTNode alloc] init];
            param.name = child.displayName;
            [parameters addObject: param];
        }
        return PLClangCursorVisitContinue;
    }];

    constant.declaration = [[self stringForSourceRange: cursor.extent] stringByAppendingString: @";"];
    constant.parameters = parameters;

    return constant;
}

- (void) parseVariableAtCursor: (PLClangCursor *) cursor {
    DTNode *constant = _nodes[cursor.USR];
    if (constant) {
        if (cursor.isDefinition) {
            constant.cursor = cursor;
        }
        return;
    }

    constant = [[DTNode alloc] init];
    constant.declaration = [[self stringForSourceRange: cursor.extent] stringByAppendingString: @";"];

    [self addNode: constant forCursor: cursor];

    if ([self shouldDocumentCursor: cursor]) {
        [_pendingConstants addObject: constant];
    }
}

/**
 * Return whether or not the cursor should be included in the documentation.
 *
 * TODO: Proper determination of whether the cursor represents public API. For now
 * just assume that anything declared in a header is documented.
 */
- (BOOL) shouldDocumentCursor: (PLClangCursor *) cursor {
    return [cursor.location.path.pathExtension isEqualToString: @"h"];
}

- (void) addNode: (DTNode *) node forCursor: (PLClangCursor *) cursor {
    if (!node.cursor)
        node.cursor = cursor;

    if (!node.name)
        node.name = cursor.displayName;

    if (!node.appleRef)
        node.appleRef = [self appleRefForCursor: cursor];

    if (!node.path)
        node.path = cursor.location.path;

    if (!node.deprecated) {
        if (cursor.availability.isDeprecated) {
            node.deprecated = YES;

            /** Convert the first letter to upper-case, lower-case is often used in attributes to match clang's style */
            NSString *message = cursor.availability.deprecationMessage;
            if ([message length] > 1) {
                message = [message stringByReplacingCharactersInRange: NSMakeRange(0, 1) withString: [[message substringToIndex: 1] uppercaseString]];
            }
            node.deprecationComment = message;
        }
    }

    if (cursor.availability.isUnavailable)
        return;

    _nodes[cursor.USR] = node;
}

- (void) associatePendingConstants {
    NSMutableArray *associatedConstants = [NSMutableArray array];
    for (DTNode *constant in _pendingConstants) {
        if (_currentContainer && [constant.path isEqual: _currentContainer.path]) {
            [associatedConstants addObject: constant];
        } else {
            [_constants addObject: constant];
        }
    }

    if (_currentContainer && [associatedConstants count] > 0) {
        for (DTNode *constant in associatedConstants) {
            constant.parent = _currentContainer;
        }

        if (_currentContainer.constants) {
            _currentContainer.constants = [_currentContainer.constants arrayByAddingObjectsFromArray: associatedConstants];
        } else {
            _currentContainer.constants = associatedConstants;
        }
    }

    [_pendingConstants removeAllObjects];
}

/**
 * Load a default precompiled header, creating it if necessary.
 *
 * Using a precompiled header and excluding its declarations significantly improves parsing performance.
 */
- (BOOL) loadDefaultPrecompiledHeader {
    NSString *path = [_cachePath stringByAppendingPathComponent: @"Default.pch"];
    _pch = [_index addTranslationUnitWithASTPath: path error: nil];
    if (!_pch) {
        // TODO:
        // - Precompiled header(s) need to be configurable
        // - Need a separate PCH for C++ when supported
        // - Can be influenced by user-defined compiler options
        // - In some cases clang can successfully parse a PCH but cannot use it because
        //   it was created by a different version of the compiler. Need to expose the
        //   diagnostics through libclang to detect this or generate the PCH for every run.

        /* Create a new PCH for the Foundation headers */
        NSError *error = nil;
        NSData *pchSourceData = [@"#ifdef __OBJC__\n#import <Foundation/Foundation.h>\n#endif" dataUsingEncoding: NSUTF8StringEncoding];
        PLClangUnsavedFile *file = [PLClangUnsavedFile unsavedFileWithPath: path data: pchSourceData];
        _pch = [_index addTranslationUnitWithSourcePath: path
                                           unsavedFiles: @[file]
                                      compilerArguments: @[@"-x", @"objective-c-header"]
                                                options: PLClangTranslationUnitCreationDetailedPreprocessingRecord |
                                                         PLClangTranslationUnitCreationIncomplete |
                                                         PLClangTranslationUnitCreationForSerialization
                                                  error: &error];

        if (_pch) {
            if (![_pch writeToFile: path error: &error]) {
                NSLog(@"Unable to create default precompiled header at %@: %@", path, error);
            }
        } else {
            NSLog(@"Unable to create default precompiled header at %@", path);
            return NO;
        }
    }

    return YES;
}

- (PLClangComment *) commentForNode: (DTNode *) node {
    PLClangComment *comment = node.cursor.comment;
    if (!comment) {
        comment = node.cursor.definition.comment;
    }

    if (!comment) {
        comment = node.cursor.underlyingType.declaration.comment;
    }

    // For Objective-C properties, see if a comment is associated with
    // the implementation of one of the property's implicit methods.
    if (!comment) {
        for (DTNode *method in node.implicitMethods) {
            comment = [self commentForNode: method];
            if (comment)
                break;
        }
    }

    return comment;
}

/**
 * Return an "apple_ref" string for the given cursor.
 *
 * This is a standard anchor format used within Apple documentation and described here:
 * https://developer.apple.com/library/Mac/documentation/DeveloperTools/Conceptual/HeaderDoc/anchors/anchors.html
 */
- (NSString *) appleRefForCursor: (PLClangCursor *) cursor {
    NSMutableArray *components = [NSMutableArray arrayWithObject: @"//apple_ref"];
    BOOL inProtocol = (cursor.semanticParent.kind == PLClangCursorKindObjCProtocolDeclaration);

    switch (cursor.language) {
        case PLClangLanguageC:
            [components addObject: @"c"];
            break;
        case PLClangLanguageCPlusPlus:
            [components addObject: @"cpp"];
            break;
        case PLClangLanguageObjC:
            [components addObject: @"occ"];
            break;
        default:
            return nil;
    }

    switch (cursor.kind) {
        case PLClangCursorKindObjCInterfaceDeclaration:
            [components addObject: @"cl"];
            break;
        case PLClangCursorKindObjCProtocolDeclaration:
            [components addObject: @"intf"];
            break;
        case PLClangCursorKindObjCCategoryDeclaration:
            [components addObject: @"cat"];
            break;
        case PLClangCursorKindObjCClassMethodDeclaration:
            [components addObject: inProtocol ? @"intfcm" : @"clm"];
            [components addObject: cursor.semanticParent.spelling];
            break;
        case PLClangCursorKindObjCInstanceMethodDeclaration:
            [components addObject: inProtocol ? @"intfm" : @"instm"];
            [components addObject: cursor.semanticParent.spelling];
            break;
        case PLClangCursorKindObjCPropertyDeclaration:
            [components addObject: inProtocol ? @"intfp" : @"instp"];
            [components addObject: cursor.semanticParent.spelling];
            break;
        case PLClangCursorKindTypedefDeclaration:
            [components addObject: @"tdef"];
            break;
        case PLClangCursorKindVariableDeclaration:
            [components addObject: @"data"];
            break;
        case PLClangCursorKindEnumConstantDeclaration:
            [components addObject: @"econst"];
            break;
        case PLClangCursorKindMacroDefinition:
            [components addObject: @"macro"];
            break;
        default:
            return nil;
    }

    [components addObject: cursor.spelling];

    return [components componentsJoinedByString: @"/"];
}

- (NSString *) stringForSourceRange: (PLClangSourceRange *) range {
    NSString *path = range.startLocation.path;
    NSFileHandle *file = _fileHandles[path];
    if (!file) {
        file = [NSFileHandle fileHandleForReadingAtPath: path];
        if (!file) {
            return nil;
        }
        _fileHandles[path] = file;
    }

    [file seekToFileOffset: (unsigned long long)range.startLocation.fileOffset];
    NSData *data = [file readDataOfLength: (NSUInteger)(range.endLocation.fileOffset - range.startLocation.fileOffset)];
    NSString *result = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];

    // TODO: Remove?
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [characterSet addCharactersInString: @";"];
    return [result stringByTrimmingCharactersInSet: characterSet];
}

@end
