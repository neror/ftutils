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

#import <SenTestingKit/SenTestingKit.h>
#import "FTAnimationManager.h"

@interface TestFTAnimationManager : SenTestCase {
  UIView *rootView;
  UIView *dummyView;
}
@end

@implementation TestFTAnimationManager

- (void)setUp {
  rootView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  dummyView = [[UIView alloc] initWithFrame:CGRectMake(135.f, 215.f, 50.f, 50.f)];
  [rootView addSubview:dummyView];
}

- (void)tearDown {
  [dummyView removeFromSuperview];
  [dummyView release];
  dummyView = nil;
  [rootView release];
  rootView = nil;
}

- (void)testOffscreenCenterFor {
  CGPoint startCenter = CGPointMake(160.f, 240.f);
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  CGFloat expectedOffset = [dummyView frame].size.height / 2; 

  // Sanity check
  STAssertEquals([dummyView frame].size.height, [dummyView frame].size.width, @"dummyView is supposed to be a square");
  STAssertEquals(startCenter, [dummyView center], @"dummyView is not in the center of the screen: %@", NSStringFromCGPoint([dummyView center]));
  
  // Bottom
  CGFloat bottomExpected = screenBounds.size.height + expectedOffset;
  CGFloat bottomActual = FTAnimationOffscreenCenterPoint(dummyView.frame, dummyView.center, kFTAnimationBottom).y;
  STAssertEquals(bottomExpected, bottomActual, @"Bottom y should be %f, was %f", bottomExpected, bottomActual);

  // Top
  CGFloat topExpected = screenBounds.origin.y - expectedOffset;
  CGFloat topActual = FTAnimationOffscreenCenterPoint(dummyView.frame, dummyView.center, kFTAnimationTop).y;
  STAssertEquals(topExpected, topActual, @"Top y should be %f, was %f", topExpected, topActual);

  // Right
  CGFloat rightExpected = screenBounds.size.width + expectedOffset;
  CGFloat rightActual = FTAnimationOffscreenCenterPoint(dummyView.frame, dummyView.center, kFTAnimationRight).x;
  STAssertEquals(rightExpected, rightActual, @"Right x should be %f, was %f", rightExpected, rightActual);

  // Left
  CGFloat leftExpected = screenBounds.origin.x - expectedOffset;
  CGFloat leftActual = FTAnimationOffscreenCenterPoint(dummyView.frame, dummyView.center, kFTAnimationLeft).x;
  STAssertEquals(leftExpected, leftActual, @"Left x should be %f, was %f", leftExpected, leftActual);
}

- (void)verifyBounceAnimation:(CAAnimation *)animation uses:(int)count pathPoints:(CGPoint[])points {
  CAAnimationGroup *group = (CAAnimationGroup *)animation;
  CAKeyframeAnimation *keyframeAnimation = [[group animations] objectAtIndex:0];
  CGMutablePathRef expectedPath = CGPathCreateMutable();
  CGPathAddLines(expectedPath, NULL, points, count);
  STAssertTrue(CGPathEqualToPath(expectedPath, keyframeAnimation.path), @"Incorrect animation path for animation %@", animation);
  CGPathRelease(expectedPath);
}

- (void)testBackOutAnimationBuilder {
  FTAnimationManager *animationManager = [FTAnimationManager sharedManager];
  CGRect screenBounds = [[UIScreen mainScreen] bounds];

  CGPoint bounceOutBottomPoints[] = {
    dummyView.center,
    CGPointMake(dummyView.center.x, dummyView.center.y - [animationManager overshootThreshold]),
    CGPointMake(dummyView.center.x, screenBounds.size.height + dummyView.frame.size.height / 2)
  };
  CAAnimation *bounceOutBottom = [animationManager backOutAnimationFor:dummyView withFade:NO direction:kFTAnimationBottom
                                                              duration:0.1f delegate:nil 
                                                         startSelector:nil stopSelector:nil];
  [self verifyBounceAnimation:bounceOutBottom uses:3 pathPoints:bounceOutBottomPoints];

  CGPoint bounceOutTopPoints[] = {
    dummyView.center,
    CGPointMake(dummyView.center.x, dummyView.center.y + [animationManager overshootThreshold]),
    CGPointMake(dummyView.center.x, screenBounds.origin.y - dummyView.frame.size.height / 2)
  };
  CAAnimation *bounceOutTop = [animationManager backOutAnimationFor:dummyView withFade:NO direction:kFTAnimationTop 
                                                           duration:0.1f delegate:nil 
                                                      startSelector:nil stopSelector:nil];
  [self verifyBounceAnimation:bounceOutTop uses:3 pathPoints:bounceOutTopPoints];
  
  CGPoint bounceOutLeftPoints[] = {
    dummyView.center,
    CGPointMake(dummyView.center.x + [animationManager overshootThreshold], dummyView.center.y),
    CGPointMake(screenBounds.origin.x - dummyView.frame.size.width / 2, dummyView.center.y)
  };
  CAAnimation *bounceOutLeft = [animationManager backOutAnimationFor:dummyView withFade:NO direction:kFTAnimationLeft
                                                            duration:0.1f delegate:nil
                                                       startSelector:nil stopSelector:nil];
  [self verifyBounceAnimation:bounceOutLeft uses:3 pathPoints:bounceOutLeftPoints];

  CGPoint bounceOutRightPoints[] = {
    dummyView.center,
    CGPointMake(dummyView.center.x - [animationManager overshootThreshold], dummyView.center.y),
    CGPointMake(screenBounds.size.width + dummyView.frame.size.width / 2, dummyView.center.y)
  };
  CAAnimation *bounceOutRight = [animationManager backOutAnimationFor:dummyView withFade:NO direction:kFTAnimationRight 
                                                             duration:0.1f delegate:nil 
                                                        startSelector:nil stopSelector:nil];
  [self verifyBounceAnimation:bounceOutRight uses:3 pathPoints:bounceOutRightPoints];
  
}

- (void)testPopInAnimationBuilder {
  CAAnimationGroup *group = (CAAnimationGroup *)[[FTAnimationManager sharedManager] popInAnimationFor:dummyView 
                                                                                             duration:0.1f
                                                                                             delegate:nil
                                                                                        startSelector:nil
                                                                                         stopSelector:nil];
  CAKeyframeAnimation *keyframeAnimation = [[group animations] objectAtIndex:0];
  NSArray *expectedScales = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.5f], 
                                                      [NSNumber numberWithFloat:1.2f], 
                                                      [NSNumber numberWithFloat:.85f],
                                                      [NSNumber numberWithFloat:1.f], nil];
  STAssertEqualObjects(expectedScales, keyframeAnimation.values, nil);
}

@end
