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

#import "RunTests.h"
#import "GTMIPhoneUnitTestDelegate.h"
#import "GTMNSObject+UnitTesting.h"

@implementation RunTests

- (void)run:(id)sender {
  [NSObject gtm_setUnitTestSaveToDirectory:@"/Users/neror/Desktop/"];
  GTMIPhoneUnitTestDelegate *testDelegate = [[GTMIPhoneUnitTestDelegate alloc] init];
  [testDelegate runTests];
  NSUInteger totalFailures = [testDelegate totalFailures];
  [testDelegate release];
#if 1
  int exitStatus = ((totalFailures == 0U) ? 0 : 1);
  exit(exitStatus);
#endif
}

@end
