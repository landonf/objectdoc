/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "DTHTMLGenerator.h"
#import "DTDoxygenCommands.h"
#import "DocTool.h"
#import "GRMustache.h"

static NSString * const DTFrameworkNameKey = @"frameworkName";
static NSString * const DTGeneratedDateKey = @"generatedDate";
static NSString * const DTClassesKey = @"classes";
static NSString * const DTProtocolsKey = @"protocols";
static NSString * const DTCategoriesKey = @"categories";
static NSString * const DTTitleKey = @"title";
static NSString * const DTFunctionsKey = @"functions";
static NSString * const DTConstantsKey = @"constants";
static NSString * const DTIncludeOtherReferencesKey = @"includeOtherReferences";

@implementation DTHTMLGenerator {
    DTLibrary *_library;
    BOOL _inInternal;
}

- (void) generateDocumentationForLibrary: (DTLibrary *) library error: (NSError **) outError {
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (outError)
        *outError = nil;

    _library = library;
    [self processComments];

    NSString *classesDirectory = [self.outputDirectory stringByAppendingPathComponent: @"Classes"];
    NSString *protocolsDirectory = [self.outputDirectory stringByAppendingPathComponent: @"Protocols"];
    NSString *categoriesDirectory = [self.outputDirectory stringByAppendingPathComponent: @"Categories"];
    NSString *miscDirectory = [self.outputDirectory stringByAppendingPathComponent: @"Misc"];
    [fileManager removeItemAtPath: classesDirectory error: nil];
    [fileManager removeItemAtPath: protocolsDirectory error: nil];
    [fileManager removeItemAtPath: categoriesDirectory error: nil];
    [fileManager removeItemAtPath: miscDirectory error: nil];

    /* Sort the top-level content */
    NSArray *nameDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: @"name" ascending: YES selector: @selector(localizedStandardCompare:)]];
    NSArray *classes = [library.classes sortedArrayUsingDescriptors: nameDescriptors];
    NSArray *protocols = [library.protocols sortedArrayUsingDescriptors: nameDescriptors];
    NSArray *categories = [library.categories sortedArrayUsingDescriptors: nameDescriptors];
    NSArray *functions = [library.functions sortedArrayUsingDescriptors: nameDescriptors];
    NSArray *constants = [library.constants sortedArrayUsingDescriptors: nameDescriptors];

    NSMutableArray *directoriesToCreate = [NSMutableArray array];

    if ([classes count] > 0) {
        [directoriesToCreate addObject: classesDirectory];
    }

    if ([protocols count] > 0) {
        [directoriesToCreate addObject: protocolsDirectory];
    }

    if ([categories count] > 0) {
        [directoriesToCreate addObject: categoriesDirectory];
    }

    if ([functions count] > 0 || [constants count] > 0) {
        [directoriesToCreate addObject: miscDirectory];
    }

    for (NSString *directory in directoriesToCreate) {
        if ([fileManager createDirectoryAtPath: directory withIntermediateDirectories: YES attributes: nil error: &error] == NO) {
            if (outError) {
                *outError = [self errorWithString: NSLocalizedString(@"Error creating HTML output directory", nil) underlyingError: error];
            }
            return;
        }
    }

    /* Copy dependent files */
    NSArray *files = @[@"css", @"js"];

    for (NSString *fileName in files) {
        NSString *source = [self.templatesDirectory stringByAppendingPathComponent: fileName];
        NSString *destination = [self.outputDirectory stringByAppendingPathComponent: fileName];
        [fileManager removeItemAtPath: destination error: &error];
        [fileManager copyItemAtPath: source toPath: destination error: &error];
    }

    NSMutableDictionary *context = [NSMutableDictionary dictionary];
    context[DTFrameworkNameKey] = self.frameworkName;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    context[DTGeneratedDateKey] = [dateFormatter stringFromDate: [NSDate date]];

    GRMustacheContext *mustacheContext = [[GRMustacheConfiguration defaultConfiguration] baseContext];
    mustacheContext = [mustacheContext contextByAddingObject: context];
    [[GRMustacheConfiguration defaultConfiguration] setBaseContext: mustacheContext];

    GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile: [self.templatesDirectory stringByAppendingPathComponent: @"objc_container.html"] error: &error];
    if (!template) {
        if (outError) {
            *outError = [self errorWithString: NSLocalizedString(@"Error parsing template", nil) underlyingError: error];
        }
        return;
    }

    GRMustacheTemplate *indexTemplate = [GRMustacheTemplate templateFromContentsOfFile: [self.templatesDirectory stringByAppendingPathComponent: @"index.html"] error: &error];
    context[DTTitleKey] = [NSString stringWithFormat: @"%@ Framework Reference", self.frameworkName];
    NSDictionary *index = @{
        DTClassesKey: classes,
        DTProtocolsKey: protocols,
        DTCategoriesKey: categories,
        DTFunctionsKey: functions,
        DTConstantsKey: constants,
        DTIncludeOtherReferencesKey: @([functions count] > 0 || [constants count] > 0)
    };
    NSString *indexPath = [self.outputDirectory stringByAppendingPathComponent: @"index.html"];
    [self renderObject: index withTemplate: indexTemplate path: indexPath error: outError];

    for (DTNode *class in classes) {
        context[DTTitleKey] = [NSString stringWithFormat: @"%@ Class Reference", class.name];
        NSString *path = [[classesDirectory stringByAppendingPathComponent: class.name] stringByAppendingPathExtension: @"html"];
        [self renderObject: class withTemplate: template path: path error: outError];
    }

    for (DTNode *protocol in protocols) {
        context[DTTitleKey] = [NSString stringWithFormat: @"%@ Protocol Reference", protocol.name];
        NSString *path = [[protocolsDirectory stringByAppendingPathComponent: protocol.name] stringByAppendingPathExtension: @"html"];
        [self renderObject: protocol withTemplate: template path: path error: outError];
    }

    if ([constants count] > 0) {
        context[DTTitleKey] = [NSString stringWithFormat: @"%@ Constants Reference", self.frameworkName];
        NSString *path = [miscDirectory stringByAppendingPathComponent: @"Constants.html"];
        [self renderObject: @{ DTConstantsKey: constants } withTemplate: template path: path error: outError];
    }

    if ([functions count] > 0) {
        context[DTTitleKey] = [NSString stringWithFormat: @"%@ Functions Reference", self.frameworkName];
        NSString *path = [miscDirectory stringByAppendingPathComponent: @"Functions.html"];
        [self renderObject: @{ DTFunctionsKey: functions } withTemplate: template path: path error: outError];
    }
}

- (BOOL) renderObject: (id) object withTemplate: (GRMustacheTemplate *) template path: (NSString *) path error: (NSError **) outError {
    NSError *error = nil;
    NSString *html = [template renderObject: object error: &error];
    if (!html) {
        if (outError) {
            *outError = [self errorWithString: NSLocalizedString(@"Error rendering template", nil) underlyingError: error];
        }
        return NO;
    }

    if ([html writeToFile: path atomically: NO encoding: NSUTF8StringEncoding error: &error] == NO) {
        if (outError) {
            *outError = [self errorWithString: NSLocalizedString(@"Error saving rendered template", nil) underlyingError: error];
        }
        return NO;
    }

    return YES;
}

- (void) processComments {
    [self assignHTMLPaths];

    [_library.nodes enumerateKeysAndObjectsUsingBlock: ^(NSString *USR, DTNode *node, BOOL *stop) {
        [self generateDeclarationForNode: node];
        [self processCommentForNode: node];
    }];
}

- (void) assignHTMLPaths {
    NSUInteger referenceNumber = 1;

    for (DTNode *node in _library.classes) {
        node.HTMLPath = [NSString stringWithFormat: @"Classes/%@.html", node.name];
        node.referenceNumber = @(referenceNumber++);
    }

    for (DTNode *node in _library.protocols) {
        node.HTMLPath = [NSString stringWithFormat: @"Protocols/%@.html", node.name];
        node.referenceNumber = @(referenceNumber++);
    }

    for (DTNode *node in _library.categories) {
        node.HTMLPath = [NSString stringWithFormat: @"Categories/%@.html", node.name];
        node.referenceNumber = @(referenceNumber++);
    }

    for (DTNode *node in _library.functions) {
        node.HTMLPath = @"Misc/Functions.html";
    }

    for (DTNode *node in _library.constants) {
        node.HTMLPath = @"Misc/Constants.html";
    }
}

/**
 * Creates a normalized HTML representation of a declaration, with links to known types.
 */
- (void) generateDeclarationForNode: (DTNode *) node {
    DTNode *containerNode = node.parent ?: node;
    PLClangCursor *cursor = node.cursor;
    NSMutableString *decl = [NSMutableString string];
    if (cursor.kind == PLClangCursorKindObjCInstanceMethodDeclaration || cursor.kind == PLClangCursorKindObjCClassMethodDeclaration) {
        [decl appendString: (cursor.kind == PLClangCursorKindObjCClassMethodDeclaration ? @"+" : @"-")];
        [decl appendString: @" ("];
        [decl appendString: [self linkForType: cursor.resultType relativeTo: containerNode.HTMLPath]];
        [decl appendString: @")"];

        // TODO: Is there a better way to get the keywords for the method name?
        if (cursor.arguments.count > 0) {
            NSArray *keywords = [cursor.spelling componentsSeparatedByString: @":"];
            NSAssert(keywords.count == (cursor.arguments.count + 1), @"Method name parts do not match argument count");

            [cursor.arguments enumerateObjectsUsingBlock: ^(PLClangCursor *argument, NSUInteger index, BOOL *stopArguments) {
                if (index > 0) {
                    [decl appendString: @" "];
                }
                [decl appendFormat: @"%@:(%@)<em>%@</em>", keywords[index], [self linkForType: argument.type relativeTo: containerNode.HTMLPath], argument.spelling];
            }];

            if (cursor.isVariadic) {
                [decl appendString: @", ..."];
            }

        } else {
            [decl appendString: cursor.spelling];
        }
    } else if (cursor.kind == PLClangCursorKindObjCPropertyDeclaration) {
        // TODO: Use libclang to get the attributes after updating to latest version
        NSRange range = [node.declaration rangeOfString: @")"];
        if (range.location != NSNotFound) {
            [decl appendString: [node.declaration substringToIndex: range.location + 1]];
        }

        [decl appendFormat: @" %@", [self linkForType: cursor.type relativeTo: containerNode.HTMLPath]];

        if (![cursor.type.spelling hasSuffix: @" *"]) {
            [decl appendString: @" "];
        }

        [decl appendString: cursor.spelling];
    } else if (cursor.kind == PLClangCursorKindFunctionDeclaration) {
        [decl appendString: @"<pre><code>"];
        [decl appendString: cursor.resultType.spelling];

        if (![cursor.resultType.spelling hasSuffix: @" *"]) {
            [decl appendString: @" "];
        }

        [decl appendString: cursor.spelling];
        [decl appendString: @"("];

        if (cursor.arguments.count > 0) {
            [cursor.arguments enumerateObjectsUsingBlock: ^(PLClangCursor *argument, NSUInteger index, BOOL *stopArguments) {
                if (index > 0) {
                    [decl appendString: @", "];
                }

                NSMutableString *typeSpelling = [NSMutableString stringWithString: argument.type.spelling];
                if (![typeSpelling hasSuffix: @" *"]) {
                    [typeSpelling appendString: @" "];
                }

                [decl appendFormat: @"\n    %@%@", typeSpelling, argument.spelling];
            }];

            if (cursor.isVariadic) {
                [decl appendString: @",\n    ..."];
            }

            [decl appendString: @"\n"];
        }

        [decl appendString: @");"];

        [decl appendString: @"</code></pre>"];
    }

    if ([decl length] > 0) {
        node.declarationHTML = decl;
    }
}

// TODO: The linking process needs to be rethought, currently assumptions are made
// up-front about where nodes will be documented. Deciding where comments or a
// declaration are written should be decided by the generator and the content
// created with links relative to that destination.
- (NSString *) linkForType: (PLClangType *) type relativeTo: (NSString *) path {

    // TODO: Finding our own types can be accomplished by looking up the USR.
    // What about inner frameworks from Core Services, how are those documented?

    // TODO: Need to handle pointer-to-pointer to get to class type?

    NSString *baseDirectory = [path stringByDeletingLastPathComponent];
    PLClangType *pointeeType = type;

    // Get the base type
    while (pointeeType.pointeeType) {
        pointeeType = pointeeType.pointeeType;
    }

    if (pointeeType.kind == PLClangTypeKindObjCInterface) {
        DTNode *class = _library.nodes[pointeeType.declaration.USR];

        if (class.HTMLPath) {
            if ([class.HTMLPath isEqualToString: path])
                return type.spelling;

            NSString *classReferenceURL = [self relativePathTo: class.HTMLPath fromBaseDirectory: baseDirectory];
            NSMutableString *link = [[type spelling] mutableCopy];
            NSRange range = [link rangeOfString: pointeeType.spelling];
            if (range.location == NSNotFound) {
                return type.spelling;
            }

            NSString *typeLink = [NSString stringWithFormat: @"<a href=\"%@\">%@</a>", classReferenceURL, pointeeType.spelling];
            [link replaceCharactersInRange: range withString: typeLink];
            return link;
        }

        // TODO: Expand, query system docsets so the API coverage is complete and always up-to-date.
        // Fast but evil way to do this is to query the sqlite Core Data db inside the docset. Alternative a list
        // can be built by scanning files, or a manual mapping of frameworks to base URLs can be maintained.
        // Note that Xcode is aware of the web URLs for local docset nodes, so there's no penalty for using a web
        // link here. When following such a link in the Xcode viewer the local docset page will be loaded instead.
        if ([type.spelling hasPrefix: @"NS"]) {
            NSURL *fileURL = [NSURL fileURLWithPath: pointeeType.declaration.location.path isDirectory: NO];
            NSArray *components = [fileURL pathComponents];
            __block NSString *classReferenceURL = nil;
            [components enumerateObjectsWithOptions: NSEnumerationReverse usingBlock: ^(NSString *component, NSUInteger index, BOOL *stop) {
                if ([[component pathExtension] isEqualToString: @"framework"]) {
                    NSString *frameworkName = [component stringByDeletingPathExtension];
                    // TODO: Determine if we should link to the Mac or iOS docs. Probably best to ask the user,
                    // but could key off headers used or target type.
                    classReferenceURL = [NSString stringWithFormat: @"http://developer.apple.com/library/mac/documentation/Cocoa/Reference/%@/Classes/%@_Class/", frameworkName, pointeeType.spelling];
                    *stop = YES;
                }
            }];

            if (classReferenceURL) {
                NSMutableString *link = [[type spelling] mutableCopy];
                NSRange range = [link rangeOfString: pointeeType.spelling];
                if (range.location == NSNotFound) {
                    return type.spelling;
                }

                NSString *typeLink = [NSString stringWithFormat: @"<a href=\"%@\">%@</a>", classReferenceURL, pointeeType.spelling];
                [link replaceCharactersInRange: range withString: typeLink];
                return link;
            }
        }
    } else if (pointeeType.kind == PLClangTypeKindTypedef) {
        DTNode *constant = _library.nodes[pointeeType.declaration.USR];
        if (!constant)
            constant = _library.nodes[pointeeType.canonicalType.declaration.USR];

        // TODO: If on same page, just link via anchor

        NSString *HTMLPath = constant.HTMLPath;
        if (!HTMLPath)
            HTMLPath = constant.parent.HTMLPath;

        if (HTMLPath) {
            if ([HTMLPath isEqualToString: path]) {
                HTMLPath = @"";
            } else {
                HTMLPath = [self relativePathTo: HTMLPath fromBaseDirectory: baseDirectory];
            }


            NSString *classReferenceURL = [NSString stringWithFormat: @"%@#%@", HTMLPath, constant.appleRef];
            //return [NSString stringWithFormat: @"<a href=\"%@\">%@</a> *", classReferenceURL, type.spelling];
            NSMutableString *link = [[type spelling] mutableCopy];
            NSRange range = [link rangeOfString: pointeeType.spelling];
            if (range.location == NSNotFound) {
                return type.spelling;
            }

            NSString *typeLink = [NSString stringWithFormat: @"<a href=\"%@\">%@</a>", classReferenceURL, pointeeType.spelling];
            [link replaceCharactersInRange: range withString: typeLink];
            return link;
        }
    }


    // TODO: Handle not found, declaration not found
    // Handle protocols vs classes for these sorts of links
    // Handle block and function pointer types
    // Expose protocol list in libclang, e.g. "Protocol" in "id<Protocol>"
    return type.spelling;
}

- (NSString *) relativePathTo: (NSString *) path fromBaseDirectory: (NSString *) baseDirectory {
    NSUInteger index = 0;
    NSMutableArray *baseComponents = [[baseDirectory pathComponents] mutableCopy];
	NSMutableArray *pathComponents = [[path pathComponents] mutableCopy];
	if ([[baseComponents lastObject] isEqualToString: @"/"])
        [baseComponents removeLastObject];

	while (index < [baseComponents count] && index < [pathComponents count] && [baseComponents[index] isEqualToString: pathComponents[index]]) {
		index++;
	}

	[baseComponents removeObjectsInRange: NSMakeRange(0, index)];
	[pathComponents removeObjectsInRange: NSMakeRange(0, index)];

	for (index = 0; index < [baseComponents count]; index++) {
		[pathComponents insertObject: @".." atIndex: 0];
	}

	return [NSString pathWithComponents: pathComponents];
}

- (void) processCommentForNode: (DTNode *) node {
    PLClangComment *parentComment = node.comment;
    if (!parentComment)
        return;

    _inInternal = NO;

    BOOL firstParagraph = YES;
    NSString *paragraph;
    NSMutableString *expandedComment = [NSMutableString string];
    NSMutableString *fullComment = [NSMutableString string];

    for (PLClangComment *comment in parentComment.children) {
        if (comment.kind == PLClangCommentKindParagraph) {
            paragraph = [self stringForParagraph: comment node: node];
            if (!paragraph)
                continue;

            // TODO: Only add <p> if not already wrapped
            NSString *wrappedParagraph = [NSString stringWithFormat: @"<p>%@</p>\n", paragraph];
            [fullComment appendString: wrappedParagraph];

            if (firstParagraph) {
                firstParagraph = NO;
                if ([node.briefComment length] < 1) {
                    node.briefComment = paragraph;
                }
            } else {
                [expandedComment appendString: wrappedParagraph];
            }
        } else if (comment.kind == PLClangCommentKindBlockCommand) {
            if ([comment.commandName isEqualToString: DTCommandNameBrief]) {
                NSString *string = [self stringForParagraph: comment.paragraph node: node];
                NSString *wrappedParagraph = [NSString stringWithFormat: @"<p>%@</p>\n", string];
                [fullComment appendString: wrappedParagraph];
                node.briefComment = string;
                firstParagraph = NO;
            } else if ([comment.commandName isEqualToString: DTCommandNameAttention]) {
                NSString *string = [self stringForParagraph: comment.paragraph node: node];
                string = [NSString stringWithFormat: @"<div class=\"important\"><aside><p><strong>Important:</strong> %@</p></aside></div>", string];
                [expandedComment appendString: string];
                [fullComment appendString: string];
            } else if ([comment.commandName isEqualToString: DTCommandNameNote]) {
                NSString *string = [self stringForParagraph: comment.paragraph node: node];
                string = [NSString stringWithFormat: @"<div class=\"note\"><aside><p><strong>Note:</strong> %@</p></aside></div>", string];
                [expandedComment appendString: string];
                [fullComment appendString: string];
            } else if ([comment.commandName isEqualToString: DTCommandNameWarning]) {
                NSString *string = [self stringForParagraph: comment.paragraph node: node];
                string = [NSString stringWithFormat: @"<div class=\"warning\"><aside><p><strong>Warning:</strong> %@</p></aside></div>", string];
                [expandedComment appendString: string];
                [fullComment appendString: string];
            } else if ([comment.commandName isEqualToString: DTCommandNameDeprecated]) {
                node.deprecated = YES;
                NSString *string = [self stringForParagraph: comment.paragraph node: node];
                if (string) {
                    node.deprecationComment = string;
                }
            } else if ([comment.commandName isEqualToString: DTCommandNameReturn]) {
                node.returnValueComment = [self stringForParagraph: comment.paragraph node: node];
            } else {
                // TODO: Log as warning
                NSLog(@"Unhandled block command %@ for %@", comment.commandName, node.name);
            }
        } else if (comment.kind == PLClangCommentKindParamCommand && comment.isParameterIndexValid) {
            DTNode *param = node.parameters[comment.parameterIndex];
            //[self processComment: comment forNode: param];
            NSString *string = [self stringForParagraph: comment.paragraph node: node];
            param.fullComment = string;
        } else {
            // TODO: Log as warning
            //NSString *command = comment.commandName ? [NSString stringWithFormat: @" (%@)", comment.commandName] : @"";
            //NSLog(@"Unhandled comment kind %@%@ for %@", [PLClangComment stringForCommentKind: comment.kind], command, node.name);
        }
    }

    node.fullComment = fullComment;
    node.expandedComment = expandedComment;
}

- (NSString *) stringForParagraph: (PLClangComment *) paragraphComment node: (DTNode *) node {
    NSParameterAssert(paragraphComment.kind == PLClangCommentKindParagraph);
    if (paragraphComment.isWhitespace)
        return nil;

    NSMutableString *paragraph = [NSMutableString string];
    for (PLClangComment *comment in paragraphComment.children) {
        switch (comment.kind) {
            case PLClangCommentKindText:
                if (!_inInternal) {
                    [paragraph appendString: comment.text];
                }
                break;
                // TODO: HTML
            case PLClangCommentKindInlineCommand:
                if ([comment.commandName isEqualToString: DTCommandNameInternal]) {
                    if (!_showInternalComments) {
                        _inInternal = YES;
                    }
                } else if ([comment.commandName isEqualToString: DTCommandNameEndInternal]) {
                    _inInternal = NO;
                } else if (comment.renderKind != PLClangCommentRenderKindNormal) {
                    if (_inInternal)
                        break;

                    NSString *arg = comment.arguments[0];
                    if ([arg length] < 1)
                        break;

                    switch (comment.renderKind) {
                        case PLClangCommentRenderKindBold:
                            [paragraph appendFormat: @"<b>%@</b>", arg];
                            break;
                        case PLClangCommentRenderKindMonospaced:
                            [paragraph appendFormat: @"<code>%@</code>", arg];
                            break;
                        case PLClangCommentRenderKindEmphasized:
                            [paragraph appendFormat: @"<em>%@</em>", arg];
                            break;
                        default:
                            break;
                    }
                } else {
                    NSLog(@"Unhandled inline command %@ in paragraph for %@", comment.commandName, node.name);
                }
                break;
            case PLClangCommentKindHTMLStartTag:
            case PLClangCommentKindHTMLEndTag:
                [paragraph appendString: comment.text];
                break;
            default:
                // TODO: Log as warning
                //NSLog(@"Unhandled comment kind %@ in paragraph for %@", [PLClangComment stringForCommentKind: comment.kind], node.name);
                break;
        }
    }

    NSString *trimmedParagraph = [paragraph stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([trimmedParagraph length] < 1)
        return nil;

    return trimmedParagraph;
}

- (NSError *) errorWithString: (NSString *) string underlyingError: (NSError *) underlyingError {
    return [NSError errorWithDomain: DTErrorDomain code: DTErrorHTMLOutputGeneration userInfo: @{
        NSLocalizedDescriptionKey: string,
        NSUnderlyingErrorKey: underlyingError
    }];
}

@end
