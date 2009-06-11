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
