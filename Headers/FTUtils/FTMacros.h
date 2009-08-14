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
#pragma mark -
#pragma mark Macros
#pragma mark -

#pragma mark Logging
// FTLOGEXT logging macro from: http://iphoneincubator.com/blog/debugging/the-evolution-of-a-replacement-for-nslog
#ifdef DEBUG
  #define FTLOG(...) NSLog(__VA_ARGS__)
  #define FTLOGEXT(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
  #define FTLOG(...) /* */
  #define FTLOGEXT(...) /* */
#endif

#pragma mark Memory Management

#define FTRELEASE(_obj) [_obj release], _obj = nil
#define FTFREE(_ptr) if(_ptr != NULL) { free(_ptr); _ptr = NULL; }

#pragma mark Math

#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)
#define RADIANS_TO_DEGREES(r) (r * 180 / M_PI)

#pragma mark Color Def Macros

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/256.f green:g/256.f blue:b/256.f alpha:1.f]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/256.f green:g/256.f blue:b/256.f alpha:a]
#define UIColorFromRGB(rgbValue) [UIColor \
                                   colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                   green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
                                   blue:((float)(rgbValue & 0x0000FF))/255.0 alpha:1.0]

#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor \
                                     colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                     green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
                                     blue:((float)(rgbValue & 0x0000FF))/255.0 \
                                     alpha:alphaValue]

#pragma mark Delegates

#define FT_CALL_DELEGATE(_delegate, _selector) \
id _theDelegate = _delegate; \
if(_theDelegate != nil && [_theDelegate respondsToSelector:_selector]) { \
  [_theDelegate performSelector:_selector]; \
}

#define FT_CALL_DELEGATE_WITH_ARG(_delegate, _selector, _argument) \
id _theDelegate = _delegate; \
if(_theDelegate != nil && [_theDelegate respondsToSelector:_selector]) { \
  [_theDelegate performSelector:_selector withObject:_argument]; \
}

#define FT_CALL_DELEGATE_WITH_ARGS(_delegate, _selector, _arg1, _arg2) \
id _theDelegate = _delegate; \
if(_theDelegate != nil && [_theDelegate respondsToSelector:_selector]) { \
  [_theDelegate performSelector:_selector withObject:_arg1 withObject:_arg2]; \
}


#pragma mark -
#pragma mark Inline Functions
#pragma mark -

#pragma mark File System Helpers

static inline NSString *FTPathForFileInDocumentsDirectory(NSString *filename) {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
  return path;
}
