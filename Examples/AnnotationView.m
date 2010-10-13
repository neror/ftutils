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

#import "AnnotationView.h"
#import <FTUtils/FTAnnotationView.h>
#import <FTAnimation.h>
#import <QuartzCore/QuartzCore.h>

#define FINGER_SIZE 40.f

@interface AnnotationView (Private)

- (void)handleTap:(UITapGestureRecognizer *)gesture;

@end

@implementation AnnotationView

@synthesize annotationView;
@synthesize fingerView;

+ (NSString *)displayName {
  return @"Annotation View";
}

- (void)viewDidLoad {
  FTAnnotationView *annotation = [[FTAnnotationView alloc] initWithFrame:CGRectZero];
  [annotation setBubbleColor:[UIColor blackColor]];
  annotation.titleText = @"Tap Detected";
  self.annotationView = annotation;
  [annotation release];
  
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
  [self.view addGestureRecognizer:tap];
  [tap release];
  
  UIView *finger = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, FINGER_SIZE, FINGER_SIZE)];
  finger.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:.75f];
  finger.clipsToBounds = YES;
  finger.layer.cornerRadius = 6.f;
  self.fingerView = finger;
  [fingerView release];
  
  [super viewDidLoad];
}

- (void)viewDidUnload {
  self.annotationView = nil;
  self.fingerView = nil;
  [super viewDidUnload];
}

- (void)dealloc {
  self.annotationView = nil;
  self.fingerView = nil;
  [super dealloc];
}

#pragma mark -
#pragma mark Event handlers

- (void)handleTap:(UITapGestureRecognizer *)gesture {
  CGPoint tapLocation = [gesture locationInView:self.view];
  CGRect fingerRect = CGRectMake(tapLocation.x - FINGER_SIZE / 2.f, tapLocation.y - FINGER_SIZE / 2.f, FINGER_SIZE, FINGER_SIZE);
  
  if(self.fingerView.superview) {
    [self.fingerView removeFromSuperview];
  }
  self.fingerView.frame = fingerRect;
  [self.view addSubview:self.fingerView];
  [self.fingerView fadeIn:.2f delegate:nil];
  
  if(self.annotationView.superview) {
    [self.annotationView dismiss];
  }
  self.annotationView.bodyText = [NSString stringWithFormat:@"%@", NSStringFromCGPoint(tapLocation)];
  
  [self.annotationView showForRect:fingerRect inView:self.view animated:YES];
}

@end
