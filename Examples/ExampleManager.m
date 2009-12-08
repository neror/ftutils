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

#import "ExampleManager.h"
#import <objc/runtime.h>
#import "BackInOut.h"
#import "SlideInOut.h"
#import "FadeInOut.h"
#import "FadeBackgroundColorInOut.h"
#import "PopInOut.h"
#import "FallInOut.h"
#import "FlyOut.h"

@interface ExampleManager ()

+ (ExampleManager *)sharedSampleManager;

@end

@interface UIViewController (ThisIsHereToAviodACompilerWarning)

+ (NSString *)displayName;

@end

@implementation ExampleManager

#pragma mark -
#pragma mark Singleton Management

static ExampleManager *sharedSampleManager = nil;

+ (ExampleManager *)sharedSampleManager {
  @synchronized(self) {
    if (sharedSampleManager == nil) {
      sharedSampleManager = [[self alloc] init];
    }
  }
  return sharedSampleManager;
}

- (id)init {
  self = [super init];
  if (self != nil) {
    groups_ = [[NSArray alloc] initWithObjects:@"Animating Views",
                                               nil];
    
    samples_ = [[NSArray alloc] initWithObjects:[NSArray arrayWithObjects:[BackInOut class], 
                                                                          [SlideInOut class], 
                                                                          [FadeInOut class], 
                                                                          [FadeBackgroundColorInOut class], 
                                                                          [PopInOut class],
                                                                          [FallInOut class],
                                                                          [FlyOut class],
                                                                          nil], 
                                                nil]; 
  }
  return self;
}

#pragma mark -
#pragma mark Public class methods

+ (NSUInteger)groupCount {
  ExampleManager *SELF = [ExampleManager sharedSampleManager];
  return [SELF->groups_ count];
}

+ (NSUInteger)sampleCountForGroup:(NSUInteger)group {
  ExampleManager *SELF = [ExampleManager sharedSampleManager];
  return [[SELF->samples_ objectAtIndex:group] count];
}

+ (NSArray *)samplesForGroup:(NSUInteger)group {
  ExampleManager *SELF = [ExampleManager sharedSampleManager];
  return [[[SELF->samples_ objectAtIndex:group] copy] autorelease];
}

+ (NSString *)sampleNameAtIndexPath:(NSIndexPath *)indexPath {
  ExampleManager *SELF = [ExampleManager sharedSampleManager];
  NSArray *samples = [SELF->samples_ objectAtIndex:indexPath.section];
  Class clazz = [samples objectAtIndex:indexPath.row];
  return [clazz displayName];
}

+ (UIViewController *)sampleInstanceAtIndexPath:(NSIndexPath *)indexPath {
  ExampleManager *SELF = [ExampleManager sharedSampleManager];
  NSArray *samples = [SELF->samples_ objectAtIndex:indexPath.section];
  Class clazz = [samples objectAtIndex:indexPath.row];
  UIViewController *instance = [[clazz alloc] initWithNibName:nil bundle:nil];
  return [instance autorelease];
}

+ (NSString *)groupTitleAtIndex:(NSUInteger)index {
  ExampleManager *SELF = [ExampleManager sharedSampleManager];
 return [[[SELF->groups_ objectAtIndex:index] copy] autorelease];
}

@end
