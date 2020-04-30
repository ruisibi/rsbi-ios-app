//
//  AddDataPushViewController.h
//  Pivot
//
//  Created by djh on 16/5/12.
//  Copyright © 2016年 bos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddDataPushViewController : UIViewController
@property (nonatomic,strong) NSDictionary *historyDict;//历史
/***********************************************************************
 * 方法名称： reloadViewByStore:(NSDictionary *)aDict
 * 功能描述： 从保存的配置进入
 * 输入参数：
 * 输出参数：
 * 返 回 值：
 ***********************************************************************/
-(void)reloadViewByStore:(NSDictionary *)aDict;
@end
