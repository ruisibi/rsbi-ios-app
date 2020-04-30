//
//  BlockButton.m
//  Pivot
//
//  Created by djh on 16/3/16.
//  Copyright © 2016年 bos. All rights reserved.
//

#import "BlockButton.h"

@implementation BlockButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius  = frame.size.width/2;
        [self addTarget:self action:@selector(touchAction:) forControlEvents:UIControlEventTouchDown];
        
    }
    return self;
}

- (void)touchAction:(id)sender{
    _block(self);
}

@end
