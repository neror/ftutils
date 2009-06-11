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

#import <Foundation/Foundation.h>
#import <yajl/yajl_common.h>
#import <yajl/yajl_parse.h>

extern NSString *const FTJSONParserErrorDomain;

typedef enum {
  kFTJSONParsingStatusOK = yajl_status_ok,
  kFTJSONParsingStatusClientCanceled = yajl_status_client_canceled,
  kFTJSONParsingStatusInsufficientData = yajl_status_insufficient_data,
  kFTJSONParsingStatusError = yajl_status_error
} FTJSONParsingStatus;

@class FTJSONParser;

@protocol FTJSONParserDelegate

@optional

- (void)jsonRequestFinished:(FTJSONParser *)result;
- (void)jsonRequestFailed:(NSError *)error;

@end

@interface FTJSONParser : NSObject {
  NSMutableArray *collectionObjectStack_;
  id rootObject_;
  id delegate_;
  BOOL isDictionary_;
  yajl_handle handle_;
  FTJSONParsingStatus parsingStatus_;
  
  BOOL allowComments_;
  BOOL forceUTF8_;
}

@property(assign) id<FTJSONParserDelegate> delegate;
@property(readonly) BOOL isDictionary;
@property(readonly) FTJSONParsingStatus status;
@property(assign) BOOL allowComments;
@property(assign) BOOL forceUTF8;

- (FTJSONParsingStatus)parseString:(NSString *)jsonString error:(NSError **)error;
- (BOOL)parseUrl:(NSURL *)url;

- (NSDictionary *)dictionary;
- (NSArray *)array;

- (NSString *)statusString;

@end
