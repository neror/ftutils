#import <UIKit/UIKit.h>
#import "GTMStackTrace.h"
#import "RunTests.h"

void exceptionHandler(NSException *exception) {
	FTLOG(@"%@", GTMStackTraceFromException(exception));
}

int main(int argc, char *argv[]) {
	NSSetUncaughtExceptionHandler(&exceptionHandler);
  
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  RunTests *runTests = [[[RunTests alloc] init] autorelease];
  [[NSNotificationCenter defaultCenter] addObserver:runTests selector:@selector(run:) name:UIApplicationDidFinishLaunchingNotification object:nil];

  int retVal = UIApplicationMain(argc, argv, nil, nil);
  
  [pool release];
  return retVal;
}
