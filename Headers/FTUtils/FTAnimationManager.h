/*
 The MIT License
 
 Copyright (c) 2009 Free Time Studios and Nathan Eror
 
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

/*!
 @file FTAnimationManager.h
 @brief The FTAnimationManager.h file is the heart of the FTUtils animation utilites.
*/
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

typedef enum _FTAnimationDirection {
  kFTAnimationTop = 0,
  kFTAnimationRight,
  kFTAnimationBottom,
  kFTAnimationLeft
} FTAnimationDirection;

#pragma mark String Constants

extern NSString *const kFTAnimationName;
extern NSString *const kFTAnimationType;
extern NSString *const kFTAnimationTypeIn;
extern NSString *const kFTAnimationTypeOut;

extern NSString *const kFTAnimationSlideIn;
extern NSString *const kFTAnimationSlideOut;
extern NSString *const kFTAnimationBackOut;
extern NSString *const kFTAnimationBackIn;
extern NSString *const kFTAnimationFadeOut;
extern NSString *const kFTAnimationFadeIn;
extern NSString *const kFTAnimationFadeBackgroundOut;
extern NSString *const kFTAnimationFadeBackgroundIn;
extern NSString *const kFTAnimationPopIn;
extern NSString *const kFTAnimationPopOut;
extern NSString *const kFTAnimationFallIn;
extern NSString *const kFTAnimationFallOut;
extern NSString *const kFTAnimationFlyOut;

extern NSString *const kFTAnimationTargetViewKey;

#pragma mark Inline Functions

static inline CGPoint FTAnimationOffscreenCenterPoint(CGRect viewFrame, CGPoint viewCenter, FTAnimationDirection direction) {
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  switch (direction) {
    case kFTAnimationBottom: {
      CGFloat extraOffset = viewFrame.size.height / 2;
      return CGPointMake(viewCenter.x, screenRect.size.height + extraOffset);
      break;
    }
    case kFTAnimationTop: {
      CGFloat extraOffset = viewFrame.size.height / 2;
      return CGPointMake(viewCenter.x, screenRect.origin.y - extraOffset);
      break;
    }
    case kFTAnimationLeft: {
      CGFloat extraOffset = viewFrame.size.width / 2;
      return CGPointMake(screenRect.origin.x - extraOffset, viewCenter.y);
      break;
    }
    case kFTAnimationRight: {
      CGFloat extraOffset = viewFrame.size.width / 2;
      return CGPointMake(screenRect.size.width + extraOffset, viewCenter.y);
      break;
    }
  }
  return CGPointZero;  
}

/*!
 @class FTAnimationManager
 @brief The FTAnimationManager class is the heart of the FTUtils Core Animation utilities.

 This class is meant to be used as a singleton. Developers should avoid creating
 mulitple instances and should get a reference to an instance via the 
 FTAnimationManager#sharedManager class method.
*/
@interface FTAnimationManager : NSObject {
  CGFloat overshootThreshold_;
}

/*!
 The maximum value (in pixels) that the bouncing animations will travel past their end vlaue before coming to rest. The default is 10.0.
*/
@property(assign) CGFloat overshootThreshold;

/*!
 Get a reference to the FTAnimationManager singleton creating it if necessary.
 @return The singleton.
*/
+ (FTAnimationManager *)sharedManager;

- (CAAnimationGroup *)delayStartOfAnimation:(CAAnimation *)animation withDelay:(CFTimeInterval)delayTime;
- (CAAnimationGroup *)pauseAtEndOfAnimation:(CAAnimation *)animation withDelay:(CFTimeInterval)delayTime;
- (CAAnimation *)chainAnimations:(NSArray *)animations run:(BOOL)run;

- (CAAnimationGroup *)animationGroupFor:(NSArray *)animations withView:(UIView *)view 
                               duration:(NSTimeInterval)duration delegate:(id)delegate 
                          startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector 
                                   name:(NSString *)name type:(NSString *)type;

- (CAAnimation *)slideInAnimationFor:(UIView *)view direction:(FTAnimationDirection)direction 
                            duration:(NSTimeInterval)duration delegate:(id)delegate 
                       startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;
- (CAAnimation *)slideOutAnimationFor:(UIView *)view direction:(FTAnimationDirection)direction 
                             duration:(NSTimeInterval)duration delegate:(id)delegate 
                        startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;

- (CAAnimation *)backOutAnimationFor:(UIView *)view withFade:(BOOL)fade direction:(FTAnimationDirection)direction 
                            duration:(NSTimeInterval)duration delegate:(id)delegate 
                       startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;
- (CAAnimation *)backInAnimationFor:(UIView *)view withFade:(BOOL)fade direction:(FTAnimationDirection)direction 
                           duration:(NSTimeInterval)duration delegate:(id)delegate 
                      startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;

- (CAAnimation *)fadeAnimationFor:(UIView *)view duration:(NSTimeInterval)duration 
                         delegate:(id)delegate startSelector:(SEL)startSelector 
                     stopSelector:(SEL)stopSelector fadeOut:(BOOL)fadeOut;

- (CAAnimation *)fadeBackgroundColorAnimationFor:(UIView *)view duration:(NSTimeInterval)duration 
                                        delegate:(id)delegate startSelector:(SEL)startSelector 
                                    stopSelector:(SEL)stopSelector fadeOut:(BOOL)fadeOut;

- (CAAnimation *)popInAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
                     startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;
- (CAAnimation *)popOutAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
                      startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;

- (CAAnimation *)fallInAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
                      startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;
- (CAAnimation *)fallOutAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
                       startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;
- (CAAnimation *)flyOutAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
                      startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;


@end

@interface CAAnimation (FTAnimationAdditions)

- (void)setStartSelector:(SEL)selector withTarget:(id)target;
- (void)setStopSelector:(SEL)selector withTarget:(id)target;

@end
