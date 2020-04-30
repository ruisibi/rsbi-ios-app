//
//  HeadView.h
//  表格
//
//  Created by zzy on 14-5-5.
//  Copyright (c) 2014年 zzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"

@class HeadView;

@protocol HeadViewDelegate <NSObject>

-(void)headView:(HeadView *)headView point:(CGPoint)point;

@end

@interface HeadView : UIView
@property (nonatomic,strong) MarqueeLabel *numRoom;
@property (nonatomic,strong) NSString *detail;

@end
