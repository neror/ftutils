#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FTMacros.h"

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

@interface FTAnimationManager : NSObject {
  CGFloat overshootThreshold_;
}

@property(assign) CGFloat overshootThreshold;

+ (FTAnimationManager *)sharedManager;

- (CAAnimation *)chainAnimations:(NSArray *)animations run:(BOOL)run;

- (CAAnimation *)slideInAnimationFor:(UIView *)view direction:(FTAnimationDirection)direction 
                             duration:(NSTimeInterval)duration delegate:(id)delegate 
                       startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;
- (CAAnimation *)slideOutAnimationFor:(UIView *)view direction:(FTAnimationDirection)direction 
                            duration:(NSTimeInterval)duration delegate:(id)delegate 
                        startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;

- (CAAnimation *)backOutAnimationFor:(UIView *)view direction:(FTAnimationDirection)direction 
                            duration:(NSTimeInterval)duration delegate:(id)delegate 
                       startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;
- (CAAnimation *)backInAnimationFor:(UIView *)view direction:(FTAnimationDirection)direction 
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


@end

@interface UIView (FTAnimationAdditions)

- (void)slideInFrom:(FTAnimationDirection)direction duration:(NSTimeInterval)duration delegate:(id)delegate;
- (void)slideInFrom:(FTAnimationDirection)direction duration:(NSTimeInterval)duration delegate:(id)delegate 
      startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;
- (void)slideOutTo:(FTAnimationDirection)direction duration:(NSTimeInterval)duration delegate:(id)delegate;
- (void)slideOutTo:(FTAnimationDirection)direction duration:(NSTimeInterval)duration delegate:(id)delegate 
     startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;

- (void)backOutTo:(FTAnimationDirection)direction duration:(NSTimeInterval)duration delegate:(id)delegate;
- (void)backOutTo:(FTAnimationDirection)direction duration:(NSTimeInterval)duration delegate:(id)delegate 
    startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;
- (void)backInFrom:(FTAnimationDirection)direction duration:(NSTimeInterval)duration delegate:(id)delegate;
- (void)backInFrom:(FTAnimationDirection)direction duration:(NSTimeInterval)duration delegate:(id)delegate 
     startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;

- (void)fadeIn:(NSTimeInterval)duration delegate:(id)delegate;
- (void)fadeIn:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;
- (void)fadeOut:(NSTimeInterval)duration delegate:(id)delegate;
- (void)fadeOut:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;

- (void)fadeBackgroundColorIn:(NSTimeInterval)duration delegate:(id)delegate;
- (void)fadeBackgroundColorIn:(NSTimeInterval)duration delegate:(id)delegate 
                startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;
- (void)fadeBackgroundColorOut:(NSTimeInterval)duration delegate:(id)delegate;
- (void)fadeBackgroundColorOut:(NSTimeInterval)duration delegate:(id)delegate 
                 startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;

- (void)popIn:(NSTimeInterval)duration delegate:(id)delegate;
- (void)popIn:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;
- (void)popOut:(NSTimeInterval)duration delegate:(id)delegate;
- (void)popOut:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;

@end
