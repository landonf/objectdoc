#import "PLClangTestCase.h"

@implementation PLClangTestCase

- (void) setUp {
    [super setUp];
    _index = [[PLClangSourceIndex alloc] init];
}

/**
 * Convenience method to create a translation from the given source with options
 * suitable for typical unit testing.
 */
- (PLClangTranslationUnit *) translationUnitWithSource: (NSString *) source {
    return [self translationUnitWithSource: source path: @"test.m"];
}

/**
 * Convenience method to create a translation from the given source and path with
 * options suitable for typical unit testing.
 */
- (PLClangTranslationUnit *) translationUnitWithSource: (NSString *) source path: (NSString *) path {
    return [self translationUnitWithSource: source path: path options: 0];
}

/**
 * Convenience method to create a translation from the given source and path and options
 */
- (PLClangTranslationUnit *) translationUnitWithSource: (NSString *) source path: (NSString *) path options: (PLClangTranslationUnitCreationOptions) options {
    NSError *error = nil;
    NSData *data = [source dataUsingEncoding: NSUTF8StringEncoding];
    PLClangUnsavedFile *file = [PLClangUnsavedFile unsavedFileWithPath: path data: data];
    PLClangTranslationUnit *tu = [_index addTranslationUnitWithSourcePath: path unsavedFiles: @[file] compilerArguments: @[] options: options error: &error];
    STAssertNotNil(tu, @"Failed to parse", nil);
    STAssertNil(error, @"Received error for successful parse");
    STAssertFalse(tu.didFail, @"Should be marked as non-failed: %@", tu.diagnostics);

    return tu;
}

@end

@implementation PLClangTranslationUnit (TestingAdditions)

/**
 * Returns the first cursor in the translation unit with the specified spelling
 */
- (PLClangCursor *) cursorWithSpelling: (NSString *) spelling {
    __block PLClangCursor *cursor = nil;
    [self.cursor visitChildrenUsingBlock: ^PLClangCursorVisitResult(PLClangCursor *child) {
        if ([child.spelling isEqualToString: spelling]) {
            cursor = child;
            return PLClangCursorVisitBreak;
        }
        return PLClangCursorVisitRecurse;
    }];

    return cursor;
}

@end
