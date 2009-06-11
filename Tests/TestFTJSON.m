#import "GTMSenTestCase.h"
#import <FTUtils/FTJSONParser.h>
#import <FTUtils/FTJSONWriter.h>

@interface TestFTJSONParser : GTMTestCase {
  NSDictionary *testData;
}
@end

@interface TestFTJSONWriter : GTMTestCase {}
@end

@implementation TestFTJSONParser

- (id) init {
  self = [super init];
  if (self != nil) {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"FTJSONTestData" ofType:@"plist"];
    testData = [[NSDictionary dictionaryWithContentsOfFile:plistPath] retain];
  }
  return self;
}

- (void) dealloc {
  [testData release], testData = nil;
  [super dealloc];
}

- (void)assertParseJSONData:(NSDictionary *)dataDict rootIsDictionary:(BOOL)isDictionary {
  FTJSONParser *parser = [[[FTJSONParser alloc] init] autorelease];
  [parser parseString:[dataDict objectForKey:@"json"] error:NULL];
  STAssertEquals(kFTJSONParsingStatusOK, parser.status, nil);
  if(isDictionary) {
    STAssertTrue([parser isDictionary], nil);
    STAssertEqualObjects([dataDict objectForKey:@"json_object"], [parser dictionary], nil);
    STAssertEqualObjects([parser dictionary], [[parser array] objectAtIndex:0], nil);
  } else {
    STAssertFalse([parser isDictionary], nil);
    STAssertEqualObjects([dataDict objectForKey:@"json_object"], [parser array], nil);
    STAssertNil([parser dictionary], nil);
  }
  FTLOG(@"%@", [parser statusString]);
}

- (void)testParseBasicJSONDict {
  [self assertParseJSONData:[testData objectForKey:@"testParseBasicJSONDict"] rootIsDictionary:YES];
}

- (void)testParseBasicJSONArray {
  [self assertParseJSONData:[testData objectForKey:@"testParseBasicJSONArray"] rootIsDictionary:NO];
}

- (void)testParseMixedJSONObjectWithDictRoot {
  [self assertParseJSONData:[testData objectForKey:@"testParseMixedJSONObjectWithDictRoot"] rootIsDictionary:YES];
}

- (void)testParseMixedJSONObjectWithArrayRoot {
  [self assertParseJSONData:[testData objectForKey:@"testParseMixedJSONObjectWithArrayRoot"] rootIsDictionary:NO];
}

- (void)testParseBadJSONData {
  FTJSONParser *parser = [[[FTJSONParser alloc] init] autorelease];
  NSError *error;
  STAssertEquals(kFTJSONParsingStatusError, [parser parseString:@"{1:THISISABAD,json string]}" error:&error], nil);
  STAssertEqualStrings(@"parse error: invalid object key (must be a string)", [error localizedFailureReason], nil);
  STAssertEquals(FTJSONParserErrorDomain, [error domain], nil);
}

@end

@implementation TestFTJSONWriter

- (void)testFTJSONParserEncodeSimpleDictionaryToString {
  FTJSONWriter *writer = [[FTJSONWriter alloc] init];
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"One", @"1", @"Two", @"2", nil];
  NSString *expectedResult = @"{\"1\":\"One\",\"2\":\"Two\"}";
  
  [writer prepareWriter];
  FTJSONEncodingStatus status = [writer encodeDictionary:dict error:nil];
  STAssertEquals(status, kFTJSONEncStatusOK, nil);
  STAssertEqualStrings([writer encodedString], expectedResult, nil);
}

- (void)testFTJSONParserEncodeComplexDictionaryToString {
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:1], @"One",
                        [NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithFloat:.3], @"Four", nil], @"An Array",
                        [NSNumber numberWithBool:NO], @"NO",
                        @"That's right, a string!", @"Just a String",
                       nil];
  NSDictionary *expected = @"{\"One\":1,\"An Array\":[2,0.3,\"Four\"],\"NO\":false,\"Just a String\":\"That's right, a string!\"}";
  
  NSError *error;
  FTJSONWriter *writer = [[FTJSONWriter alloc] init];
  [writer prepareWriter];
  FTJSONEncodingStatus status = [writer encodeDictionary:dict error:&error];
  STAssertEquals(status, kFTJSONEncStatusOK, [error localizedFailureReason]);
  STAssertEqualStrings([writer encodedString], expected, nil);
  
  [writer prepareWriter];
  status = [writer encodeObject:dict error:&error];
  STAssertEquals(status, kFTJSONEncStatusOK, [error localizedFailureReason]);
  STAssertEqualStrings([writer encodedString], expected, nil);
}

- (void)testFTJSONParserEncodeSimpleArrayToString {
  FTJSONWriter *writer = [[FTJSONWriter alloc] init];
  NSArray *array = [NSArray arrayWithObjects:@"One", @"Two", @"Three", nil];
  NSString *expectedResult = @"[\"One\",\"Two\",\"Three\"]";
  
  [writer prepareWriter];
  FTJSONEncodingStatus status = [writer encodeArray:array error:nil];
  STAssertEquals(status, kFTJSONEncStatusOK, nil);
  STAssertEqualStrings([writer encodedString], expectedResult, nil);
}

@end
