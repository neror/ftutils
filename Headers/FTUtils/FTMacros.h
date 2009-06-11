// FTLOGEXT logging macro from: http://iphoneincubator.com/blog/debugging/the-evolution-of-a-replacement-for-nslog
#ifdef DEBUG
  #define FTLOG(...) NSLog(__VA_ARGS__)
  #define FTLOGEXT(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
  #define FTLOG(...) /* */
  #define FTLOGEXT(...) /* */
#endif

#define FTRELEASE(_obj) [_obj release], _obj = nil

#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)
#define RADIANS_TO_DEGREES(r) (r * 180 / M_PI)
#define UIColorFromRGB(rgbValue) [UIColor \
                                   colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                   green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
                                   blue:((float)(rgbValue & 0x0000FF))/255.0 alpha:1.0]

#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor \
                                     colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                     green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
                                     blue:((float)(rgbValue & 0x0000FF))/255.0 \
                                     alpha:alphaValue]
