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
#import <yajl/yajl_gen.h>

extern NSString *const FTJSONWriterErrorDomain;

typedef enum {
  kFTJSONTypeUnknown = 0,
  kFTJSONTypeDictionary,
  kFTJSONTypeArray,
  kFTJSONTypeInteger,
  kFTJSONTypeDouble,
  kFTJSONTypeString,
  kFTJSONTypeBOOL
} FTJSONType;

typedef enum {
  kFTJSONEncStatusOK = yajl_gen_status_ok,
  kFTJSONEncStatusKeysMustBeStrings = yajl_gen_keys_must_be_strings,
  kFTJSONEncStatusMaxDepthExceeded = yajl_max_depth_exceeded,
  kFTJSONEncStatusCalledInErrorState = yajl_gen_in_error_state,
  kFTJSONEncStatusGenerationComplete = yajl_gen_generation_complete,
  kFTJSONEncStatusCannotEncode
} FTJSONEncodingStatus;

@protocol FTJSONWriterDelegate

- (FTJSONType)typeOfValue:(id)value forKey:(NSString *)key;

@end


@interface FTJSONWriter : NSObject {
  yajl_gen handle_;
  NSMutableString *encodedString_;
  id delegate_;
  BOOL beautify_;
  NSString *indentString_;
}

@property(assign) id<FTJSONWriterDelegate> delegate;
@property(assign) BOOL beautify;
@property(nonatomic,retain) NSString *indentString;
@property(readonly) NSString *encodedString;

- (BOOL)prepareWriter;

- (FTJSONEncodingStatus)encodeObject:(id)obj error:(NSError **)error;
- (FTJSONEncodingStatus)encodeDictionary:(NSDictionary *)dictionary error:(NSError **)error;
- (FTJSONEncodingStatus)encodeArray:(NSArray *)array error:(NSError **)error;

@end
