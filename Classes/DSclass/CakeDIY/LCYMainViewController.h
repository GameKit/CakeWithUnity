//
//  LCYMainViewController.h
//  CakeDIY
//
//  Created by eagle on 14-3-25.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCYMainViewController : UIViewController
/**
 *  设置按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *slideSwitchButton;
- (IBAction)slideSwitchButtonPressed:(id)sender;
- (IBAction)slideSwitchButton2Pressed:(id)sender;

/**
 *  侧边菜单
 */
@property (strong, nonatomic) IBOutlet UIView *mainSlideView;

@property (weak, nonatomic) IBOutlet UIImageView *logo;


- (IBAction)diyButtonPressed:(id)sender;
- (IBAction)sourceSettingButtonPressed:(id)sender;
- (IBAction)chooseButtonPressed:(id)sender;

@end
