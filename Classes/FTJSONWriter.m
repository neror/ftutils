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

#import <FTUtils/FTJSONWriter.h>

#define SAFE_RELEASE_HANDLE \
  if(handle_ != NULL) { \
    yajl_gen_free(handle_); \
    handle_ = NULL; \
  }

#define CHECK_STATUS_NO_ERROR(_status, _method_call) \
  _status = _method_call; \
  if(_status != kFTJSONEncStatusOK) { \
    return _status; \
  }

#define THROW_ERROR_FOR_STATUS(_status, _err) \
  if (_status != kFTJSONEncStatusOK) { \
    if(_err != NULL) { \
      *_err = [NSError errorWithDomain:FTJSONWriterErrorDomain \
                                  code:_status \
                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys: \
                                        [NSString stringWithUTF8String:friendlyErrorMessages[_status]], \
                                        NSLocalizedFailureReasonErrorKey, nil] \
              ]; \
    } \
    return _status; \
  }


#define GEN_FUNC_OR_ERROR(_err, _status, _func, ...) \
  _status = (FTJSONEncodingStatus)_func(__VA_ARGS__); \
  THROW_ERROR_FOR_STATUS(_status, _err)

static const char *friendlyErrorMessages[] = {
  "OK!",
  "All keys must be strings.",
  "Max stack depth exceeded.",
  "A generator function was called while the generator was in an error state.",
  "Generation complete.",
  "Could not encode into a JSON string"
};

NSString *const FTJSONWriterErrorDomain = @"FTJSONWriterError";

@interface FTJSONWriter (PrivateEncodingMethods)

- (FTJSONEncodingStatus)flushBuffer:(NSError **)error;
- (FTJSONType)guessType:(id)value;
- (FTJSONEncodingStatus)encodeString:(NSString *)value error:(NSError **)error;
- (FTJSONEncodingStatus)encodeNSValue:(NSNumber *)value forType:(FTJSONType)type error:(NSError **)error;
- (FTJSONEncodingStatus)encodeObject:(id)value forType:(FTJSONType)type error:(NSError **)error;
- (FTJSONEncodingStatus)encodeObject:(id)value forKey:(NSString *)key error:(NSError **)error;

@end

@implementation FTJSONWriter (PrivateEncodingMethods)

- (FTJSONEncodingStatus)flushBuffer:(NSError **)error {
  const unsigned char *buffer;
  unsigned int length;
  FTJSONEncodingStatus status;
  GEN_FUNC_OR_ERROR(error, status, yajl_gen_get_buf, handle_, &buffer, &length)
  [encodedString_ appendString:[NSString stringWithUTF8String:(const char *)buffer]];
  yajl_gen_clear(handle_);
  return status;
}

- (FTJSONType)guessType:(id)value {
  return kFTJSONTypeUnknown;
}

- (FTJSONEncodingStatus)encodeNSValue:(NSNumber *)value forType:(FTJSONType)type error:(NSError **)error {
  FTJSONEncodingStatus status = kFTJSONEncStatusCannotEncode;
  switch (type) {
    case kFTJSONTypeInteger:
      GEN_FUNC_OR_ERROR(error, status, yajl_gen_integer, handle_, [value longValue])
      break;
    case kFTJSONTypeDouble:
      GEN_FUNC_OR_ERROR(error, status, yajl_gen_double, handle_, [value doubleValue])
      break;
    case kFTJSONTypeBOOL:
      GEN_FUNC_OR_ERROR(error, status, yajl_gen_bool, handle_, [value boolValue])
      break;
  }
  return status;
}

- (FTJSONEncodingStatus)encodeString:(NSString *)value error:(NSError **)error {
  FTJSONEncodingStatus status;
  const char *str = [value UTF8String];
  GEN_FUNC_OR_ERROR(error, status, yajl_gen_string, handle_, (const unsigned char *)str, strlen(str))
  return status;
}

- (FTJSONEncodingStatus)encodeObject:(id)obj forType:(FTJSONType)type error:(NSError **)error {
  switch (type) {
    case kFTJSONTypeDictionary:
      return [self encodeDictionary:obj error:error];
    case kFTJSONTypeArray:
      return [self encodeArray:obj error:error];
    case kFTJSONTypeString:
      return [self encodeString:obj error:error];
    case kFTJSONTypeInteger:
    case kFTJSONTypeDouble:
    case kFTJSONTypeBOOL:
      return [self encodeNSValue:obj forType:type error:error];
  }
  THROW_ERROR_FOR_STATUS(kFTJSONEncStatusCannotEncode, error)
}

- (FTJSONEncodingStatus)encodeObject:(id)obj forKey:(NSString *)key error:(NSError **)error {
  FTJSONType type = kFTJSONTypeUnknown;
  
  if(delegate_ != nil && [delegate_ respondsToSelector:@selector(typeOfValue:forKey:)]) {
    type = [delegate_ typeOfValue:obj forKey:key];
  }
  
  if(type == kFTJSONTypeUnknown)
  {
    if([obj isKindOfClass:[NSValue class]])
    {
      const char *objCType = [obj objCType];
      if(strncmp(objCType, "i", 1)==0 || strncmp(objCType, "l", 1)==0 || strncmp(objCType, "q", 1)==0 || 
         strncmp(objCType, "I", 1)==0 || strncmp(objCType, "L", 1)==0 || strncmp(objCType, "Q", 1)==0)
      {
        type = kFTJSONTypeInteger;
      }
      else if(strncmp(objCType, "f", 1)==0 || strncmp(objCType, "d", 1)==0)
      {
        type = kFTJSONTypeDouble;
      }
      else if(strncmp(objCType, "B", 1)==0 || (strncmp(objCType, "c", 1)==0 && ([obj charValue]==0 || [obj charValue]==1))) {
        type = kFTJSONTypeBOOL;
      }
    }
    else if([obj respondsToSelector:@selector(initWithArray:)])
    {
      type = kFTJSONTypeArray;
    }
    else if([obj respondsToSelector:@selector(initWithDictionary:)] || 
            [obj respondsToSelector:@selector(addEntriesFromDictionary:)])
    {
      type = kFTJSONTypeDictionary;
    }
    else
    {
      //This is a fall through default and the NSString handler becuase
      //[NSString -descrption] just returns its receiver
      obj = [obj description];
      type = kFTJSONTypeString;
    }
  }
  return [self encodeObject:obj forType:type error:error];
}

@end

@implementation FTJSONWriter

@synthesize beautify = beautify_;
@synthesize indentString = indentString_;
@synthesize delegate = delegate_;
@dynamic encodedString;

- (id) init {
  self = [super init];
  if (self != nil) {
    beautify_ = NO;
    self.indentString = @"  ";
  }
  return self;
}

- (void) dealloc {
  SAFE_RELEASE_HANDLE
  FTRELEASE(encodedString_);
  FTRELEASE(indentString_);
  [super dealloc];
}

- (NSString *)encodedString {
  return [NSString stringWithString:encodedString_];
}

- (BOOL)prepareWriter {
  FTRELEASE(encodedString_);
  encodedString_ = [[NSMutableString alloc] init];
  SAFE_RELEASE_HANDLE
  yajl_gen_config yajlGeneratorConf = {beautify_, [indentString_ UTF8String]};
  handle_ = yajl_gen_alloc(&yajlGeneratorConf, NULL);
  return (handle_ != NULL);
}

- (FTJSONEncodingStatus)encodeDictionary:(NSDictionary *)dictionary error:(NSError **)error {
  NSAssert(handle_, @"The writer must be prepared before encoding can begin.");
  
  FTJSONEncodingStatus status;
  GEN_FUNC_OR_ERROR(error, status, yajl_gen_map_open, handle_)
  for(id key in dictionary) {
    //Force Dictionary keys to NSStrings. We can use description since
    //it just returns the receiver when called on NSString
    CHECK_STATUS_NO_ERROR(status, [self encodeObject:[key description] forKey:nil error:error])
    CHECK_STATUS_NO_ERROR(status, [self encodeObject:[dictionary objectForKey:key] forKey:key error:error])
  }
  GEN_FUNC_OR_ERROR(error, status, yajl_gen_map_close, handle_)
  return [self flushBuffer:error];
}

- (FTJSONEncodingStatus)encodeArray:(NSArray *)array error:(NSError **)error {
  NSAssert(handle_, @"The writer must be prepared before encoding can begin.");

  FTJSONEncodingStatus status;
  GEN_FUNC_OR_ERROR(error, status, yajl_gen_array_open, handle_)
  for(NSString *item in array) {
    [self encodeObject:item forKey:nil error:error];
  }
  GEN_FUNC_OR_ERROR(error, status, yajl_gen_array_close, handle_)
  return [self flushBuffer:error];
}

- (FTJSONEncodingStatus)encodeObject:(id)obj error:(NSError **)error {
  FTJSONEncodingStatus status;
  CHECK_STATUS_NO_ERROR(status, [self encodeObject:obj forKey:nil error:error])
  return [self flushBuffer:error];
}

@end