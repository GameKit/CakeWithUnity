//
//  LCYMainViewController.m
//  CakeDIY
//
//  Created by eagle on 14-3-25.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import "LCYMainViewController.h"
#import "LCYSourceSettingViewController.h"
#import "UIViewController+LCYTransitions.h"
#import "LCYCommon.h"
#import "LCYDefaultCakeViewController.h"
#import "UnityAppController.h"

@interface LCYMainViewController ()

@property (strong, nonatomic) UITapGestureRecognizer *backgroundTap;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation LCYMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.backgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.backgroundImageView addGestureRecognizer:self.backgroundTap];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.backgroundImageView removeGestureRecognizer:self.backgroundTap];
}

- (void)backgroundTapped:(id)sender{
    if (self.mainSlideView.superview) {
        [self performSelector:@selector(slideSwitchButton2Pressed:) withObject:nil];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (IBAction)slideSwitchButtonPressed:(id)sender {
    CGRect startFrame = CGRectMake(1024, 0, 202, 768);
    CGRect endFrame   = CGRectMake(1024-202, 0, 202, 768);
    [self.slideSwitchButton setHidden:YES];
    
    self.mainSlideView.frame = startFrame;
    [self.view addSubview:self.mainSlideView];
    [UIView animateWithDuration:0.3 animations:^{
        self.mainSlideView.frame = endFrame;
    }];
    
}

- (IBAction)slideSwitchButton2Pressed:(id)sender {
    CGRect startFrame = CGRectMake(1024, 0, 202, 768);
    [UIView animateWithDuration:0.3 animations:^{
        self.mainSlideView.frame = startFrame;
    } completion:^(BOOL finished) {
        [self.mainSlideView removeFromSuperview];
        [self.slideSwitchButton setHidden:NO];
    }];
}

- (IBAction)diyButtonPressed:(id)sender {
    UnityAppController * appController = (UnityAppController*)[UIApplication sharedApplication].delegate;
    [appController dsStartUnity];
}

- (IBAction)sourceSettingButtonPressed:(id)sender {
    LCYSourceSettingViewController *sourceSettingVC = [[LCYSourceSettingViewController alloc] init];
    [self.navigationController pushViewController:sourceSettingVC animated:YES];
}

- (IBAction)chooseButtonPressed:(id)sender {
    LCYDefaultCakeViewController *defaultVC = [[LCYDefaultCakeViewController alloc] init];
    [self.navigationController pushViewController:defaultVC animated:YES];
}
@end
