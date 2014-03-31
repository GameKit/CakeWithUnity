//
//  LCYSettingDIYCell.h
//  CakeDIY
//
//  Created by eagle on 14-3-26.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCYSettingDIYCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *tickImageView;
@property (weak, nonatomic) IBOutlet UIImageView *icyImageView;
- (void)tickOn;
- (void)tickOff;

@end
