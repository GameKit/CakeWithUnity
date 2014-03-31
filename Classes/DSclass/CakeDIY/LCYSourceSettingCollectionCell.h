//
//  LCYSourceSettingCollectionCell.h
//  CakeDIY
//
//  Created by eagle on 14-3-26.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCYSourceSettingCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *icyImage;
@property (weak, nonatomic) IBOutlet UIImageView *tickImage;

- (void)tickOn;
- (void)tickOff;

@end
