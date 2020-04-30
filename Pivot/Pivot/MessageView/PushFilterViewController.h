//
//  PushFilterViewController.h
//  Pivot
//
//  Created by zzZ on 16/5/17.
//  Copyright © 2016年 bos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface PushFilterViewController : UIViewController
@property (nonatomic,strong) NSString *duliang;
@property (nonatomic,strong) NSString *cunit;
@property (nonatomic,strong) NSDictionary *defDict;
@property (nonatomic,strong) RSYDoneBlock block;
@end
