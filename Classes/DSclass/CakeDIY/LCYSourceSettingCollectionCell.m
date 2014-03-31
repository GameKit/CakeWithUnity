//
//  LCYSourceSettingCollectionCell.m
//  CakeDIY
//
//  Created by eagle on 14-3-26.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import "LCYSourceSettingCollectionCell.h"

@implementation LCYSourceSettingCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)tickOn{
    self.tickImage.image = [UIImage imageNamed:@"settingTick.png"];
}

- (void)tickOff{
    self.tickImage.image = nil;
}


@end
