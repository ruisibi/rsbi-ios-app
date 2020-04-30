/*********************************************************************
 * 版权所有   magic_Zzz
 *
 * 文件名称： DetailTipView
 * 内容摘要： 弹出框
 * 其它说明： 实现文件
 * 作 成 者： ZGD
 * 完成日期： 2016年03月22日
 * 修改记录1：
 * 修改日期：
 * 修 改 人：
 * 修改内容：
 * 修改记录2：
 **********************************************************************/

#import "DetailTipView.h"
#define DTV_PADDING 5 //两边view间距
#define POPUP_ROOT_SIZE					CGSizeMake(20, 10)
#define ALPHA 1

@interface DetailTipView ()
{
    UILabel *lblName;
    UILabel *lblDetail;
    CGPoint currentPoint;
    CGFloat _sidePadding;
    CGFloat _pointerSize ;
    CGFloat _cornerRadius;
    CGFloat borderWidth;
    UIColor *borderColor;
}
@end
@implementation DetailTipView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.8;
//        self.layer.borderColor = [UIColor colorWithRed:69/255.0 green:114/255.0 blue:167/255.0 alpha:1].CGColor;
        borderColor = [UIColor colorWithRed:29/255.0 green:174/255.0 blue:241/255.0 alpha:1];
 
        
    }
    return self;
}

-(void)reloadDetailView:(NSString *)title detail:(NSString *)detail
{
    [lblName removeFromSuperview];
    [lblDetail removeFromSuperview];
    self.alpha = 0;
    CGFloat maxWidth = 0;
    CGSize labelsize1 = [self sizeWithString:title font:[UIFont boldSystemFontOfSize:12]];
    maxWidth = labelsize1.width;
    CGSize labelsize2 = [self sizeWithString:detail font:[UIFont systemFontOfSize:11]];
    if (labelsize2.width > maxWidth) {
        maxWidth = labelsize2.width;
    }
    self.frame = CGRectMake(0, 0, maxWidth+ DTV_PADDING*2, 50 + DTV_PADDING*2);
    lblName = [[UILabel alloc]initWithFrame:CGRectMake(DTV_PADDING, DTV_PADDING+POPUP_ROOT_SIZE.height, maxWidth, 25)];
    lblName.font = [UIFont boldSystemFontOfSize:12];
    lblName.text = title;
    lblName.textColor = [UIColor whiteColor];
    
    lblDetail = [[UILabel alloc]initWithFrame:CGRectMake(DTV_PADDING, POPUP_ROOT_SIZE.height + DTV_PADDING + 22, maxWidth, 20)];
    lblDetail.font = [UIFont systemFontOfSize:11];
    lblDetail.text = detail;
    lblDetail.textColor = [UIColor whiteColor];
    
    [self setNeedsDisplay];
    [self addSubview:lblName];
    [self addSubview:lblDetail];

}

/***********************************************************************
 * 方法名称： -(void)showTipView:(CGPoint)atPoint
 * 功能描述： 显示提示view
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
-(void)showTipView:(CGPoint)atPoint
{
    currentPoint = atPoint;
    const CGRect toFrame = (CGRect){CGPointMake(atPoint.x - self.frame.size.width/2, atPoint.y+5), self.frame.size.width, self.frame.size.height};
    self.frame = (CGRect){CGPointMake(atPoint.x - self.frame.size.width/2, atPoint.y+5), self.frame.size.width, 1};
    [UIView animateWithDuration:0.2
                     animations:^(void) {
                         
                         self.alpha = 1.0f;
                         self.frame = toFrame;
                         
                     } completion:^(BOOL completed) {
                         self.hidden = NO;
                     }];
    
}

/***********************************************************************
 * 方法名称：- (void)disMissMenu
 * 功能描述： 隐藏菜单
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (void)disMissMenu
{
    
    const CGRect toFrame = (CGRect){currentPoint, 1, 1};
    
    [UIView animateWithDuration:0.2
                     animations:^(void) {
                         
                         self.alpha = 0;
                         self.frame = toFrame;
                         
                     } completion:^(BOOL finished) {
                        self.hidden = YES;
                     }];
}

/***********************************************************************
 * 方法名称： - (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font
 * 功能描述： 定义成方法方便多个label调用 增加代码的复用性
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
- (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(300, 30)//限制最大的宽度和高度
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin//采用换行模式
                                    attributes:@{NSFontAttributeName: font}//传人的字体字典
                                       context:nil];
    
    return rect.size;
}

- (void)drawRect:(CGRect)rect
{
 
    [self drawBackground:self.bounds
               inContext:UIGraphicsGetCurrentContext()];
 
 
}

- (void)drawBackground:(CGRect)frame
             inContext:(CGContextRef) context
{
    CGFloat R0 = 0.267, G0 = 0.303, B0 = 0.335;
    CGFloat R1 = 37/255.0, G1 = 145/255.0, B1 = 241/255.0;
    
    UIColor *tintColor = borderColor;
//    tintColor = [UIColor whiteColor];
    if (tintColor) {
        
        CGFloat a;
        [tintColor getRed:&R0 green:&G0 blue:&B0 alpha:&a];
    }
    
    CGFloat X0 = frame.origin.x;
    CGFloat X1 = frame.origin.x + frame.size.width;
    CGFloat Y0 = frame.origin.y;
    CGFloat Y1 = frame.origin.y + frame.size.height;
    
    // render arrow
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    CGFloat kArrowSize = 12;
    CGFloat _arrowPosition = frame.size.width/2;
    // 画箭头
    const CGFloat kEmbedFix = 3.f;
    const CGFloat arrowXM = _arrowPosition;
    const CGFloat arrowX0 = arrowXM - kArrowSize;
    const CGFloat arrowX1 = arrowXM + kArrowSize;
        const CGFloat arrowY0 = Y0;
        const CGFloat arrowY1 = Y0 + kArrowSize + kEmbedFix;
        
        [arrowPath moveToPoint:    (CGPoint){arrowXM, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowXM, arrowY0}];
        
        [[UIColor colorWithRed:R0 green:G0 blue:B0 alpha:1] set];
        
        Y0 += kArrowSize;
   
    [arrowPath fill];
    
    // render body
    
    const CGRect bodyFrame = {X0, Y0, X1 - X0, Y1 - Y0};
    
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:bodyFrame
                                                          cornerRadius:8];
    
    const CGFloat locations[] = {0, 1};
    const CGFloat components[] = {
        R0, G0, B0, 1,
        R1, G1, B1, 1,
    };
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace,
                                                                 components,
                                                                 locations,
                                                                 sizeof(locations)/sizeof(locations[0]));
    CGColorSpaceRelease(colorSpace);
    
    
    [borderPath addClip];
    
    CGPoint start, end;
    
 
        
        start = (CGPoint){X0, Y0};
        end = (CGPoint){X0, Y1};
    
    CGContextDrawLinearGradient(context, gradient, start, end, 0);
    
    CGGradientRelease(gradient);
}




- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (![self pointInside:point withEvent:event]) {
//        [self disMissMenu];
    }
    ;

    
    return [super hitTest:point withEvent:event];
}

@end
