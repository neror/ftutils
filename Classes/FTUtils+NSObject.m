#import "FTUtils+NSObject.h"
#import <QuartzCore/QuartzCore.h>

@implementation NSObject (FTUtilsAdditions)

- (void)performSelector:(SEL)selector andReturnTo:(void *)returnData withArguments:(void **)arguments {
  NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
  [invocation setSelector:selector];
  
  NSUInteger argCount = [methodSignature numberOfArguments];
  
  for (int i=2; i < argCount; i++) {
    void *arg = arguments[i-2];
    [invocation setArgument:arg atIndex:i];
  }
  
  [invocation invokeWithTarget:self];
  if(returnData != NULL) {
    [invocation getReturnValue:returnData];
  }
}

- (void)performSelector:(SEL)selector withArguments:(void **)arguments {
  [self performSelector:selector andReturnTo:NULL withArguments:arguments];
}

- (void)performSelectorIfExists:(SEL)selector andReturnTo:(void *)returnData withArguments:(void **)arguments {
  if([self respondsToSelector:selector]) {
    [self performSelector:selector andReturnTo:returnData withArguments:arguments];
  }
}

- (void)performSelectorIfExists:(SEL)selector withArguments:(void **)arguments {
  [self performSelectorIfExists:selector andReturnTo:NULL withArguments:arguments];
}

@end

@implementation NSArray (FTUtilsAdditions)

- (NSArray *)reversedArray {
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
  NSEnumerator *enumerator = [self reverseObjectEnumerator];
  for (id element in enumerator) {
    [array addObject:element];
  }
  return [NSArray arrayWithArray:array];
}

@end

@implementation NSMutableArray (FTUtilsAdditions)

- (void)reverse {
  NSUInteger i = 0;
  NSUInteger j = [self count] - 1;
  while (i < j) {
    [self exchangeObjectAtIndex:i withObjectAtIndex:j];
    i++;
    j--;
  }
}

@end
