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

#import "SimpleAnimationExample.h"
#import <QuartzCore/QuartzCore.h>

@implementation SimpleAnimationExample

@synthesize viewToAnimate = viewToAnimate_;
@synthesize performAnimationButton = performAnimationButton_;
@synthesize directionControl = directionControl_;

+ (NSString *)displayName {
  return @"";
}

#pragma mark init and dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.title = [[self class] displayName];
  }
  return self;
}

- (void)dealloc {
  self.viewToAnimate = nil;
  self.performAnimationButton = nil;
  self.directionControl = nil;
  [super dealloc];
}

- (void)setHasDirectionControl:(BOOL)hasDirection {
  if(hasDirection && (self.directionControl.superview == nil)) {
    [self.view insertSubview:self.directionControl belowSubview:self.viewToAnimate];
  } else if(!hasDirection && self.directionControl.superview != nil){
    [self.directionControl removeFromSuperview];
  }
}

- (BOOL)hasDirectionControl {
  return (self.directionControl.superview != nil);
}

#pragma mark Load and unload the view

- (void)loadView {
  self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Checkers.png"]];;
  
  self.viewToAnimate = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ViewBackground.png"]] autorelease];
  self.viewToAnimate.opaque = NO;
  self.viewToAnimate.backgroundColor = [UIColor clearColor];
  self.viewToAnimate.frame = CGRectMake(20., 10., 280., 280.);
  
  self.performAnimationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  self.performAnimationButton.frame = CGRectMake(10., 356., 300., 44.);
  [self.performAnimationButton setTitle:@"Run Animation" forState:UIControlStateNormal];
  [self.performAnimationButton addTarget:self action:@selector(performAnimation:) forControlEvents:UIControlEventTouchUpInside];
  
  NSArray *directionItems = [NSArray arrayWithObjects:@"Top", @"Right", @"Bottom", @"Left", nil];
  self.directionControl = [[[UISegmentedControl alloc] initWithItems:directionItems] autorelease];
  self.directionControl.selectedSegmentIndex = 0;
  self.directionControl.frame = CGRectMake(10., 300., 300., 44.);
  
  [self.view addSubview:self.performAnimationButton];
  [self.view addSubview:self.viewToAnimate];
}


#pragma mark Event Handling

- (void)performAnimation:(id)sender {
  NSAssert(NO, @"performAnimation: must be overridden by subclasses");
}

@end


