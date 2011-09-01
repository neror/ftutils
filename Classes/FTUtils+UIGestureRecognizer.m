/*
 The MIT License
 
 Copyright (c) 2011 Free Time Studios and Nathan Eror
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#if NS_BLOCKS_AVAILABLE

#import "FTUtils+UIGestureRecognizer.h"
#import <objc/runtime.h>

@interface UIGestureRecognizer()

- (void)handleAction:(UIGestureRecognizer *)recognizer;

@end

static char * kFTGestureActionKey   = "ft_gestureAction";
static char * kFTGestureDisabledKey = "ft_gestureDisabled";

@implementation UIGestureRecognizer(FTBlockAdditions)

+ (id)recognizer {
  return [self recognizerWithActionBlock:nil];
}

+ (id)recognizerWithActionBlock:(FTGestureActionBlock)action {
  id me = [[self class] alloc];
  me = [me initWithTarget:me action:@selector(handleAction:)];
  [me setActionBlock:action];
  return [me autorelease];
}

- (void)handleAction:(UIGestureRecognizer *)recognizer {
  if(self.actionBlock && !self.disabled) {
    self.actionBlock(recognizer);
  }
}

- (FTGestureActionBlock)actionBlock {
  return objc_getAssociatedObject(self, kFTGestureActionKey);
}

- (void)setActionBlock:(FTGestureActionBlock)actionBlock {
  objc_setAssociatedObject(self, kFTGestureActionKey, actionBlock, OBJC_ASSOCIATION_COPY);
}

- (BOOL)disabled {
  return [objc_getAssociatedObject(self, kFTGestureDisabledKey) boolValue];
}

- (void)setDisabled:(BOOL)disabled {
  objc_setAssociatedObject(self, kFTGestureDisabledKey, [NSNumber numberWithBool:disabled], OBJC_ASSOCIATION_RETAIN);
}

@end

#endif