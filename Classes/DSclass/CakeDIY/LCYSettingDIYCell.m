//
//  LCYSettingDIYCell.m
//  CakeDIY
//
//  Created by eagle on 14-3-26.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import "LCYSettingDIYCell.h"

@implementation LCYSettingDIYCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)tickOn{
    self.tickImageView.image = [UIImage imageNamed:@"settingTick.png"];
}

- (void)tickOff{
    self.tickImageView.image = nil;
}

@end
