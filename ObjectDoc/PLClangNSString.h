#import <Foundation/Foundation.h>
#import <clang-c/Index.h>

NSString *plclang_convert_cxstring(CXString string);
NSString *plclang_convert_and_dispose_cxstring(CXString string);
