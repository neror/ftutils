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
#import "FTAnimationManager.h"

NSString *const kFTAnimationName = @"kFTAnimationName";
NSString *const kFTAnimationType = @"kFTAnimationType";
NSString *const kFTAnimationTypeIn = @"kFTAnimationTypeIn";
NSString *const kFTAnimationTypeOut = @"kFTAnimationTypeOut";

NSString *const kFTAnimationSlideOut = @"kFTAnimationNameSlideOut";
NSString *const kFTAnimationSlideIn = @"kFTAnimationNameSlideIn";
NSString *const kFTAnimationBackOut = @"kFTAnimationNameBackOut";
NSString *const kFTAnimationBackIn = @"kFTAnimationNameBackIn";
NSString *const kFTAnimationFadeOut = @"kFTAnimationFadeOut";
NSString *const kFTAnimationFadeIn = @"kFTAnimationFadeIn";
NSString *const kFTAnimationFadeBackgroundOut = @"kFTAnimationFadeBackgroundOut";
NSString *const kFTAnimationFadeBackgroundIn = @"kFTAnimationFadeBackgroundIn";
NSString *const kFTAnimationPopIn = @"kFTAnimationPopIn";
NSString *const kFTAnimationPopOut = @"kFTAnimationPopOut";

NSString *const kFTAnimationCallerDelegateKey = @"kFTAnimationCallerDelegateKey";
NSString *const kFTAnimationCallerStartSelectorKey = @"kFTAnimationCallerStartSelectorKey";
NSString *const kFTAnimationCallerStopSelectorKey = @"kFTAnimationCallerStopSelectorKey";
NSString *const kFTAnimationTargetViewKey = @"kFTAnimationTargetViewKey";
NSString *const kFTAnimationIsChainedKey = @"kFTAnimationIsChainedKey";
NSString *const kFTAnimationNextAnimationKey = @"kFTAnimationNextAnimationKey";
NSString *const kFTAnimationPrevAnimationKey = @"kFTAnimationPrevAnimationKey";

@interface FTAnimationManager (Private)

- (CGPoint)overshootPointFor:(CGPoint)point withDirection:(FTAnimationDirection)direction threshold:(CGFloat)threshold;
- (CAAnimationGroup *)animationGroupFor:(NSArray *)animations withView:(UIView *)view 
                               duration:(NSTimeInterval)duration delegate:(id)delegate 
                          startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector 
                                   name:(NSString *)name type:(NSString *)type;

@end


@implementation FTAnimationManager

@synthesize overshootThreshold = overshootThreshold_;

#pragma mark -
#pragma mark Chained Animations

- (CAAnimation *)chainAnimations:(NSArray *)animations run:(BOOL)run{
  CAAnimation *head = nil;
  CAAnimation *prev = nil;
  
  for(CAAnimation *anim in animations) {
    if(!head) {
      head = anim;
    } else {
      [prev setValue:anim forKey:kFTAnimationNextAnimationKey];
    }
    [anim setValue:prev forKey:kFTAnimationPrevAnimationKey];
    [anim setValue:[NSNumber numberWithBool:YES] forKey:kFTAnimationIsChainedKey];
    prev = anim;
  }
  if(run) {
    UIView *target = [head valueForKey:kFTAnimationTargetViewKey];
    [target.layer addAnimation:head forKey:[head valueForKey:kFTAnimationName]];
  }
  return head;
}

#pragma mark -
#pragma mark Utility Methods

- (CAAnimationGroup *)animationGroupFor:(NSArray *)animations withView:(UIView *)view 
                               duration:(NSTimeInterval)duration delegate:(id)delegate 
                          startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector
                                   name:(NSString *)name type:(NSString *)type {
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.animations = [NSArray arrayWithArray:animations];
  group.delegate = self;
  group.duration = duration;
  group.removedOnCompletion = NO;
  if([type isEqualToString:kFTAnimationTypeOut]) {
    group.fillMode = kCAFillModeBoth;
  }
  group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [group setValue:view forKey:kFTAnimationTargetViewKey];
  [group setValue:delegate forKey:kFTAnimationCallerDelegateKey];
  if(!startSelector) {
    startSelector = @selector(animationDidStart:);
  }
  [group setValue:NSStringFromSelector(startSelector) forKey:kFTAnimationCallerStartSelectorKey];
  if(!stopSelector) {
    stopSelector = @selector(animationDidStop:finished:);
  }
  [group setValue:NSStringFromSelector(stopSelector) forKey:kFTAnimationCallerStopSelectorKey];
  [group setValue:name forKey:kFTAnimationName];
  [group setValue:type forKey:kFTAnimationType];
  return group;
}

#pragma mark -
#pragma mark Slide Animation Builders
- (CAAnimation *)slideInAnimationFor:(UIView *)view direction:(FTAnimationDirection)direction 
                            duration:(NSTimeInterval)duration delegate:(id)delegate 
                       startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
  animation.fromValue = [NSValue valueWithCGPoint:FTAnimationOffscreenCenterPoint(view.frame, view.center, direction)];
  animation.toValue = [NSValue valueWithCGPoint:view.center];
  return [self animationGroupFor:[NSArray arrayWithObject:animation] withView:view duration:duration 
                        delegate:delegate startSelector:startSelector stopSelector:stopSelector 
                            name:kFTAnimationSlideIn type:kFTAnimationTypeIn];
}

- (CAAnimation *)slideOutAnimationFor:(UIView *)view direction:(FTAnimationDirection)direction 
                             duration:(NSTimeInterval)duration delegate:(id)delegate 
                        startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector{
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
  animation.fromValue = [NSValue valueWithCGPoint:view.center];
  animation.toValue = [NSValue valueWithCGPoint:FTAnimationOffscreenCenterPoint(view.frame, view.center, direction)];
  return [self animationGroupFor:[NSArray arrayWithObject:animation] withView:view duration:duration 
                        delegate:delegate startSelector:startSelector stopSelector:stopSelector 
                            name:kFTAnimationSlideOut type:kFTAnimationTypeOut];
}

#pragma mark -
#pragma mark Bounce Animation Builders

- (CGPoint)overshootPointFor:(CGPoint)point withDirection:(FTAnimationDirection)direction threshold:(CGFloat)threshold {
  CGPoint overshootPoint;
  if(direction == kFTAnimationTop || direction == kFTAnimationBottom) {
    overshootPoint = CGPointMake(point.x, point.y + ((direction == kFTAnimationBottom ? -1 : 1) * threshold));
  } else {
    overshootPoint = CGPointMake(point.x + ((direction == kFTAnimationRight ? -1 : 1) * threshold), point.y);
  }
  return overshootPoint;
}

- (CAAnimation *)backOutAnimationFor:(UIView *)view direction:(FTAnimationDirection)direction 
                            duration:(NSTimeInterval)duration delegate:(id)delegate 
                       startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  CGPoint path[3] = {
    view.center,
    [self overshootPointFor:view.center withDirection:direction threshold:overshootThreshold_],
    FTAnimationOffscreenCenterPoint(view.frame, view.center, direction)
  };
  
  CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
  CGMutablePathRef thePath = CGPathCreateMutable();
  CGPathAddLines(thePath, NULL, path, 3);
  animation.path = thePath;
  CGPathRelease(thePath);
  return [self animationGroupFor:[NSArray arrayWithObject:animation] withView:view duration:duration 
                        delegate:delegate startSelector:startSelector stopSelector:stopSelector 
                            name:kFTAnimationBackOut type:kFTAnimationTypeOut];
}

- (CAAnimation *)backInAnimationFor:(UIView *)view direction:(FTAnimationDirection)direction 
                           duration:(NSTimeInterval)duration delegate:(id)delegate 
                      startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  CGPoint path[3] = {
    FTAnimationOffscreenCenterPoint(view.frame, view.center, direction),
    [self overshootPointFor:view.center withDirection:direction threshold:(overshootThreshold_ * 1.15)],
    view.center
  };
  
  CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
  CGMutablePathRef thePath = CGPathCreateMutable();
  CGPathAddLines(thePath, NULL, path, 3);
  animation.path = thePath;
  CGPathRelease(thePath);
  return [self animationGroupFor:[NSArray arrayWithObject:animation] withView:view duration:duration 
                        delegate:delegate startSelector:startSelector stopSelector:stopSelector 
                            name:kFTAnimationBackIn type:kFTAnimationTypeIn];
}

#pragma mark -
#pragma mark Fade Animation Builders

- (CAAnimation *)fadeAnimationFor:(UIView *)view duration:(NSTimeInterval)duration 
                         delegate:(id)delegate startSelector:(SEL)startSelector 
                     stopSelector:(SEL)stopSelector fadeOut:(BOOL)fadeOut {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  
  NSString *name, *type;
  if(fadeOut) {
    animation.fromValue = [NSNumber numberWithFloat:1.f];
    animation.toValue = [NSNumber numberWithFloat:0.f];
    name = kFTAnimationFadeOut;
    type = kFTAnimationTypeOut;
  } else {
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue = [NSNumber numberWithFloat:1.f];
    name = kFTAnimationFadeIn;
    type = kFTAnimationTypeIn;
  }
  CAAnimationGroup *group = [self animationGroupFor:[NSArray arrayWithObject:animation] withView:view duration:duration 
                                           delegate:delegate startSelector:startSelector stopSelector:stopSelector 
                                               name:name type:type];
  group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
  return group;
  
}


- (CAAnimation *)fadeBackgroundColorAnimationFor:(UIView *)view duration:(NSTimeInterval)duration 
                                   delegate:(id)delegate startSelector:(SEL)startSelector 
                                    stopSelector:(SEL)stopSelector fadeOut:(BOOL)fadeOut {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
  
  NSString *name, *type;
  if(fadeOut) {
    animation.fromValue = (id)view.layer.backgroundColor;
    animation.toValue = (id)[[UIColor clearColor] CGColor];
    name = kFTAnimationFadeBackgroundOut;
    type = kFTAnimationTypeOut;
  } else {
    animation.fromValue = (id)[[UIColor clearColor] CGColor];
    animation.toValue = (id)view.layer.backgroundColor;
    name = kFTAnimationFadeBackgroundIn;
    type = kFTAnimationTypeIn;
  }
  CAAnimationGroup *group = [self animationGroupFor:[NSArray arrayWithObject:animation] withView:view duration:duration 
                                           delegate:delegate startSelector:startSelector stopSelector:stopSelector
                                               name:name type:type];
  group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
  return group;
}

#pragma mark -
#pragma mark Pop Animation Builders

- (CAAnimation *)popInAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
                     startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
  scale.duration = duration;
  scale.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.5f],
                      [NSNumber numberWithFloat:1.2f],
                      [NSNumber numberWithFloat:.85f],
                      [NSNumber numberWithFloat:1.f],
                      nil];
  
  CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
  fadeIn.duration = duration * .66f;
  fadeIn.fromValue = [NSNumber numberWithFloat:0.f];
  fadeIn.toValue = [NSNumber numberWithFloat:1.f];
  fadeIn.fillMode = kCAFillModeForwards;
  
  CAAnimationGroup *group = [self animationGroupFor:[NSArray arrayWithObjects:scale, fadeIn, nil] withView:view duration:duration 
                                           delegate:delegate startSelector:startSelector stopSelector:stopSelector 
                                               name:kFTAnimationPopIn type:kFTAnimationTypeIn];
  group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  return group;
}

- (CAAnimation *)popOutAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
                      startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
  scale.duration = duration;
  scale.removedOnCompletion = NO;
  scale.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.f],
                      [NSNumber numberWithFloat:1.2f],
                      [NSNumber numberWithFloat:.75f],
                      nil];

  CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
  fadeOut.duration = duration;
  fadeOut.fromValue = [NSNumber numberWithFloat:1.f];
  fadeOut.toValue = [NSNumber numberWithFloat:0.f];
  fadeOut.fillMode = kCAFillModeForwards;
  
  return [self animationGroupFor:[NSArray arrayWithObjects:scale, fadeOut, nil] withView:view duration:duration 
                        delegate:delegate startSelector:startSelector stopSelector:stopSelector 
                            name:kFTAnimationPopOut type:kFTAnimationTypeOut];
}

#pragma mark -
#pragma mark Animation Delegate Methods

- (void)animationDidStart:(CAAnimation *)theAnimation {
  UIView *targetView = [theAnimation valueForKey:kFTAnimationTargetViewKey];
  [targetView setUserInteractionEnabled:NO];

  if([[theAnimation valueForKey:kFTAnimationType] isEqualToString:kFTAnimationTypeIn]) {
    [targetView setHidden:NO];
  }
  
  //Check for chaining and forward the delegate call if necessary
  id callerDelegate = [theAnimation valueForKey:kFTAnimationCallerDelegateKey];
  SEL startSelector = NSSelectorFromString([theAnimation valueForKey:kFTAnimationCallerStartSelectorKey]);

  FT_CALL_DELEGATE_WITH_ARG(callerDelegate, startSelector, theAnimation)
}
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished {
  UIView *targetView = [theAnimation valueForKey:kFTAnimationTargetViewKey];
  [targetView setUserInteractionEnabled:YES];

  if([[theAnimation valueForKey:kFTAnimationType] isEqualToString:kFTAnimationTypeOut]) {
    [targetView setHidden:YES];
    [targetView.layer removeAnimationForKey:[theAnimation valueForKey:kFTAnimationName]];
  }
  
  //Forward the delegate call
  id callerDelegate = [theAnimation valueForKey:kFTAnimationCallerDelegateKey];
  SEL stopSelector = NSSelectorFromString([theAnimation valueForKey:kFTAnimationCallerStopSelectorKey]);
  
  if([theAnimation valueForKey:kFTAnimationIsChainedKey]) {
    CAAnimation *next = [theAnimation valueForKey:kFTAnimationNextAnimationKey];
    if(next) {
      //Add the next animation to it's layer
      UIView *nextTarget = [next valueForKey:kFTAnimationTargetViewKey];
      [nextTarget.layer addAnimation:next forKey:[next valueForKey:kFTAnimationName]];
    }
  }
  
  FT_CALL_DELEGATE_WITH_ARGS(callerDelegate, stopSelector, theAnimation, [NSNumber numberWithBool:finished])
}

#pragma mark Singleton Boilerplate

static FTAnimationManager *sharedAnimationManager = nil;

+ (FTAnimationManager *)sharedManager {
  @synchronized(self) {
    if (sharedAnimationManager == nil) {
      [[self alloc] init]; // assignment not done here
    }
  }
  return sharedAnimationManager;
}

- (id)init {
  self = [super init];
  if (self != nil) {
    overshootThreshold_ = 10.f;
  }
  return self;
}


+ (id)allocWithZone:(NSZone *)zone {
  @synchronized(self) {
    if (sharedAnimationManager == nil) {
      sharedAnimationManager = [super allocWithZone:zone];
      return sharedAnimationManager;
    }
  }
  return nil;
}

- (id)copyWithZone:(NSZone *)zone {
  return self;
}

- (id)retain {
  return self;
}

- (unsigned)retainCount {
  return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
  
}

- (id)autorelease {
  return self;
}

@end

#pragma mark -

@implementation UIView (FTAnimationAdditions)

#pragma mark Slide Animations

- (void)slideInFrom:(FTAnimationDirection)direction duration:(NSTimeInterval)duration delegate:(id)delegate 
      startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  [CATransaction begin];
  {    
    CAAnimation *slideInAnim = [[FTAnimationManager sharedManager] slideInAnimationFor:self direction:direction 
                                                                              duration:duration delegate:delegate 
                                                                         startSelector:startSelector stopSelector:stopSelector];
    [self.layer addAnimation:slideInAnim forKey:kFTAnimationSlideIn];
  }
  [CATransaction commit];
}

- (void)slideInFrom:(FTAnimationDirection)direction duration:(NSTimeInterval)duration delegate:(id)delegate {
  [self slideInFrom:direction duration:duration delegate:delegate startSelector:nil stopSelector:nil];
}

- (void)slideOutTo:(FTAnimationDirection)direction duration:(NSTimeInterval)duration 
          delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  [CATransaction begin];
  {    
    CAAnimation *slideOutAnim = [[FTAnimationManager sharedManager] slideOutAnimationFor:self direction:direction 
                                                                                duration:duration delegate:delegate 
                                                                           startSelector:startSelector stopSelector:stopSelector];
    [self.layer addAnimation:slideOutAnim forKey:kFTAnimationSlideOut];
  }
  [CATransaction commit];
}


- (void)slideOutTo:(FTAnimationDirection)direction duration:(NSTimeInterval)duration delegate:(id)delegate {
  [self slideOutTo:direction duration:duration delegate:delegate startSelector:nil stopSelector:nil];
}

#pragma mark Back In/Out Animations

- (void)backOutTo:(FTAnimationDirection)direction duration:(NSTimeInterval)duration delegate:(id)delegate 
    startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  [CATransaction begin];
  {    
    CAAnimation *backOutAnim = [[FTAnimationManager sharedManager] backOutAnimationFor:self direction:direction 
                                                                              duration:duration delegate:delegate 
                                                                         startSelector:startSelector stopSelector:stopSelector];
    [self.layer addAnimation:backOutAnim forKey:kFTAnimationBackOut];
  }
  [CATransaction commit];
}

- (void)backOutTo:(FTAnimationDirection)direction duration:(NSTimeInterval)duration delegate:(id)delegate {
  [self backOutTo:direction duration:duration delegate:delegate startSelector:nil stopSelector:nil];
}

- (void)backInFrom:(FTAnimationDirection)direction duration:(NSTimeInterval)duration delegate:(id)delegate 
     startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  [CATransaction begin];
  {    
    CAAnimation *backInAnim = [[FTAnimationManager sharedManager] backInAnimationFor:self direction:direction 
                                                                            duration:duration delegate:delegate 
                                                                       startSelector:startSelector stopSelector:stopSelector];
    [self.layer addAnimation:backInAnim forKey:kFTAnimationBackIn];
  }
  [CATransaction commit];
}

- (void)backInFrom:(FTAnimationDirection)direction duration:(NSTimeInterval)duration delegate:(id)delegate {
  [self backInFrom:direction duration:duration delegate:delegate startSelector:nil stopSelector:nil];
}

#pragma mark -
#pragma mark Fade Animations

- (void)fadeIn:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  [CATransaction begin];
  {
    CAAnimation *anim = [[FTAnimationManager sharedManager] fadeAnimationFor:self duration:duration delegate:delegate 
                                                               startSelector:startSelector stopSelector:stopSelector fadeOut:NO];
    [self.layer addAnimation:anim forKey:kFTAnimationFadeIn];
  }
  [CATransaction commit];
}

- (void)fadeIn:(NSTimeInterval)duration delegate:(id)delegate {
  [self fadeIn:duration delegate:delegate startSelector:nil stopSelector:nil];
}

- (void)fadeOut:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  [CATransaction begin];
  {
    CAAnimation *anim = [[FTAnimationManager sharedManager] fadeAnimationFor:self duration:duration delegate:delegate 
                                                               startSelector:startSelector stopSelector:stopSelector fadeOut:YES];
    [self.layer addAnimation:anim forKey:kFTAnimationFadeOut];
  }
  [CATransaction commit];
}

- (void)fadeOut:(NSTimeInterval)duration delegate:(id)delegate {
  [self fadeOut:duration delegate:delegate startSelector:nil stopSelector:nil];
}

- (void)fadeBackgroundColorIn:(NSTimeInterval)duration delegate:(id)delegate 
                startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  [CATransaction begin];
  {
    CAAnimation *anim = [[FTAnimationManager sharedManager] fadeBackgroundColorAnimationFor:self duration:duration 
                                                                                   delegate:delegate startSelector:startSelector 
                                                                               stopSelector:stopSelector fadeOut:NO];
    [self.layer addAnimation:anim forKey:kFTAnimationFadeBackgroundIn];
  }
  [CATransaction commit];
}

- (void)fadeBackgroundColorIn:(NSTimeInterval)duration delegate:(id)delegate {
  [self fadeBackgroundColorIn:duration delegate:delegate startSelector:nil stopSelector:nil];
}

- (void)fadeBackgroundColorOut:(NSTimeInterval)duration delegate:(id)delegate 
                 startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  [CATransaction begin];
  {
    CAAnimation *anim = [[FTAnimationManager sharedManager] fadeBackgroundColorAnimationFor:self duration:duration 
                                                                                   delegate:delegate startSelector:startSelector 
                                                                               stopSelector:stopSelector fadeOut:YES];
    [self.layer addAnimation:anim forKey:kFTAnimationFadeBackgroundOut];
  }
  [CATransaction commit];
}

- (void)fadeBackgroundColorOut:(NSTimeInterval)duration delegate:(id)delegate {
  [self fadeBackgroundColorOut:duration delegate:delegate startSelector:nil stopSelector:nil];
}

#pragma mark -
#pragma mark Pop Animations

- (void)popIn:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  [CATransaction begin];
  {
    CAAnimation *anim = [[FTAnimationManager sharedManager] popInAnimationFor:self duration:duration delegate:delegate 
                                                                startSelector:startSelector stopSelector:stopSelector];
    [self.layer addAnimation:anim forKey:kFTAnimationPopIn];
  }
  [CATransaction commit];
}

- (void)popIn:(NSTimeInterval)duration delegate:(id)delegate {
  [self popIn:duration delegate:delegate startSelector:nil stopSelector:nil];
}

- (void)popOut:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  [CATransaction begin];
  {
    CAAnimation *anim = [[FTAnimationManager sharedManager] popOutAnimationFor:self duration:duration delegate:delegate 
                                                                 startSelector:startSelector stopSelector:stopSelector];
    [self.layer addAnimation:anim forKey:kFTAnimationPopOut];
  }
  [CATransaction commit];
}

- (void)popOut:(NSTimeInterval)duration delegate:(id)delegate {
  [self popOut:duration delegate:delegate startSelector:nil stopSelector:nil];
}

@end
