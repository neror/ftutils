#import <Foundation/Foundation.h>

@interface NSObject (FTUtilsAdditions)

- (void)performSelector:(SEL)selector andReturnTo:(void *)returnData withArguments:(void **)arguments;
- (void)performSelector:(SEL)selector withArguments:(void **)arguments;
- (void)performSelectorIfExists:(SEL)selector andReturnTo:(void *)returnData withArguments:(void **)arguments;
- (void)performSelectorIfExists:(SEL)selector withArguments:(void **)arguments;

@end

@interface NSArray (FTUtilsAdditions)

- (NSArray *)reversedArray;

@end

@interface NSMutableArray (FTUtilsAdditions)

- (void)reverse;

@end
