/*
 * Copyright (c) 2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 */

#import "PLClangSourceLocation.h"
#import "PLClangSourceLocationPrivate.h"
#import "PLClangTranslationUnitPrivate.h"
#import "PLClangNSString.h"
#import "PLAdditions.h"

/**
 * A clang source location within a translation unit.
 */
@implementation PLClangSourceLocation {
@private
    /** The owner of the clang data structure backing _location. This is used
     * to ensure the lifetime of the CXSourceLocation. */
    id _owner;

    /** Backing clang source location. */
    CXSourceLocation _location;

    /**
     * Indicates whether or not the expansion location has been read from the
     * source location.
     *
     * Obtaining the expansion location is an expensive operation, so it is
     * deferred until a property that requires it is read.
     */
    BOOL _expansionLocationRead;

    /** The path to the file. */
    NSString *_path;

    /** The byte offset within the file. */
    off_t _fileOffset;

    /** The line number within the file. */
    NSUInteger _lineNumber;

    /** The column number within the file. */
    NSUInteger _columnNumber;
}

/**
 * Initialize a newly-created source range with the specified translation unit, and offset within a source file.
 *
 * @param translationUnit The translation unit containing the source location.
 * @param path Path to the source file containing the source location.
 * @param offset Byte offset within the source file.
 * @return An initialized source location or nil if the requested location is invalid.
 *
 * @internal
 * clang's behavior in handling a request for a source location beyond the range of the source file is
 * inconsistent. If given a file offset beyond the file's range it will return a garbage location. If
 * given a line or column number beyond the file's range it will return the closest source location within
 * the file. To be consistent in this API, check that the resulting source location is what was requested
 * and return nil if not.
 */
- (instancetype) initWithTranslationUnit: (PLClangTranslationUnit *) translationUnit file: (NSString *) path offset: (off_t) offset {
    if (!translationUnit || !path)
        return nil;

    CXFile file = clang_getFile([translationUnit cxTranslationUnit], [path fileSystemRepresentation]);
    if (!file)
        return nil;

    CXSourceLocation sourceLocation = clang_getLocationForOffset([translationUnit cxTranslationUnit], file, (unsigned int)offset);
    PLClangSourceLocation *location = [self initWithOwner: translationUnit cxSourceLocation: sourceLocation];
    if (location != nil && location.fileOffset != offset)
        return nil;

    return location;
}

/**
 * Initialize a newly-created source range with the specified translation unit, and line and column numbers within a source file.
 *
 * @param translationUnit The translation unit containing the source location.
 * @param path Path to the source file containing the source location.
 * @param lineNumber 1-based line number within the source file containing.
 * @param columnNumber 1-based column number within the source file.
 * @return An initialized source location or nil if the requested location is invalid.
 *
 * @internal
 * clang's behavior in handling a request for a source location beyond the range of the source file is
 * inconsistent. If given a file offset beyond the file's range it will return a garbage location. If
 * given a line or column number beyond the file's range it will return the closest source location within
 * the file. To be consistent in this API, check that the resulting source location is what was requested
 * and return nil if not.
 */
- (instancetype) initWithTranslationUnit: (PLClangTranslationUnit *) translationUnit file: (NSString *) path lineNumber: (NSUInteger) lineNumber columnNumber: (NSUInteger) columnNumber {
    if (!translationUnit || !path)
        return nil;

    CXFile file = clang_getFile([translationUnit cxTranslationUnit], [path fileSystemRepresentation]);
    if (!file)
        return nil;

    CXSourceLocation sourceLocation = clang_getLocation([translationUnit cxTranslationUnit], file, (unsigned int)lineNumber, (unsigned int)columnNumber);
    PLClangSourceLocation *location = [self initWithOwner: translationUnit cxSourceLocation: sourceLocation];
    if (location != nil && (location.lineNumber != lineNumber || location.columnNumber != columnNumber))
        return nil;

    return location;
}

- (NSString *) path {
    if (_expansionLocationRead == NO) {
        [self readExpansionLocation];
    }

    return _path;
}

- (off_t) fileOffset {
    if (_expansionLocationRead == NO) {
        [self readExpansionLocation];
    }

    return _fileOffset;
}

- (NSUInteger) lineNumber {
    if (_expansionLocationRead == NO) {
        [self readExpansionLocation];
    }

    return _lineNumber;
}

- (NSUInteger) columnNumber {
    if (_expansionLocationRead == NO) {
        [self readExpansionLocation];
    }

    return _columnNumber;
}

- (BOOL) isInMainFile {
    return clang_Location_isFromMainFile(_location);
}

- (BOOL) isInSystemHeader {
    return clang_Location_isInSystemHeader(_location);
}

- (BOOL) isEqual: (id) object {
    if (![object isKindOfClass: [PLClangSourceLocation class]])
        return NO;

    return clang_equalLocations(_location, [object cxSourceLocation]);
}

/**
 * @internal
 * Clang should provide a function for this similar to clang_hashCursor().
 * For now this is based on the implementation of clang_equalLocations(), which
 * checks for equality of the data pointers.
 */
- (NSUInteger) hash {
    return (NSUInteger)_location.ptr_data[0] ^ (NSUInteger)_location.ptr_data[1] ^ _location.int_data;
}

- (NSString *) description {
    return [NSString stringWithFormat: @"%@:%lu:%lu",
            self.path,
            (unsigned long)self.lineNumber,
            (unsigned long)self.columnNumber];
}

- (void) readExpansionLocation {
    CXFile file = NULL;
    unsigned int line = 0, column = 0, offset = 0;
    clang_getExpansionLocation(_location, &file, &line, &column, &offset);

    _path = plclang_convert_and_dispose_cxstring(clang_getFileName(file));
    _fileOffset = offset;
    _lineNumber = line;
    _columnNumber = column;

    _expansionLocationRead = YES;
}

@end

/**
 * @internal
 * Package-private methods.
 */
@implementation PLClangSourceLocation (PackagePrivate)

/**
 * Initialize with the source location
 *
 * @param owner An Objective-C reference to the owner of the sourceLocation value. This reference will
 * be retained, as to ensure that @a sourceLocation survives for the lifetime of the source location instance.
 * @param sourceLocation Backing clang location.
 * @return An initialized source location or nil if a null clang source location was provided.
 */
- (instancetype) initWithOwner: (id) owner cxSourceLocation: (CXSourceLocation) sourceLocation {
    PLSuperInit();

    if (clang_equalLocations(sourceLocation, clang_getNullLocation()))
        return nil;

    _owner = owner;
    _location = sourceLocation;

    return self;
}

- (CXSourceLocation) cxSourceLocation {
    return _location;
}

@end