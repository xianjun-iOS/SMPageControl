//
//  SMPageControl.m
//  SMPageControl
//
//  Created by Jerry Jones on 10/13/12.
//  Copyright (c) 2012 Spaceman Labs. All rights reserved.
//

#import "SMPageControl.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


#define DEFAULT_INDICATOR_WIDTH 6.0f
#define DEFAULT_INDICATOR_MARGIN 10.0f

@interface SMPageControl ()
@end

@implementation SMPageControl
{
@private
    NSInteger       _displayedPage;
	CGFloat			_measuredIndicatorWidth;
	CGFloat			_measuredIndicatorHeight;
}

- (void)_initialize
{
	_measuredIndicatorWidth = DEFAULT_INDICATOR_WIDTH;
	_measuredIndicatorHeight = DEFAULT_INDICATOR_WIDTH;
	_indicatorWidth = DEFAULT_INDICATOR_WIDTH;
	_indicatorMargin = DEFAULT_INDICATOR_MARGIN;
	_alignment = SMPageControlAlignmentCenter;
	_verticalAlignment = SMPageControlVerticalAlignmentMiddle;
	
	_numberOfPages = 10;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (nil == self) {
		return nil;
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self _initialize];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIColor redColor] set];
	CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
	[self _renderPages:context rect:rect];
}

- (void)_renderPages:(CGContextRef)context rect:(CGRect)rect
{
	if (_numberOfPages < 2 && _hidesForSinglePage) {
		return;
	}
	
	CGSize size = [self sizeForNumberOfPages:self.numberOfPages];
	CGFloat left = [self _leftOffset];
	CGContextFillRect(context, CGRectMake(left, 0, size.width, size.height));
		
	CGFloat xOffset = left;
	CGFloat yOffset = [self _topOffset];
	UIColor *fillColor = nil;
	for (NSUInteger i = 0; i < _numberOfPages; i++) {
		
		if (i == _displayedPage) {
			fillColor = _currentPageIndicatorTintColor ? _currentPageIndicatorTintColor : [UIColor whiteColor];
		} else {
			fillColor = _pageIndicatorTintColor ? _pageIndicatorTintColor : [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
		}
		[fillColor set];

		
		
		CGContextFillEllipseInRect(context, CGRectMake(xOffset, yOffset, _measuredIndicatorWidth, _measuredIndicatorHeight));
		xOffset += _measuredIndicatorWidth + _indicatorMargin;
	}
	
//	[[UIColor greenColor] set];
//	CGContextFillRect(context, CGRectMake(left, 0.0f, [self sizeForNumberOfPages:_numberOfPages].width, 10.0f));
}

- (CGFloat)_leftOffset
{
	CGRect rect = self.bounds;
	CGSize size = [self sizeForNumberOfPages:self.numberOfPages];
	CGFloat left = 0.0f;
	switch (_alignment) {
		case SMPageControlAlignmentCenter:
			left = CGRectGetMidX(rect) - (size.width / 2.0f);
			break;
		case SMPageControlAlignmentRight:
			left = CGRectGetMaxX(rect) - size.width;
			break;
		default:
			break;
	}
	
	return left;
}

- (CGFloat)_topOffset
{
	CGRect rect = self.bounds;
	CGSize size = [self sizeForNumberOfPages:self.numberOfPages];
	CGFloat top = 0.0f;
	switch (_verticalAlignment) {
		case SMPageControlVerticalAlignmentMiddle:
			top = CGRectGetMidY(rect) - (_measuredIndicatorHeight / 2.0f);
			break;
		case SMPageControlVerticalAlignmentBottom:
			top = CGRectGetMaxY(rect) - size.height;
			break;
		default:
			break;
	}

	return top;
}

- (void)updateCurrentPageDisplay
{
	_displayedPage = _currentPage;
	[self setNeedsDisplay];
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
	CGFloat marginSpace = MAX(0, pageCount - 1) * _indicatorMargin;
	CGFloat indicatorSpace = pageCount * _measuredIndicatorWidth;
	return CGSizeMake(marginSpace + indicatorSpace, _measuredIndicatorHeight);
}

- (CGRect)rectForPage:(NSInteger)pageIndex
{
	if (pageIndex < 0 || pageIndex >= _numberOfPages) {
		return CGRectZero;
	}
	
	CGFloat left = [self _leftOffset];
	CGSize size = [self sizeForNumberOfPages:pageIndex + 1];
	CGRect rect = CGRectMake(left + size.width - _measuredIndicatorWidth, 0, _measuredIndicatorWidth, _measuredIndicatorWidth);
	return rect;
}

#pragma mark -

- (void)_updateMeasuredIndicatorSizes
{
	_measuredIndicatorWidth = _indicatorWidth;
	_measuredIndicatorHeight = _indicatorWidth;
	if (self.pageIndicatorImage) {
		CGSize imageSize = self.pageIndicatorImage.size;
		_measuredIndicatorWidth = MAX(_indicatorWidth, imageSize.width);
		_measuredIndicatorHeight = MAX(_indicatorWidth, imageSize.height);
	}
	
	if (self.currentPageIndicatorImage) {
		CGSize imageSize = self.currentPageIndicatorImage.size;
		_measuredIndicatorWidth = MAX(_indicatorWidth, imageSize.width);
		_measuredIndicatorHeight = MAX(_indicatorWidth, imageSize.height);
	}	
}


#pragma mark - Tap Gesture

// We're using touchesEnded: because we want to mimick UIPageControl as close as possible
// As of iOS 6, UIPageControl still does not use a tap gesture recognizer. This means that actions like
// touching down, sliding around, and releasing, still results in the page incrementing or decrementing.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	if (point.x < self.bounds.size.width / 2.0f) {
		self.currentPage -= 1;
	} else {
		self.currentPage += 1;
	}
}

#pragma mark - Accessors

- (void)setIndicatorWidth:(CGFloat)indicatorWidth
{
	if (indicatorWidth == _indicatorWidth) {
		return;
	}
	
	_indicatorWidth = indicatorWidth;
	[self setNeedsDisplay];
}

- (void)setIndicatorMargin:(CGFloat)indicatorMargin
{
	if (indicatorMargin == _indicatorMargin) {
		return;
	}
	
	_indicatorMargin = indicatorMargin;
	[self setNeedsDisplay];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
	if (numberOfPages == _numberOfPages) {
		return;
	}
	
	_numberOfPages = numberOfPages;
	[self setNeedsDisplay];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
	if (currentPage < 0 || currentPage >= _numberOfPages) {
		return;
	}
	
	_currentPage = currentPage;
	if (NO == self.defersCurrentPageDisplay) {
		_displayedPage = _currentPage;
		[self setNeedsDisplay];
	}
}

- (void)setCurrentPageIndicatorImage:(UIImage *)currentPageIndicatorImage
{
	if ([currentPageIndicatorImage isEqual:_currentPageIndicatorImage]) {
		return;
	}
	
	_currentPageIndicatorImage = currentPageIndicatorImage;
	[self _updateMeasuredIndicatorSizes];
	[self setNeedsDisplay];
}

- (void)setPageIndicatorImage:(UIImage *)pageIndicatorImage
{
	if ([pageIndicatorImage isEqual:_pageIndicatorImage]) {
		return;
	}
	
	_pageIndicatorImage = pageIndicatorImage;
	[self _updateMeasuredIndicatorSizes];
	[self setNeedsDisplay];
}

@end
