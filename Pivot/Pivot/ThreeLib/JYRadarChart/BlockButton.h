//
//  BlockButton.h
//  Pivot
//
//  Created by djh on 16/3/16.
//  Copyright © 2016年 bos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlockButton : UIButton
typedef void (^TouchButton)(BlockButton*);
@property(nonatomic,copy)TouchButton block;
@end
