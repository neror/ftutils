#import "GTMSenTestCase.h"
#import <FTUtils/FTAnimationManager.h>

@interface TestFTAnimationManager : GTMTestCase {
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
  FTRELEASE(dummyView);
  FTRELEASE(rootView);
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

- (void)verifyBackAnimation:(CAAnimation *)animation uses:(int)count pathPoints:(CGPoint[])points {
  CAAnimationGroup *group = (CAAnimationGroup *)animation;
  CAKeyframeAnimation *keyframeAnimation = [[group animations] objectAtIndex:0];
  CGMutablePathRef expectedPath = CGPathCreateMutable();
  CGPathAddLines(expectedPath, NULL, points, count);
  FTLOG(@"%d", CGPathEqualToPath(expectedPath, keyframeAnimation.path));
  STAssertTrue(CGPathEqualToPath(expectedPath, keyframeAnimation.path), @"Incorrect animation path for animation %@", animation);
  CGPathRelease(expectedPath);
}

- (void)testBackOutAnimationBuilder {
  FTAnimationManager *animationManager = [FTAnimationManager sharedManager];
  CGRect screenBounds = [[UIScreen mainScreen] bounds];

  CGPoint backOutBottomPoints[] = {
    dummyView.center,
    CGPointMake(dummyView.center.x, dummyView.center.y - [animationManager overshootThreshold]),
    CGPointMake(dummyView.center.x, screenBounds.size.height + dummyView.frame.size.height / 2)
  };
  CAAnimation *backOutBottom = [animationManager backOutAnimationFor:dummyView direction:kFTAnimationBottom duration:0.1f delegate:nil];
  [self verifyBackAnimation:backOutBottom uses:3 pathPoints:backOutBottomPoints];

  CGPoint backOutTopPoints[] = {
    dummyView.center,
    CGPointMake(dummyView.center.x, dummyView.center.y + [animationManager overshootThreshold]),
    CGPointMake(dummyView.center.x, screenBounds.origin.y - dummyView.frame.size.height / 2)
  };
  CAAnimation *backOutTop = [animationManager backOutAnimationFor:dummyView direction:kFTAnimationTop duration:0.1f delegate:nil];
  [self verifyBackAnimation:backOutTop uses:3 pathPoints:backOutTopPoints];
  
  CGPoint backOutLeftPoints[] = {
    dummyView.center,
    CGPointMake(dummyView.center.x + [animationManager overshootThreshold], dummyView.center.y),
    CGPointMake(screenBounds.origin.x - dummyView.frame.size.width / 2, dummyView.center.y)
  };
  CAAnimation *backOutLeft = [animationManager backOutAnimationFor:dummyView direction:kFTAnimationLeft duration:0.1f delegate:nil];
  [self verifyBackAnimation:backOutLeft uses:3 pathPoints:backOutLeftPoints];

  CGPoint backOutRightPoints[] = {
    dummyView.center,
    CGPointMake(dummyView.center.x - [animationManager overshootThreshold], dummyView.center.y),
    CGPointMake(screenBounds.size.width + dummyView.frame.size.width / 2, dummyView.center.y)
  };
  CAAnimation *backOutRight = [animationManager backOutAnimationFor:dummyView direction:kFTAnimationRight duration:0.1f delegate:nil];
  [self verifyBackAnimation:backOutRight uses:3 pathPoints:backOutRightPoints];
  
}

- (void)testPopInAnimationBuilder {
  CAAnimationGroup *group = (CAAnimationGroup *)[[FTAnimationManager sharedManager] popInAnimationFor:dummyView duration:0.1f delegate:nil];
  CAKeyframeAnimation *keyframeAnimation = [[group animations] objectAtIndex:0];
  NSArray *expectedScales = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.5f], [NSNumber numberWithFloat:1.2f], [NSNumber numberWithFloat:.85f], [NSNumber numberWithFloat:1.f], nil];
  STAssertEqualObjects(expectedScales, keyframeAnimation.values, nil);
}

@end
