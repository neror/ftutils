/*
 The MIT License
 
 Copyright (c) 2010 Free Time Studios and Nathan Eror
 
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FTAnnotationView : UIView {
  CAGradientLayer *gradient_;
  CALayer *bubble_;
  CAShapeLayer *arrow_;
  UIColor *bubbleColor_;
  UILabel *titleLabel_;
  UILabel *bodyLabel_;
  
  CGPoint anchorPosition_;
}

@property (assign) CGPoint anchorPosition;
@property (copy) NSString *titleText;
@property (copy) NSString *bodyText;
@property (assign) CGFloat bubbleCornerRadius;
@property (assign) CGFloat arrowWidth;
@property (readonly) CGFloat windowMargin;

- (void)showForRect:(CGRect)subjectRect inView:(UIView *)subjectContainerView animated:(BOOL)animated;
- (void)dismiss;
- (void)setBubbleColor:(UIColor *)newColor;

@end
