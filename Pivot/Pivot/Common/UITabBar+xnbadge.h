//
//  UITabBar+xnbadge.h
//  XncccBox
//
//  Created by djh on 16/5/17.
//  Copyright © 2016年 bos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (xnbadge)
- (void)showBadgeOnItemIndex:(int)index;   //显示小红点

- (void)hideBadgeOnItemIndex:(int)index; //隐藏小红点

@end
