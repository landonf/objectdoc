/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "DTConfiguration.h"
#import "DocTool.h"
#import "PLAdditions.h"

@implementation DTConfiguration

- (instancetype) initWithPropertyList: (NSDictionary *) plist error: (NSError **) error {
    PLSuperInit();

    if (error)
        *error = nil;

    if (!plist) {
        return nil;
    }

    _htmlOutputEnabled = YES;

    _paths = plist[@"Paths"];
    if ([_paths count] < 1) {
        if (error) {
            *error = [self errorWithString: NSLocalizedString(@"No input paths specified.", nil)];
        }
        return nil;
    }

    _excludePatterns = plist[@"ExcludePatterns"];

    _fileTypes = [NSSet setWithArray: plist[@"FileTypes"]];
    if ([_fileTypes count] < 1) {
        _fileTypes = [NSSet setWithObjects: @"h", @"m", nil];
    }

    _outputPath = plist[@"OutputPath"];
    if ([_outputPath length] < 1) {
        if (error) {
            *error = [self errorWithString: NSLocalizedString(@"No output path specified.", nil)];
        }
        return nil;
    }

    _frameworkName = plist[@"Name"];
    if ([_frameworkName length] < 1) {
        if (error) {
            *error = [self errorWithString: NSLocalizedString(@"No framework name specified.", nil)];
        }
        return nil;
    }

    _docSetBundleId = plist[@"DocSetBundleId"];
    if ([_docSetBundleId length] > 0) {
        _docSetOutputEnabled = YES;
    } else {
        NSLog(@"No documentation set bundle ID specified, documentation set will not be generated.");
    }

    _docSetBundleVersion = plist[@"DocSetBundleVersion"];
    if ([_docSetBundleVersion length] < 1) {
        _docSetBundleVersion = @"1.0";
    }

    _docSetPublisherIdentifier = plist[@"DocSetPublisherId"];
    if ([_docSetPublisherIdentifier length] < 1) {
        _docSetPublisherIdentifier = [_docSetBundleId stringByDeletingPathExtension];
    }

    _docSetPublisherName = plist[@"DocSetPublisherName"];
    if ([_docSetPublisherName length] < 1) {
        _docSetPublisherName = _frameworkName;
    }

    _compilerArguments = plist[@"CompilerArguments"];
    if (_compilerArguments == nil) {
        _compilerArguments = @[];
    }

    NSNumber *showUndocumentedEntities = plist[@"ShowUndocumentedEntities"];
    if (showUndocumentedEntities) {
        _showUndocumentedEntities = [showUndocumentedEntities boolValue];
    } else {
        _showUndocumentedEntities = YES;
    }

    NSNumber *showInternalComments = plist[@"ShowInternalComments"];
    if (showInternalComments) {
        _showInternalComments = [showInternalComments boolValue];
    } else {
        _showInternalComments = NO;
    }

    return self;
}

- (NSError *) errorWithString: (NSString *) string {
    return [NSError errorWithDomain: DTErrorDomain code: DTErrorConfiguration userInfo: @{ NSLocalizedDescriptionKey: string }];
}

@end
