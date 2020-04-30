//
//  PushDateSetViewController.h
//  Pivot
//
//  Created by djh on 16/5/18.
//  Copyright © 2016年 bos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface PushDateSetViewController : UIViewController
@property (nonatomic) NSInteger  pushType;//0 每天 1每月
@property (nonatomic,strong) RSYDoneBlock block;
@property (nonatomic,strong) NSDictionary *defDict;
@end
