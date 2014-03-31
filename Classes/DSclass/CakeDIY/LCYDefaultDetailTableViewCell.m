//
//  LCYDefaultDetailTableViewCell.m
//  CakeDIY
//
//  Created by eagle on 14-3-28.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import "LCYDefaultDetailTableViewCell.h"

@implementation LCYDefaultDetailTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.textLabel.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
