//
//  PushSettingViewController.h
//  Pivot
//
//  Created by zzZ on 16/5/15.
//  Copyright © 2016年 bos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PushSettingViewController : UIViewController

@property (nonatomic,strong) NSString *tid;
@property (nonatomic,strong) NSDictionary *historyDict;//历史
@property (nonatomic) NSInteger  pushType;//0 每天 1每月
@end
