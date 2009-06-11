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

#import <FTUtils/FTJSONParser.h>

#define SAFE_RELEASE_HANDLE if(handle_ != NULL) { yajl_free(handle_), handle_ = NULL; }

NSString *const FTJSONParserErrorDomain = @"FTJSONParserError";

//Forward declaration, the struct is defined at the bottom of the file
static yajl_callbacks scjsonCallbacks;

@interface FTJSONParser (YAJLParserCallbacks)

- (BOOL)objectIsDictionary:(id)obj;

- (void)startCollectionWithKey:(NSString *)key collection:(id)collection;

- (void)startDictionaryWithKey:(NSString *)key;
- (void)endDictionary;

- (void)startArrayWithKey:(NSString *)key;
- (void)endArray;

- (void)addObject:(id)obj forKey:(NSString *)key;

@end

@implementation FTJSONParser (YAJLParserCallbacks)

- (BOOL)objectIsDictionary:(id)obj  {
  //NSDictionary is the only class that implements allKeys
  return [obj respondsToSelector:@selector(allKeys)];
}

- (void)addObject:(id)obj forKey:(NSString *)key {
  id stackTop = [collectionObjectStack_ lastObject];
  if([self objectIsDictionary:stackTop]) {
    [stackTop setObject:obj forKey:key];
  } else {
    [stackTop addObject:obj];
  }
}

- (void)startCollectionWithKey:(NSString *)key collection:(id)collection {
  id stackTop = [collectionObjectStack_ lastObject];
  if(stackTop == nil) {
    rootObject_ = [collection retain];
  } else {
    if([self objectIsDictionary:stackTop]) {
      [stackTop setObject:collection forKey:key];
    } else {
      [stackTop addObject:collection];
    }
  }
  [collectionObjectStack_ addObject:collection];
}

- (void)startDictionaryWithKey:(NSString *)key {
  if([collectionObjectStack_ count] == 0) {
    isDictionary_ = YES;
  }
  [self startCollectionWithKey:key collection:[NSMutableDictionary dictionary]];
}

- (void)endDictionary {
  NSAssert([self objectIsDictionary:[collectionObjectStack_ lastObject]], @"I need to pop a dictionary off of the type stack!");
  [collectionObjectStack_ removeLastObject];
}

- (void)startArrayWithKey:(NSString *)key {
  if([collectionObjectStack_ count] == 0) {
    isDictionary_ = NO;
  }
  [self startCollectionWithKey:key collection:[NSMutableArray array]];
}
- (void)endArray {
  NSAssert(![self objectIsDictionary:[collectionObjectStack_ lastObject]], @"I need to pop an array off of the type stack!");
  [collectionObjectStack_ removeLastObject];
}

@end


@implementation FTJSONParser

@synthesize delegate = delegate_;
@synthesize isDictionary = isDictionary_;
@synthesize allowComments = allowComments_;
@synthesize forceUTF8 = forceUTF8_;
@synthesize status = parsingStatus_;

#pragma mark init/dealloc

- (id) init {
  self = [super init];
  if (self != nil) {
    collectionObjectStack_ = [[NSMutableArray alloc] init];
    allowComments_ = YES;
    forceUTF8_ = YES;
  }
  return self;
}

- (void) dealloc {
  FTRELEASE(rootObject_);
  FTRELEASE(collectionObjectStack_);
  [super dealloc];
}

#pragma mark Result and Status Accessors

- (NSDictionary *)dictionary {
  if(isDictionary_) {
    return [NSDictionary dictionaryWithDictionary:rootObject_];
  }
  return nil;
}
- (NSArray *)array {
  if(isDictionary_) {
    return [NSArray arrayWithObject:rootObject_];
  }
  return [NSArray arrayWithArray:rootObject_];
}

- (NSString *)statusString {
  return [NSString stringWithCString:yajl_status_to_string((yajl_status)parsingStatus_)];
}

#pragma mark Error Handling Helpers

- (NSString *)getYAJLErrorStringFor:(NSData *)data {
  unsigned char *yajlError = yajl_get_error(handle_, 0, [data bytes], [data length]);
  //Put the error string into an NSString and lop off the trailing newline
  NSString *errorString = [NSString stringWithCString:(const char *)yajlError length:strlen((const char *)yajlError)-1];
  yajl_free_error(handle_, yajlError);
  return errorString;
}

#pragma mark Parse NSData Stream

- (BOOL)prepareParser {
  SAFE_RELEASE_HANDLE
  yajl_parser_config parserConfig = {allowComments_, forceUTF8_};
  handle_ = yajl_alloc(&scjsonCallbacks, &parserConfig, NULL, self);
  return (handle_ != NULL);
}

- (FTJSONParsingStatus)parseChunk:(NSData *)dataChunk error:(NSError **)error {
  parsingStatus_ = (FTJSONParsingStatus)yajl_parse(handle_, [dataChunk bytes], [dataChunk length]);
  if (parsingStatus_ != kFTJSONParsingStatusInsufficientData && parsingStatus_ != kFTJSONParsingStatusOK) {
    if(error != NULL) {
      *error = [NSError errorWithDomain:FTJSONParserErrorDomain 
                                   code:parsingStatus_ 
                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [self getYAJLErrorStringFor:dataChunk], NSLocalizedFailureReasonErrorKey, nil]];
    }
  }
  return parsingStatus_;
}

- (void)finishedParsing {
  parsingStatus_ = yajl_parse_complete(handle_);
  SAFE_RELEASE_HANDLE
}

#pragma mark Parse Stream From URL

- (BOOL)parseUrl:(NSURL *)url {
  return !![NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  [self prepareParser];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  NSError *error = nil;
  [self parseChunk:data error:&error];
  if (parsingStatus_ != kFTJSONParsingStatusInsufficientData && parsingStatus_ != kFTJSONParsingStatusOK) {
    [connection cancel];
    if (delegate_ != nil && [delegate_ respondsToSelector:@selector(jsonRequestFailed:)]) {
      [delegate_ jsonRequestFailed:error];
    }
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [self finishedParsing];
  if (delegate_ != nil && [delegate_ respondsToSelector:@selector(jsonRequestFailed:)]) {
    [delegate_ jsonRequestFailed:error];
  }
  
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  [self finishedParsing];
  if (delegate_ != nil && [delegate_ respondsToSelector:@selector(jsonRequestFinished:)]) {
    [delegate_ jsonRequestFinished:self];
  }
}

#pragma mark Parse a plain ole' NSString

- (FTJSONParsingStatus)parseString:(NSString *)jsonString error:(NSError **)error {
  NSData *data = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
  [self prepareParser];
  [self parseChunk:data error:error];
  [self finishedParsing];
  return parsingStatus_;
}

@end

#pragma mark -
#pragma mark YAJL Callbacks

static NSString *currentKey;

static int scjson_null(void *ctx) {
  [(FTJSONParser *)ctx addObject:nil forKey:currentKey];
  return 1;
}

static int scjson_boolean(void *ctx, int boolean) {
  [(FTJSONParser *)ctx addObject:[NSNumber numberWithBool:boolean] forKey:currentKey];
  return 1;
}

static int scjson_integer(void *ctx, long value) {
  [(FTJSONParser *)ctx addObject:[NSNumber numberWithLong:value] forKey:currentKey];
  return 1;
  
}

static int scjson_double(void *ctx, double value) {
  [(FTJSONParser *)ctx addObject:[NSNumber numberWithDouble:value] forKey:currentKey];
  return 1;
}

static int scjson_string(void *ctx, const unsigned char *stringVal, unsigned int stringLen) {
  NSString *value = [[NSString alloc] initWithBytes:stringVal length:stringLen encoding:NSUTF8StringEncoding];
  [(FTJSONParser *)ctx addObject:value forKey:currentKey];
  [value release];
  return 1;
}

static int scjson_map_key(void *ctx, const unsigned char *stringVal, unsigned int stringLen) {
  FTRELEASE(currentKey);
	currentKey = [[NSString alloc] initWithBytes:stringVal length:stringLen encoding:NSUTF8StringEncoding];
  return 1;
}

static int scjson_start_map(void *ctx) {
  [(FTJSONParser *)ctx startDictionaryWithKey:currentKey];
  return 1;
}

static int scjson_end_map(void *ctx) {
  [(FTJSONParser *)ctx endDictionary];
  return 1;
}

static int scjson_start_array(void *ctx) {
  [(FTJSONParser *)ctx startArrayWithKey:currentKey];
  return 1;
}

static int scjson_end_array(void *ctx) {
  [(FTJSONParser *)ctx endArray];
  return 1;
}

static yajl_callbacks scjsonCallbacks = {
  scjson_null,
  scjson_boolean,
  scjson_integer,
  scjson_double,
  NULL,
  scjson_string,
  scjson_start_map,
  scjson_map_key,
  scjson_end_map,
  scjson_start_array,
  scjson_end_array
};