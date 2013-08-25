#import <Foundation/Foundation.h>
#import <clang-c/Index.h>
@class PLClangTranslationUnit;

@interface PLClangTokenSet : NSObject

- (instancetype) initWithTranslationUnit: (PLClangTranslationUnit *) tu cxTokens: (CXToken *) tokens count: (unsigned) count;

@end
