/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "DTDocSetGenerator.h"
#import "DocTool.h"
#import "GRMustache.h"

@implementation DTDocSetGenerator

- (void) generateDocumentationForLibrary: (DTLibrary *) library error: (NSError **) error {
    NSString *docSetOutputDirectory = [[self.outputDirectory stringByAppendingPathComponent: self.bundleIdentifier] stringByAppendingPathExtension: @"docset"];
    self.outputDirectory = [docSetOutputDirectory stringByAppendingPathComponent: @"Contents/Resources/Documents"];
    [super generateDocumentationForLibrary: library error: error];

    NSString *contentsDirectory = [docSetOutputDirectory stringByAppendingPathComponent: @"Contents"];

    NSBundle *xcodeBundle = [self selectedXcodeBundle];
    if (!xcodeBundle) {
        if (error) {
            *error = [NSError errorWithDomain: DTErrorDomain code: DTErrorHTMLOutputGeneration userInfo: @{
                NSLocalizedDescriptionKey: NSLocalizedString(@"Could not locate selected Xcode bundle.", nil)
            }];
        }
        return;
    }

    NSString *minimumXcodeVersion = [self docSetMinimumXcodeVersionForBundle: xcodeBundle];
    if (!minimumXcodeVersion) {
        if (error) {
            *error = [NSError errorWithDomain: DTErrorDomain code: DTErrorHTMLOutputGeneration userInfo: @{
                NSLocalizedDescriptionKey: NSLocalizedString(@"Could not obtain minimum docset version from selected Xcode bundle.", nil)
            }];
        }
    }

    NSDictionary *infoPlist = @{
        @"CFBundleIdentifier": self.bundleIdentifier,
        @"CFBundleName": self.bundleName,
        @"CFBundleVersion": self.bundleVersion,
        @"DocSetPublisherIdentifier": self.publisherIdentifier,
        @"DocSetPublisherName": self.publisherName,
        @"DocSetMinimumXcodeVersion": minimumXcodeVersion
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

    // Set the modification date to indicate changes to an existing doc set package directory
    [[NSFileManager defaultManager] setAttributes: @{ NSFileModificationDate: [NSDate date] } ofItemAtPath: docSetOutputDirectory error: nil];
}

- (void) indexDocSetAtPath: (NSString *) path {
    NSTask *task = [NSTask launchedTaskWithLaunchPath: @"/usr/bin/xcrun" arguments: @[@"docsetutil", @"index", path]];
    [task waitUntilExit];
}

/**
 * Return the minimum Xcode version needed for compatibility with the generted docset.
 *
 * It is important that this be as correct as possible because docsets are not backward
 * compatible and if Xcode loads a docset it does not understand it will likely crash.
 * Unfortunately docsetutil does not appear to have any way to query the required Xcode
 * version and this information is not published anywhere. As docsetutil itself does not
 * have a version number, obtain the major version of the selected Xcode bundle and use
 * this as the minimum version.
 */
- (NSString *) docSetMinimumXcodeVersionForBundle: (NSBundle *) bundle {
    NSString *xcodeVersion = bundle.infoDictionary[@"CFBundleShortVersionString"];
    int majorVersion = 0;
    NSScanner *scanner = [NSScanner scannerWithString: xcodeVersion];
    if ([scanner scanInt:&majorVersion] == NO)
        return nil;

    return [NSString stringWithFormat:@"%d.0", majorVersion];
}

/**
 * Return the currently selected Xcode bundle, as identified by xcode-select --print-path
 *
 * This is used instead of querying Launch Services because Launch Services will return the
 * bundle with the highest version number, while this method will return the bundle used to
 * service xcrun invocations.
 */
- (NSBundle *) selectedXcodeBundle {
    NSBundle *result = nil;
    NSPipe *outputPipe = [NSPipe pipe];
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/xcode-select";
    task.arguments = @[@"--print-path"];
    task.standardInput = [NSPipe pipe];
    task.standardOutput = outputPipe;
    task.standardError = [NSPipe pipe];
    [task launch];
    [task waitUntilExit];

    NSData *pathData = [outputPipe.fileHandleForReading readDataToEndOfFile];
    NSString *path = [[NSString alloc] initWithData: pathData encoding: NSUTF8StringEncoding];
    path = [path stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // Use a URL here because isFilePackageAtPath: is part of AppKit
    NSURL *fileURL = [NSURL fileURLWithPath: path];
    NSUInteger count = [[fileURL pathComponents] count];
    if (count == 0)
        return result;

    for (NSUInteger i = 0; i < count - 1; i++) {
        NSNumber *isPackage = nil;
        [fileURL getResourceValue:&isPackage forKey: NSURLIsPackageKey error: nil];
        if ([isPackage boolValue]) {
            result = [NSBundle bundleWithURL:fileURL];
            break;
        }
        fileURL = [fileURL URLByDeletingLastPathComponent];
    }

    return result;
}

@end
