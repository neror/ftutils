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
