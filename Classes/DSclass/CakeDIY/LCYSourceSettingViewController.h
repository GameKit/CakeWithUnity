//
//  LCYSourceSettingViewController.h
//  CakeDIY
//
//  Created by eagle on 14-3-25.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCYSourceSettingViewController : UIViewController


@property (strong, nonatomic) IBOutlet UIView *cakePatternView;
@property (strong, nonatomic) IBOutlet UIView *diySourceView;

/**
 *  蛋糕样式
 */
@property (weak, nonatomic) IBOutlet UICollectionView *patternCollectionView;
/**
 *  DIY素材
 */
@property (weak, nonatomic) IBOutlet UICollectionView *diyCollectionView;


/**
 *  确定按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
/**
 *  蛋糕样式按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *patternButton;
/**
 *  DIY素材按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *diyButton;



@end
