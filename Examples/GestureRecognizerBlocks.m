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

#import "GestureRecognizerBlocks.h"
#import "FTUtils+UIGestureRecognizer.h"

@implementation GestureRecognizerBlocks

+ (NSString *)displayName {
  return @"Gesture Recognizer Blocks";
}

- (void)viewDidLoad {
  [self.performAnimationButton removeFromSuperview];
  self.viewToAnimate.userInteractionEnabled = YES;
  self.viewToAnimate.multipleTouchEnabled = YES;

#if NS_BLOCKS_AVAILABLE  
  
  [self.viewToAnimate addGestureRecognizer:
   [UIPanGestureRecognizer recognizerWithActionBlock:^(UIPanGestureRecognizer *pan) {
    if(pan.state == UIGestureRecognizerStateBegan || 
       pan.state == UIGestureRecognizerStateChanged) {
      CGPoint translation = [pan translationInView:self.viewToAnimate.superview];
      
      self.viewToAnimate.center =  CGPointMake(self.viewToAnimate.center.x + translation.x, 
                                               self.viewToAnimate.center.y + translation.y);
      [pan setTranslation:CGPointZero inView:self.viewToAnimate.superview];
    }
  }]];
  
  UIPinchGestureRecognizer *thePinch = [UIPinchGestureRecognizer recognizer];
  thePinch.actionBlock = ^(UIPinchGestureRecognizer *pinch) {
    if ([pinch state] == UIGestureRecognizerStateBegan || 
        [pinch state] == UIGestureRecognizerStateChanged) {
      self.viewToAnimate.transform = CGAffineTransformScale(self.viewToAnimate.transform, pinch.scale, pinch.scale);
      [pinch setScale:1];
    }
  };
  [self.viewToAnimate addGestureRecognizer:thePinch];
  
  UITapGestureRecognizer *doubleTap = [UITapGestureRecognizer recognizerWithActionBlock:^(id dTap) {
    thePinch.disabled = !thePinch.disabled;
    [UIView animateWithDuration:.25f animations:^{
      self.viewToAnimate.transform = CGAffineTransformIdentity;
    }];
  }];
  doubleTap.numberOfTapsRequired = 2;
  [self.viewToAnimate addGestureRecognizer:doubleTap];
  
#endif
}

- (void)viewDidUnload {
  for(UIGestureRecognizer *recognizer in self.viewToAnimate.gestureRecognizers) {
    [self.viewToAnimate removeGestureRecognizer:recognizer];
  }
}

@end
