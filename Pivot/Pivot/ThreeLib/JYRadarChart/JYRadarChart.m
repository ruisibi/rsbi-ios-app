//
//  JYRadarChart.m
//  JYRadarChart
//
//  Created by jy on 13-10-31.
//  Copyright (c) 2013年 wcode. All rights reserved.
//

#import "JYRadarChart.h"
#import "JYLegendView.h"
#import "Common.h"
#import "BlockButton.h"
#import "CPTPlotSymbol.h"
#import "CPTFill.h"
#import "CPTColor.h"

#define PADDING 30
#define LEGEND_PADDING 3
#define ATTRIBUTE_TEXT_SIZE 10
#define COLOR_HUE_STEP 5
#define MAX_NUM_OF_COLOR 17

@interface JYRadarChart ()

@property (nonatomic, assign) NSUInteger numOfV;
@property (nonatomic, strong) JYLegendView *legendView;
@property (nonatomic, strong) UIFont *scaleFont;
@property (nonatomic, strong) NSArray *symbols;
@property (nonatomic, strong) NSArray *defaultColors;

@end

@implementation JYRadarChart

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
        [self setDefaultValues];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaultValues];
    }
    return self;
}

- (void)setDefaultValues {
    self.backgroundColor = [UIColor whiteColor];
    _maxValue = 100.0;
    CPTPlotSymbol *aaplSymbol1 = [CPTPlotSymbol ellipsePlotSymbol];
    CPTPlotSymbol *aaplSymbol2 = [CPTPlotSymbol diamondPlotSymbol];
    CPTPlotSymbol *aaplSymbol3 = [CPTPlotSymbol rectanglePlotSymbol];
    CPTPlotSymbol *aaplSymbol4 = [CPTPlotSymbol trianglePlotSymbol];
    CPTPlotSymbol *aaplSymbol5 = [CPTPlotSymbol pentagonPlotSymbol];
    CPTPlotSymbol *aaplSymbol6 = [CPTPlotSymbol hexagonPlotSymbol];
    self.symbols = @[aaplSymbol1,aaplSymbol2,aaplSymbol3,aaplSymbol4,aaplSymbol5,aaplSymbol6];
    UIColor *aaplColor = [UIColor colorWithRed:69/255.0 green:114/255.0 blue:167/255.0 alpha:1];
    UIColor *aaplColor2 = [UIColor colorWithRed:170/255.0 green:70/255.0 blue:67/255.0 alpha:1];
    UIColor *aaplColor3 = [UIColor colorWithRed:137/255.0 green:165/255.0 blue:77/255.0 alpha:1];
    UIColor *aaplColor4 = [UIColor colorWithRed:128/255.0 green:105/255.0 blue:155/255.0 alpha:1];
    UIColor *aaplColor5 = [UIColor colorWithRed:61/255.0 green:150/255.0 blue:174/255.0 alpha:1];
    UIColor *aaplColor6 = [UIColor colorWithRed:219/255.0 green:132/255.0 blue:61/255.0 alpha:1];
    self.defaultColors = @[aaplColor,aaplColor2,aaplColor3,aaplColor4,aaplColor5,aaplColor6];
    
    _centerPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    _r = MIN(self.frame.size.width / 2 - PADDING, self.frame.size.height / 2 - PADDING);
    _steps = 1;
    _drawPoints = NO;
    _showLegend = NO;
    _showStepText = NO;
    _fillArea = NO;
    _minValue = 0;
    _colorOpacity = 1.0;
    _backgroundLineColorRadial = [UIColor lightGrayColor];
    _backgroundFillColor = [UIColor whiteColor];
    self.dataIndex = [[NSArray alloc]init];
    _legendView = [[JYLegendView alloc] init];
//    _legendView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    _legendView.backgroundColor = [UIColor clearColor];
    _legendView.colors = [NSMutableArray array];
    _attributes = @[@"you", @"should", @"set", @"these", @"data", @"titles,",
                        @"this", @"is", @"just", @"a", @"placeholder"];

    _scaleFont = [UIFont systemFontOfSize:ATTRIBUTE_TEXT_SIZE];
    
    _clockwise = YES;
}

- (void)setShowLegend:(BOOL)showLegend {
	_showLegend = showLegend;
	if (_showLegend) {
		[self addSubview:self.legendView];
	}
	else {
		for (UIView *subView in self.subviews) {
			if ([subView isKindOfClass:[JYLegendView class]]) {
				[subView removeFromSuperview];
			}
		}
	}
}

- (void)setTitles:(NSArray *)titles {
	self.legendView.titles = titles;
}

- (void)setColors:(NSArray *)colors {
    [self.legendView.colors removeAllObjects];
    for (UIColor *color in colors) {
        [self.legendView.colors addObject:[color colorWithAlphaComponent:self.colorOpacity]];
    }
}

- (void)setNeedsDisplay {
	[super setNeedsDisplay];
	[self.legendView sizeToFit];
	[self.legendView setNeedsDisplay];
}

- (void)setDataSeries:(NSArray *)dataSeries {
    if (dataSeries.count == 0) {
        _dataSeries = dataSeries;
        _numOfV     = 0;
        return;
    }
	_dataSeries = dataSeries;
	NSArray *arr = _dataSeries[0];
	_numOfV = [arr count];
	if (self.legendView.colors.count < _dataSeries.count) {
		for (int i = 0; i < _dataSeries.count; i++) {
			UIColor *color = [UIColor colorWithHue:1.0 * (i * COLOR_HUE_STEP % MAX_NUM_OF_COLOR) / MAX_NUM_OF_COLOR
			                            saturation:1
			                            brightness:1
			                                 alpha:self.colorOpacity];
			self.legendView.colors[i] = color;
		}
	}
}

- (void)layoutSubviews {
	[self.legendView sizeToFit];
	CGRect r = self.legendView.frame;
	r.origin.x = self.frame.size.width - self.legendView.frame.size.width - LEGEND_PADDING;
	r.origin.y = LEGEND_PADDING;
	self.legendView.frame = r;
	[self bringSubviewToFront:self.legendView];
}

- (void)drawRect:(CGRect)rect {
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[BlockButton class]]) {
            [subView removeFromSuperview];
        }
    }
	NSArray *colors = [self.defaultColors copy];
	CGFloat radPerV = M_PI * 2 / _numOfV;
    
    if (_clockwise) {
        radPerV =  - (M_PI * 2 / _numOfV);
    }
    else
    {
        radPerV = (M_PI * 2 / _numOfV);
    }
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	//draw attribute text
	CGFloat height = [self.scaleFont lineHeight];
	CGFloat padding = 2.0;
	for (int i = 0; i < _numOfV; i++) {
		NSString *attributeName = _attributes[i];
		CGPoint pointOnEdge = CGPointMake(_centerPoint.x - _r * sin(i * radPerV), _centerPoint.y - _r * cos(i * radPerV));
        
		CGSize attributeTextSize = JY_TEXT_SIZE(attributeName, self.scaleFont);
		NSInteger width = attributeTextSize.width;
        
		CGFloat xOffset = pointOnEdge.x >= _centerPoint.x ? width / 2.0 + padding : -width / 2.0 - padding;
		CGFloat yOffset = pointOnEdge.y >= _centerPoint.y ? height / 2.0 + padding : -height / 2.0 - padding;
		CGPoint legendCenter = CGPointMake(pointOnEdge.x + xOffset, pointOnEdge.y + yOffset);

        if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 70000) {
            NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
            [paragraphStyle setAlignment:NSTextAlignmentCenter];

            NSDictionary *attributes = @{ NSFontAttributeName: self.scaleFont,
                                          NSParagraphStyleAttributeName: paragraphStyle };

            [attributeName drawInRect:CGRectMake(legendCenter.x - width / 2.0,
                                                 legendCenter.y - height / 2.0,
                                                 width,
                                                 height)
                       withAttributes:attributes];
        }
        else {
            [attributeName drawInRect:CGRectMake(legendCenter.x - width / 2.0,
                                                 legendCenter.y - height / 2.0,
                                                 width,
                                                 height)
                             withFont:self.scaleFont
                        lineBreakMode:NSLineBreakByClipping
                            alignment:NSTextAlignmentCenter];
        }
    }

    //draw background fill color
    [_backgroundFillColor setFill];
    CGContextMoveToPoint(context, _centerPoint.x, _centerPoint.y - _r);
    for (int i = 1; i <= _numOfV; ++i) {
        CGContextAddLineToPoint(context, _centerPoint.x - _r * sin(i * radPerV),
                                _centerPoint.y - _r * cos(i * radPerV));
    }
    CGContextFillPath(context);

	//draw steps line
    //	static CGFloat dashedPattern[] = {3,3};
	//TODO: make this color a variable
	[[UIColor lightGrayColor] setStroke];
	CGContextSaveGState(context);
	for (int step = 1; step <= _steps; step++) {
		for (int i = 0; i <= _numOfV; ++i) {
			if (i == 0) {
				CGContextMoveToPoint(context, _centerPoint.x, _centerPoint.y - _r * step / _steps);
			}
			else {
//				                CGContextSetLineDash(context, 0, dashedPattern, 2);
				CGContextAddLineToPoint(context, _centerPoint.x - _r * sin(i * radPerV) * step / _steps,
				                        _centerPoint.y - _r * cos(i * radPerV) * step / _steps);
			}
		}
		CGContextStrokePath(context);
	}
	CGContextRestoreGState(context);
    
	//draw lines from center
	[_backgroundLineColorRadial setStroke];
	for (int i = 0; i < _numOfV; i++) {
		CGContextMoveToPoint(context, _centerPoint.x, _centerPoint.y);
		CGContextAddLineToPoint(context, _centerPoint.x - _r * sin(i * radPerV),
		                        _centerPoint.y - _r * cos(i * radPerV));
		CGContextStrokePath(context);
	}
	//end of base except axis label
    
    
	CGContextSetLineWidth(context, 2.0);
    
	//draw lines
    if (_numOfV > 0) {
        for (int serie = 0; serie < [_dataSeries count]; serie++) {
            if (self.fillArea) {
                [colors[serie] setFill];
            }
            else {
                UIColor *tmpColor ;
                if (serie >= 6) {
                  
                    tmpColor = [UIColor redColor];
                }else{
                    NSString *ttNum = _dataIndex[serie];
                    if (ttNum.intValue >= 6) {
                    
                        tmpColor = [UIColor redColor];
                    }else{
                    
                        tmpColor = colors[ttNum.intValue];
                    }
                    
                }
                [tmpColor setStroke];
            }
            for (int i = 0; i < _numOfV; ++i) {
                CGFloat value = [_dataSeries[serie][i] floatValue];
                if (i == 0) {
                    CGContextMoveToPoint(context, _centerPoint.x, _centerPoint.y - (value - _minValue) / (_maxValue - _minValue) * _r);
                }
                else {
                    CGContextAddLineToPoint(context, _centerPoint.x - (value - _minValue) / (_maxValue - _minValue) * _r * sin(i * radPerV),
                            _centerPoint.y - (value - _minValue) / (_maxValue - _minValue) * _r * cos(i * radPerV));
                }
            }
            CGFloat value = [_dataSeries[serie][0] floatValue];
            CGContextAddLineToPoint(context, _centerPoint.x, _centerPoint.y - (value - _minValue) / (_maxValue - _minValue) * _r);

            if (self.fillArea) {
                CGContextFillPath(context);
            }
            else {
                CGContextStrokePath(context);
            }


            //draw data points
            if (_drawPoints) {
                for (int i = 0; i < _numOfV; i++) {
                    CGFloat value = [_dataSeries[serie][i] floatValue];
                    CGFloat xVal = _centerPoint.x - (value - _minValue) / (_maxValue - _minValue) * _r * sin(i * radPerV);
                    CGFloat yVal = _centerPoint.y - (value - _minValue) / (_maxValue - _minValue) * _r * cos(i * radPerV);
                    
                    BlockButton *btn = [[BlockButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
                    btn.center = CGPointMake(xVal, yVal);
                    [btn setBlock:^(BlockButton *button){
                        if (self.delegate) {
                            [self.delegate radarViewDidSelectAt:serie index:i withPoint:CGPointMake(xVal, yVal)];
                        }
//                        NSLog(@"点击了%d线的%d,（%f,%f）",serie,i,xVal,yVal);
                    }];
                    [self addSubview:btn];
                    
                    [colors[serie] setFill];
                    
                    CPTPlotSymbol *sy ;
                    UIColor *tmpColor ;
                    if (serie >= 6) {
                        sy = self.symbols[1];
                        tmpColor = [UIColor redColor];
                    }else{
                        NSString *ttNum = _dataIndex[serie];
                        if (ttNum.intValue >= 6) {
                            sy = self.symbols[1];
                            tmpColor = [UIColor redColor];
                        }else{
                            sy = self.symbols[ttNum.intValue];
                            tmpColor = colors[ttNum.intValue];
                        }
                        
                    }
                    
                    sy.size = CGSizeMake(10, 10);
                    sy.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:tmpColor.CGColor]];
                    sy.lineStyle = nil;
                    [sy renderInContext:context atPoint:CGPointMake(xVal, yVal) scale:1 alignToPixels:NO];
//                    CGContextFillEllipseInRect(context, CGRectMake(xVal - 4, yVal - 4, 8, 8));
                 
//                    [self.backgroundColor setFill];
//                    CGContextFillEllipseInRect(context, CGRectMake(xVal - 2, yVal - 2, 4, 4));
                }
            }
        }
    }
    
	if (self.showStepText) {
        if (_dataSeries.count == 0) {
            return;
        }
		//draw step label text, alone y axis
		//TODO: make this color a variable
		[[UIColor blackColor] setFill];
		for (int step = 0; step <= _steps; step++) {
			CGFloat value = _minValue + (_maxValue - _minValue) * step / _steps;
            NSString *tmpLabel = [Common getStringByInt:value withMax:_maxValue];
//			NSString *currentLabel = [NSString stringWithFormat:@"%.0f", value];
			JY_DRAW_TEXT_IN_RECT(tmpLabel,
			                     CGRectMake(_centerPoint.x + 3,
			                                _centerPoint.y - _r * step / _steps - 3,
			                                80,
			                                10),
			                     self.scaleFont);
		}
	}
}

@end
