#import <SenTestingKit/SenTestingKit.h>
#import "PLClangSourceIndex.h"

@interface PLClangTestCase : SenTestCase {
    PLClangSourceIndex *_index;
}

- (PLClangTranslationUnit *) translationUnitWithSource: (NSString *) source;

- (PLClangTranslationUnit *) translationUnitWithSource: (NSString *) source
                                                  path: (NSString *) path;

@end

@interface PLClangTranslationUnit (TestingAdditions)

- (PLClangCursor *) cursorWithSpelling: (NSString *) spelling;

@end
