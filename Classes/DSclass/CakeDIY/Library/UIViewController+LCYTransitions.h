//
//  UIViewController+LCYTransitions.h
//  CakeDIY
//
//  Created by eagle on 14-3-25.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (LCYTransitions)
/*! @brief 从特定方向弹出新窗口
 @param viewController 要弹出的窗口
 @param direction 弹出方向 kCATransitionFromRight kCATransitionFromLeft kCATransitionFromTop kCATransitionFromBottom
 */
- (void) presentViewController:(UIViewController *)viewController withPushDirection: (NSString *) direction;


/*! @brief 从特定方向解除窗口
 @param direction 解除方向 kCATransitionFromRight kCATransitionFromLeft kCATransitionFromTop kCATransitionFromBottom
 */
- (void) dismissViewControllerWithPushDirection:(NSString *) direction;

/*! @brief 从特定方向解除窗口
 @param direction 解除方向 kCATransitionFromRight kCATransitionFromLeft kCATransitionFromTop kCATransitionFromBottom
 @param completion 完成后调用
 */
- (void) presentViewController:(UIViewController *)viewController withPushDirection:(NSString *)direction withCompletion:(void (^)(void))completion;

/*! @brief 从特定方向解除窗口
 @param direction 解除方向 kCATransitionFromRight kCATransitionFromLeft kCATransitionFromTop kCATransitionFromBottom
 @param completion 完成后调用
 */
- (void) dismissViewControllerWithPushDirection:(NSString *) direction withCompletion:(void (^)(void))completion;
@end
