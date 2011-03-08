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

#import "AnimationChaining.h"
#import "FTAnimation.h"

@implementation AnimationChaining

@synthesize redView = redView_;
@synthesize greenView = greenView_;
@synthesize blueView = blueView_;

@synthesize performAnimationButton = performAnimationButton_;

+ (NSString *)displayName {
  return @"Animation Chaining";
}

#pragma mark init and dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = [[self class] displayName];
  }
  return self;
}

- (void)dealloc {
  self.redView = nil;
  self.greenView = nil;
  self.blueView = nil;
  self.performAnimationButton = nil;
  [super dealloc];
}


#pragma mark Load and unload the view

- (void)loadView {
  self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Checkers.png"]];;
  
  self.redView = [[[UIView alloc] initWithFrame:CGRectMake(10.f, 20.f, 300.f, 40.f)] autorelease];
  self.redView.backgroundColor = [UIColor redColor];
  self.redView.hidden = YES;
  [self.view addSubview:self.redView];
  
  self.greenView = [[[UIView alloc] initWithFrame:CGRectMake(10.f, 70.f, 300.f, 40.f)] autorelease];
  self.greenView.backgroundColor = [UIColor greenColor];
  self.greenView.hidden = YES;
  [self.view addSubview:self.greenView];

  self.blueView = [[[UIView alloc] initWithFrame:CGRectMake(10.f, 120.f, 300.f, 40.f)] autorelease];
  self.blueView.backgroundColor = [UIColor blueColor];
  self.blueView.hidden = YES;
  [self.view addSubview:self.blueView];  
  
  self.performAnimationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  self.performAnimationButton.frame = CGRectMake(10., 356., 300., 44.);
  [self.performAnimationButton setTitle:@"Run Animation" forState:UIControlStateNormal];
  [self.performAnimationButton addTarget:self action:@selector(performAnimation:) forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addSubview:self.performAnimationButton];
}

#pragma mark Animation delegates

- (void)redAnimationStopped:(CAAnimation *)anim finished:(BOOL)finished {
  FTAnimationManager *animManager = [FTAnimationManager sharedManager];
  
  CAAnimation *redOut = [animManager backOutAnimationFor:self.redView withFade:NO direction:kFTAnimationTop 
                                                duration:1.f delegate:nil startSelector:nil stopSelector:nil];
  
  CAAnimation *greenOut = [animManager backOutAnimationFor:self.greenView withFade:NO direction:kFTAnimationTop 
                                                  duration:.7f delegate:nil startSelector:nil stopSelector:nil];
  greenOut = [animManager delayStartOfAnimation:greenOut withDelay:.3f];
  
  CAAnimation *blueOut = [animManager backOutAnimationFor:self.blueView withFade:NO direction:kFTAnimationTop 
                                                 duration:.4f delegate:nil startSelector:nil stopSelector:nil];
  blueOut = [animManager delayStartOfAnimation:blueOut withDelay:.6f];
  
  [CATransaction begin];
    [self.redView.layer addAnimation:redOut forKey:nil];
    [self.greenView.layer addAnimation:greenOut forKey:nil];
    [self.blueView.layer addAnimation:blueOut forKey:nil];
  [CATransaction commit];
}

#pragma mark Event Handlers

- (void)performAnimation:(id)sender {
  FTAnimationManager *animManager = [FTAnimationManager sharedManager];
  
  CAAnimation *red = [animManager backInAnimationFor:self.redView withFade:NO 
                                           direction:kFTAnimationTop duration:.6f 
                                            delegate:nil startSelector:nil stopSelector:nil];
  CAAnimation *green = [animManager backInAnimationFor:self.greenView withFade:NO 
                                             direction:kFTAnimationTop duration:.6f 
                                              delegate:nil startSelector:nil stopSelector:nil];
  CAAnimation *blue = [animManager backInAnimationFor:self.blueView withFade:NO 
                                            direction:kFTAnimationTop duration:.6f 
                                             delegate:nil startSelector:nil stopSelector:nil];
  
  [red setStopSelector:@selector(redAnimationStopped:finished:) withTarget:self];
  
  [animManager chainAnimations:[NSArray arrayWithObjects:blue, green, red, nil] run:YES];  
}

@end
