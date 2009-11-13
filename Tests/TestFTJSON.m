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
#import "FTJSONParser.h"
#import "FTJSONWriter.h"

@interface TestFTJSONParser : SenTestCase {
  NSDictionary *testData;
}
@end

@interface TestFTJSONWriter : SenTestCase {}
@end

@implementation TestFTJSONParser

- (void)setUp {
  NSString *plistPath = [[NSBundle bundleForClass:[TestFTJSONParser class]] pathForResource:@"FTJSONTestData" ofType:@"plist"];
  testData = [[NSDictionary dictionaryWithContentsOfFile:plistPath] retain];
  STAssertNotNil(testData, @"Couldn't load the JSON test data plist");
}

- (void)tearDown {
  FTRELEASE(testData);
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
//  STAssertTrue([[error localizedFailureReason] isEqualToString:@"parse error: invalid object key (must be a string)"], nil);
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
  STAssertTrue([[writer encodedString] isEqualToString:expectedResult], @"Simple dictionary encoded incorrectly");
}

- (void)testFTJSONParserEncodeComplexDictionaryToString {
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:1], @"One",
                        [NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithFloat:.3], @"Four", nil], @"An Array",
                        [NSNumber numberWithBool:NO], @"NO",
                        @"That's right, a string!", @"Just a String",
                       nil];
  NSString *expected = @"{\"One\":1,\"An Array\":[2,0.3,\"Four\"],\"NO\":false,\"Just a String\":\"That's right, a string!\"}";
  
  NSError *error;
  FTJSONWriter *writer = [[FTJSONWriter alloc] init];
  [writer prepareWriter];
  FTJSONEncodingStatus status = [writer encodeDictionary:dict error:&error];
  STAssertEquals(status, kFTJSONEncStatusOK, [error localizedFailureReason]);
  STAssertTrue([[writer encodedString] isEqualToString:expected], nil);
  
  [writer prepareWriter];
  status = [writer encodeObject:dict error:&error];
  STAssertEquals(status, kFTJSONEncStatusOK, [error localizedFailureReason]);
  STAssertTrue([[writer encodedString] isEqualToString:expected], nil);
}

- (void)testFTJSONParserEncodeSimpleArrayToString {
  FTJSONWriter *writer = [[FTJSONWriter alloc] init];
  NSArray *array = [NSArray arrayWithObjects:@"One", @"Two", @"Three", nil];
  NSString *expectedResult = @"[\"One\",\"Two\",\"Three\"]";
  
  [writer prepareWriter];
  FTJSONEncodingStatus status = [writer encodeArray:array error:nil];
  STAssertEquals(status, kFTJSONEncStatusOK, nil);
  STAssertTrue([[writer encodedString] isEqualToString:expectedResult], nil);
}

@end
