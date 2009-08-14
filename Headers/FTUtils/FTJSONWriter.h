#import <Foundation/Foundation.h>
#import <yajl/yajl_common.h>
#import <yajl/yajl_gen.h>
#import "FTMacros.h"

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
