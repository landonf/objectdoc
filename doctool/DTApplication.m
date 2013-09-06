/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "DTApplication.h"
#import "DTConfiguration.h"
#import "DTSourceParser.h"
#import "DTDocSetGenerator.h"
#import "PLClang.h"
#import <glob.h>

@implementation DTApplication

- (BOOL) run {
    NSError *error = nil;
    NSBundle *bundle = [NSBundle mainBundle];
    DTConfiguration *config = nil;

    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    if ([arguments count] == 1) {
        NSLog(@"Usage: doctool --config configfile");
        return NO;
    }

    // TODO: Real argument parsing, probably clang compilation database support.
    for (NSUInteger i = 1; i < [arguments count]; i++) {
        NSString *arg = arguments[i];

        if ([arg isEqualToString: @"--version"]) {
            NSString *version = [bundle infoDictionary][@"CFBundleShortVersionString"];
            NSLog(@"doctool %@\nBased on %@", version, PLClangGetVersionString());
            return YES;
        } else if ([arg isEqualToString: @"--config"] && [arguments count] > i+1) {
            NSString *configFile = arguments[i+1];
            NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile: configFile];
            config = [[DTConfiguration alloc] initWithPropertyList: plist error: &error];
            i++;

            if (error) {
                NSLog(@"Error reading configuration file: %@", error);
                return NO;
            }
        }
    }

    if (!config) {
        NSLog(@"No configuration file specified.");
        return NO;
    }

    /* Create a cache directory (for precompiled headers) */
    NSString *baseCachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSString *cachePath = [baseCachePath stringByAppendingPathComponent: [bundle bundleIdentifier]];
    if (![[NSFileManager defaultManager] createDirectoryAtPath: cachePath withIntermediateDirectories: YES attributes: nil error: &error]) {
        NSLog(@"Error creating cache path %@: %@", cachePath, error);
        return NO;
    }

    DTSourceParser *parser = [[DTSourceParser alloc] initWithCachePath: cachePath];
    if ([parser parseSourceFiles: [self sourceFilesForConfiguration: config] withCompilerArguments: config.compilerArguments] == NO)
        return NO;

    DTLibrary *library = [parser.library filteredLibraryForConfiguration: config];

    // TODO: Determine how to distribute template files.
    // For now assume they are copied alongside the executable.
    NSString *templatesDirectory = [bundle pathForResource: @"templates" ofType: @""];

    NSMutableArray *generators = [NSMutableArray array];
    DTHTMLGenerator *htmlGenerator = [[DTHTMLGenerator alloc] init];
    htmlGenerator.frameworkName = config.frameworkName;
    htmlGenerator.showInternalComments = config.showInternalComments;
    htmlGenerator.outputDirectory = config.outputPath;
    htmlGenerator.templatesDirectory = templatesDirectory;
    [generators addObject: htmlGenerator];

    if ([config.docSetPublisherIdentifier length] > 1) {
        DTDocSetGenerator *docSetGenerator = [[DTDocSetGenerator alloc] init];
        docSetGenerator.frameworkName = config.frameworkName;
        docSetGenerator.showInternalComments = config.showInternalComments;
        docSetGenerator.outputDirectory = config.outputPath;
        docSetGenerator.templatesDirectory = templatesDirectory;
        docSetGenerator.bundleIdentifier = config.docSetBundleId;
        docSetGenerator.bundleName = config.frameworkName;
        docSetGenerator.bundleVersion = config.docSetBundleVersion;
        docSetGenerator.publisherIdentifier = config.docSetPublisherIdentifier;
        docSetGenerator.publisherName = config.docSetPublisherName;
        [generators addObject: docSetGenerator];
    }

    for (id<DTGenerator> generator in generators) {
        [generator generateDocumentationForLibrary: library error: &error];
        if (error) {
            NSLog(@"Error generating HTML output: %@", error);
            return NO;
        }
    }

    return YES;
}

/**
 * Return an array of source files to parse.
 *
 * TODO: Consider use of glob(), may want to use regex.
 * Consider whether there's existing code or a better way to do this in general,
 * may want to specify exclusion of a specific sub-path without applying a global
 * pattern.
 */
- (NSSet *) sourceFilesForConfiguration: (DTConfiguration *) config {
    NSMutableSet *sourceFiles = [NSMutableSet set];
    NSMutableSet *excludedPaths = [NSMutableSet set];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    /* Expand any globbed input paths */
    NSMutableArray *searchPaths = [NSMutableArray array];
    for (NSString *path in config.paths) {
        glob_t pglob = {};
        glob([path fileSystemRepresentation], GLOB_TILDE, NULL, &pglob);
        for (int i = 0; i < pglob.gl_matchc; i++) {
            [searchPaths addObject: [NSString stringWithUTF8String: pglob.gl_pathv[i]]];
        }
    }

    /* Build the set of exclude paths */
    NSMutableSet *inputDirectories = [NSMutableSet set];
    for (NSString *inputPath in searchPaths) {
        BOOL isDirectory = NO;
        if ([fileManager fileExistsAtPath: inputPath isDirectory: &isDirectory] == NO)
            continue;

        if (isDirectory) {
            [inputDirectories addObject: inputPath];

            NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath: inputPath];
            for (NSString *path in enumerator) {
                NSString *fullPath = [inputPath stringByAppendingPathComponent: path];
                [fileManager fileExistsAtPath: fullPath isDirectory: &isDirectory];

                if (isDirectory) {
                    [inputDirectories addObject: fullPath];
                }
            }
        } else {
            [inputDirectories addObject: [inputPath stringByDeletingLastPathComponent]];
        }
    }

    for (NSString *directory in inputDirectories) {
        for (NSString *pattern in config.excludePatterns) {
            NSString *fullPattern = [directory stringByAppendingPathComponent: pattern];
            glob_t pglob = {};
            glob([fullPattern fileSystemRepresentation], GLOB_TILDE, NULL, &pglob);
            for (int i = 0; i < pglob.gl_matchc; i++) {
                [excludedPaths addObject: [NSString stringWithUTF8String: pglob.gl_pathv[i]]];
            }
        }
    }

    /* Build the array of source files */
    for (NSString *inputPath in searchPaths) {
        BOOL isDirectory = NO;
        if ([fileManager fileExistsAtPath: inputPath isDirectory: &isDirectory] == NO)
            continue;

        if ([excludedPaths containsObject: inputPath]) {
            continue;
        }

        if (isDirectory == NO && [config.fileTypes containsObject: [inputPath pathExtension]]) {
            [sourceFiles addObject: inputPath];
            continue;
        }

        NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath: inputPath];
        for (NSString *path in enumerator) {
            NSString *fullPath = [inputPath stringByAppendingPathComponent: path];
            [fileManager fileExistsAtPath: fullPath isDirectory: &isDirectory];

            if ([excludedPaths containsObject: fullPath]) {
                if (isDirectory) {
                    [enumerator skipDescendants];
                }
                continue;
            }

            if (isDirectory == NO && [config.fileTypes containsObject: [fullPath pathExtension]]) {
                [sourceFiles addObject: fullPath];
            }
        }
    }

    return sourceFiles;
}

@end
