//
//  HeadView.m
//  表格
//
//  Created by zzy on 14-5-5.
//  Copyright (c) 2014年 zzy. All rights reserved.
//
#import "HeadView.h"
#import "Common.h"


@interface HeadView()

@property (nonatomic,strong) UILabel *detailRoom;
@end

@implementation HeadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.numRoom=[[MarqueeLabel alloc]initWithFrame:CGRectMake(2, 0, self.frame.size.width-4, self.frame.size.height) duration:2.0 andFadeLength:10.0f];
        self.numRoom.textAlignment=NSTextAlignmentCenter;
        self.numRoom.font = MT_FONT;
        self.numRoom.adjustsFontSizeToFitWidth = true;
        self.numRoom.marqueeType = MLLeftRight;
        self.numRoom.tapToScroll = YES;
        
        self.numRoom.animationDelay = 0.0f;
        self.numRoom.minimumScaleFactor = 9;
        self.numRoom.center=CGPointMake(self.frame.size.width*0.5, self.frame.size.height*0.5);
        [self addSubview:self.numRoom];
        self.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
        UIView  *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height - 1 ,frame.size.width, MT_LINE_WIDTH)];
        lineView.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1];
        UIView  *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width-1, 0,MT_LINE_WIDTH, self.frame.size.height)];
        lineView2.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1];
        
        [self addSubview:lineView2];
        [self addSubview:lineView];
        
    }
    return self;
}


-(void)setDetail:(NSString *)detail
{
    _detail=detail;
    self.numRoom.text=detail;
    CGSize rect = [self sizeWithString:detail];
    if (rect.width < self.frame.size.width*2-8) {
        self.numRoom.scrollDuration = 1.0;
    }else{
        self.numRoom.scrollDuration = rect.width/(self.frame.size.width-4);
    }
}

/***********************************************************************
 * 方法名称： - (CGSize)sizeWithString:(NSString *)string
 * 功能描述： 定义成方法方便多个label调用 增加代码的复用性
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (CGSize)sizeWithString:(NSString *)string
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(10000, self.frame.size.height)//限制最大的宽度和高度
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin//采用换行模式
                                    attributes:@{NSFontAttributeName: MT_FONT}//传人的字体字典
                                       context:nil];
    
    return rect.size;
}

@end
