/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "DTDocSetGenerator.h"
#import "GRMustache.h"

@implementation DTDocSetGenerator

- (void) generateDocumentationForLibrary: (DTLibrary *) library error: (NSError **) error {
    NSString *docSetOutputDirectory = [[self.outputDirectory stringByAppendingPathComponent: self.bundleIdentifier] stringByAppendingPathExtension: @"docset"];
    self.outputDirectory = [docSetOutputDirectory stringByAppendingPathComponent: @"Contents/Resources/Documents"];
    [super generateDocumentationForLibrary: library error: error];

    NSString *contentsDirectory = [docSetOutputDirectory stringByAppendingPathComponent: @"Contents"];

    // TODO: Determine the minimum Xcode version based on the version of the version of Xcode containing
    // docsetutil. There doesn't seem to be a better way, as docsetutil itself has no version and does
    // not seem to expose what the minimum required Xcode version is. This has to be right because Xcode
    // will most likely crash if it tries to load a docset in a format it doesn't understand.
    NSDictionary *infoPlist = @{
        @"CFBundleIdentifier": self.bundleIdentifier,
        @"CFBundleName": self.bundleName,
        @"CFBundleVersion": self.bundleVersion,
        @"DocSetPublisherIdentifier": self.publisherIdentifier,
        @"DocSetPublisherName": self.publisherName,
        @"DocSetMinimumXcodeVersion": @"5.0"
    };
    [infoPlist writeToFile: [contentsDirectory stringByAppendingPathComponent: @"Info.plist"] atomically: NO];

    GRMustacheTemplate *nodesTemplate = [GRMustacheTemplate templateFromContentsOfFile: [self.templatesDirectory stringByAppendingPathComponent: @"Nodes.xml"] error: error];
    NSString *nodesXML = [nodesTemplate renderObject: library error: error];
    if (nodesXML) {
        NSString *path = [[contentsDirectory stringByAppendingPathComponent: @"Resources/Nodes"] stringByAppendingPathExtension: @"xml"];
        [nodesXML writeToFile: path atomically: NO encoding: NSUTF8StringEncoding error: error];
    }

    GRMustacheTemplate *tokensTemplate = [GRMustacheTemplate templateFromContentsOfFile: [self.templatesDirectory stringByAppendingPathComponent: @"Tokens.xml"] error: error];
    NSString *tokensXML = [tokensTemplate renderObject: library error: error];
    if (tokensXML) {
        NSString *path = [[contentsDirectory stringByAppendingPathComponent: @"Resources/Tokens"] stringByAppendingPathExtension: @"xml"];
        [tokensXML writeToFile: path atomically: NO encoding: NSUTF8StringEncoding error: error];
    }

    [self indexDocSetAtPath: docSetOutputDirectory];
}

- (void) indexDocSetAtPath: (NSString *) path {
    NSTask *task = [NSTask launchedTaskWithLaunchPath: @"/usr/bin/xcrun" arguments: @[@"docsetutil", @"index", path]];
    [task waitUntilExit];
}

@end
