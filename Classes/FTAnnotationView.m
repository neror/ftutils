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

#import <FTUtils/FTAnnotationView.h>
#import <FTUtils/FTAnimation.h>

#define WINDOW_MARGIN 20.f

@interface FTAnnotationView (Private)

- (void)setupView;
- (void)sizeLabelsToFitText;

@property (readonly) CALayer *bubbleLayer;
@property (readonly) CAShapeLayer *arrowLayer;
@property (readonly) CAGradientLayer *gradientLayer;
@property (readonly) UILabel *titleLabel;
@property (readonly) UILabel *bodyLabel;

@end

@implementation FTAnnotationView

@synthesize anchorPosition;
@synthesize titleText;
@synthesize bodyText;

#pragma mark -
#pragma mark Object creation

- (id)initWithFrame:(CGRect)theFrame {
  if ((self = [super initWithFrame:theFrame])) {
    [self setupView];
  }
  return self;
}

- (void)awakeFromNib {
  [self setupView];
}

- (void)dealloc {
  [self removeObserver:self forKeyPath:@"anchorPosition"];
  [self removeObserver:self forKeyPath:@"titleText"];
  [self removeObserver:self forKeyPath:@"bodyText"];
  self.titleText = nil;
  self.bodyText = nil;
  [gradient_ release], gradient_ = nil;
  [bubble_ release], bubble_ = nil;
  [arrow_ release], arrow_ = nil;
  [titleLabel_ release], titleLabel_ = nil;
  [bodyLabel_ release], bodyLabel_ = nil;
  [super dealloc];
}

- (void)setupView {
  self.opaque = NO;
  self.layer.backgroundColor = [[UIColor clearColor] CGColor];
  self.layer.anchorPoint = CGPointMake(.5f, 1.f);
  
  [self.layer addSublayer:self.bubbleLayer];
  
  [self.layer insertSublayer:self.arrowLayer above:self.bubbleLayer];
  
  [self.bubbleLayer addSublayer:self.gradientLayer];

  self.titleLabel.text = @"Title";
  [self addSubview:self.titleLabel];
  
  self.bodyLabel.text = @"The Body";
  [self addSubview:self.bodyLabel];
  
  [self addObserver:self forKeyPath:@"anchorPosition" options:NSKeyValueObservingOptionNew context:nil];
  [self addObserver:self forKeyPath:@"titleText" options:NSKeyValueObservingOptionNew context:nil];
  [self addObserver:self forKeyPath:@"bodyText" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark -
#pragma mark Lazy properties

- (CALayer *)bubbleLayer {
  if(!bubble_) {
    bubble_ = [[CALayer alloc] init];
    bubble_.cornerRadius = 6.f;
    bubble_.backgroundColor = [[UIColor blackColor] CGColor];
  }
  return bubble_;
}

- (CAShapeLayer *)arrowLayer {
  if(!arrow_)
  {
    arrow_ = [[CAShapeLayer alloc] init];
    
    CGRect arrowRect = CGRectMake(0.f, 0.f, 20.f, 10.f);
    arrow_.bounds = arrowRect;
    
    CGMutablePathRef arrowPath = CGPathCreateMutable();
    CGPathMoveToPoint(arrowPath, NULL, 0.f, 0.f);
    CGPathAddLineToPoint(arrowPath, NULL, arrowRect.size.width / 2.f, arrowRect.size.height);
    CGPathAddLineToPoint(arrowPath, NULL, arrowRect.size.width, 0.f);
    CGPathCloseSubpath(arrowPath);
    arrow_.path = arrowPath;
    CGPathRelease(arrowPath);
    arrow_.lineWidth = 0.f;
    arrow_.fillColor = [[UIColor blackColor] CGColor];
    arrow_.anchorPoint = CGPointMake(.5f, 1.f);
  }
  return arrow_;
}

- (CAGradientLayer *)gradientLayer {
  if(!gradient_) {
    gradient_ = [[CAGradientLayer alloc] init];
    gradient_.colors = [NSArray arrayWithObjects:
                        (id)[[[UIColor whiteColor] colorWithAlphaComponent:.15f] CGColor], 
                        (id)[[[UIColor whiteColor] colorWithAlphaComponent:0.f] CGColor],
                        nil];
    gradient_.locations = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:.35f], 
                           [NSNumber numberWithFloat:1.f], 
                           nil];
  }
  return gradient_;
}

- (UILabel *)titleLabel {
  if(!titleLabel_) {
    titleLabel_ = [[UILabel alloc] initWithFrame:self.bounds];
    titleLabel_.font = [UIFont fontWithName:@"Helvetica-Oblique" size:10.f];
    titleLabel_.textColor = [UIColor whiteColor];
    titleLabel_.backgroundColor = [UIColor clearColor];
    titleLabel_.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
                                   UIViewAutoresizingFlexibleBottomMargin;
    titleLabel_.textAlignment = UITextAlignmentCenter;
    titleLabel_.layer.anchorPoint = CGPointZero;
  }
  return titleLabel_;
}

- (UILabel *)bodyLabel {
  if(!bodyLabel_) {
    bodyLabel_ = [[UILabel alloc] initWithFrame:self.bounds];
    bodyLabel_.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.f];
    bodyLabel_.textColor = [UIColor whiteColor];
    bodyLabel_.backgroundColor = [UIColor clearColor];
    bodyLabel_.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
                                  UIViewAutoresizingFlexibleTopMargin;
    bodyLabel_.numberOfLines = 2;
    bodyLabel_.textAlignment = UITextAlignmentCenter;
    bodyLabel_.layer.anchorPoint = CGPointMake(0.f, 1.f);
  }
  return bodyLabel_;
}

#pragma mark Composite property methods

- (void)setBubbleColor:(UIColor *)newColor {
  [CATransaction begin];
  [CATransaction setDisableActions:YES];
  self.bubbleLayer.backgroundColor = [newColor CGColor];
  self.arrowLayer.fillColor = [newColor CGColor];
  [CATransaction commit];
}

#pragma mark -
#pragma mark KVO observering

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([keyPath isEqualToString:@"anchorPosition"]) {
    //TODO: Calculate the height and move the anchorPoint to the top if necessary
  	[self setNeedsLayout];
  } else if([keyPath isEqualToString:@"titleText"]) {
    self.titleLabel.text = self.titleText;
    [self setNeedsLayout];
  } else if([keyPath isEqualToString:@"bodyText"]) {
    self.bodyLabel.text = self.bodyText;
    [self setNeedsLayout];
  }
}

#pragma mark -
#pragma mark View display/drawing

- (void)sizeLabelsToFitText {
  NSArray *labels = [NSArray arrayWithObjects:self.titleLabel, self.bodyLabel, nil];
  
  CGSize maxSize = self.window.bounds.size;
  maxSize.width -= WINDOW_MARGIN * 2.f;
  maxSize.height -= WINDOW_MARGIN * 2.f;
  
  CGFloat longestWidth = 0.f;
  
  for (UILabel *label in labels) {
    [label sizeToFit];
    CGRect labelBounds = label.bounds;
    if(labelBounds.size.width > maxSize.width || labelBounds.size.height > maxSize.height) {
      labelBounds.size.width = fminf(labelBounds.size.width, maxSize.width);
      labelBounds.size.height = fminf(labelBounds.size.height, maxSize.height);
      label.bounds = labelBounds;
    }
    longestWidth = fmaxf(longestWidth, labelBounds.size.width);
  }
  
  [self.titleLabel.layer setValue:[NSNumber numberWithFloat:longestWidth] forKeyPath:@"bounds.size.width"];
  [self.bodyLabel.layer setValue:[NSNumber numberWithFloat:longestWidth] forKeyPath:@"bounds.size.width"];
}

- (void)adjustAnchorPoint {
  CGRect layerFrame = self.layer.frame;
  CGRect windowBounds = CGRectInset(self.window.bounds, WINDOW_MARGIN, WINDOW_MARGIN);
  if(layerFrame.origin.x < windowBounds.origin.x || CGRectGetMaxX(layerFrame) > CGRectGetMaxX(windowBounds)) {
    layerFrame.origin.x = windowBounds.origin.x;
    CGPoint anchorPoint = self.layer.anchorPoint;
    anchorPoint.x = self.anchorPosition.x / layerFrame.size.width;
    self.layer.anchorPoint = anchorPoint;
  }
}

- (void)layoutSubviews {
  [CATransaction begin];
  [CATransaction setDisableActions:YES];

  [self sizeLabelsToFitText];
  
  CGSize fullSize;
  fullSize.width = 8.f + fmaxf(self.titleLabel.bounds.size.width, self.bodyLabel.bounds.size.width);
  fullSize.height = 6.f + self.titleLabel.bounds.size.height + self.bodyLabel.bounds.size.height + self.arrowLayer.bounds.size.height;
    
  CGRect layerBounds = self.layer.bounds;
  layerBounds.size = fullSize;
  self.layer.bounds = layerBounds;
  self.layer.position = self.anchorPosition;
  
  [self adjustAnchorPoint];
  
  CGRect bubbleFrame = self.layer.bounds;
  bubbleFrame.size.height -= (self.arrowLayer.bounds.size.height - 1.f);
  self.bubbleLayer.frame = bubbleFrame;
  
  self.arrowLayer.position = CGPointMake(self.layer.bounds.size.width * self.layer.anchorPoint.x, 
                                         self.layer.bounds.size.height * self.layer.anchorPoint.y);
  
  self.gradientLayer.frame = CGRectInset(self.bubbleLayer.bounds, 1.f, 1.f);
  self.gradientLayer.cornerRadius = self.bubbleLayer.cornerRadius;
  
  CGRect textFrame = CGRectInset(self.bubbleLayer.frame, 4.f, 3.f);
  self.titleLabel.layer.position = textFrame.origin;
  self.bodyLabel.layer.position = CGPointMake(textFrame.origin.x, textFrame.size.height);

  [CATransaction commit];
}

- (void)showForRect:(CGRect)subjectRect inView:(UIView *)subjectContainerView animated:(BOOL)animated {
  self.anchorPosition = CGPointMake(CGRectGetMidX(subjectRect), CGRectGetMinY(subjectRect));
  [subjectContainerView addSubview:self];
  
  if(animated) {
    [self popIn:.33f delegate:nil];
  }
}

- (void)dismiss {
  [self removeFromSuperview];
}

@end
