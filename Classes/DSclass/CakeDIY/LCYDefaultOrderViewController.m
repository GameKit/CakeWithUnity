//
//  LCYDefaultOrderViewController.m
//  CakeDIY
//
//  Created by eagle on 14-3-28.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import "LCYDefaultOrderViewController.h"

@interface LCYDefaultOrderViewController ()
<UITextFieldDelegate>
/**
 *  所有标签，用于设置字体
 */
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *allLabels;
/**
 *  蛋糕名称
 */
@property (weak, nonatomic) IBOutlet UILabel *cakeNameLabel;
/**
 *  蛋糕尺寸
 */
@property (weak, nonatomic) IBOutlet UILabel *cakeSizeLabel;
/**
 *  蛋糕价格
 */
@property (weak, nonatomic) IBOutlet UILabel *cakePriceLabel;
/**
 *  所有输入框，用于设置字体和光标颜色等
 */
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
/**
 *  中间大框
 */
@property (weak, nonatomic) IBOutlet UIView *middleView;
/**
 *  预订人
 */
@property (weak, nonatomic) IBOutlet UITextField *orderName;
/**
 *  联系电话
 */
@property (weak, nonatomic) IBOutlet UITextField *orderPhone;
/**
 *  送货地址
 */
@property (weak, nonatomic) IBOutlet UITextField *orderAddress;
/**
 *  祝福语
 */
@property (weak, nonatomic) IBOutlet UITextField *orderBless;
/**
 *  选择餐具
 */
@property (weak, nonatomic) IBOutlet UITextField *orderTableWare;

@end

@implementation LCYDefaultOrderViewController

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
    
    // 设置字体
    for (UILabel *oneLabel in self.allLabels) {
        [oneLabel setFont:[UIFont fontWithName:@"GJJZQJW--GB1-0" size:20]];
    }
    
    // 载入蛋糕信息
    NSAssert(self.icyCake!=nil, @"生成订单时，加载蛋糕信息失败");
    self.cakeNameLabel.text = [NSString stringWithFormat:@"名称：%@",self.icyCake.name];
    NSDictionary *sizeDictionary = [self.icyCake.size objectAtIndex:self.icyCake.sizeIndex];
    self.cakeSizeLabel.text = [NSString stringWithFormat:@"尺寸：%@",[sizeDictionary objectForKey:@"number"]];
    self.cakePriceLabel.text = [NSString stringWithFormat:@"价格：%@ 元", self.icyCake.price];
    
    // 设置光标颜色
    for (UITextField *textField in self.textFields) {
        textField.tintColor = [UIColor whiteColor];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)backButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextField Delegate Methods
- (void)keyboardWillShow{
    CGRect tmpFrame = self.middleView.frame;
    tmpFrame.origin.y = (-50);
    [UIView animateWithDuration:0.3 animations:^{
        [self.middleView setFrame:tmpFrame];
    }];
}
- (void)keyboardWillHide{
    CGRect tmpFrame = self.middleView.frame;
    tmpFrame.origin.y = 120;
    [UIView animateWithDuration:0.3 animations:^{
        [self.middleView setFrame:tmpFrame];
    }];
}
- (IBAction)textFieldGoNext:(UITextField *)sender{
    if (sender == self.orderName) {
        [self.orderPhone becomeFirstResponder];
    }
    if (sender == self.orderPhone) {
        [self.orderAddress becomeFirstResponder];
    }
    if (sender == self.orderAddress) {
        [self.orderBless becomeFirstResponder];
    }
    if (sender == self.orderBless) {
        [self.orderTableWare becomeFirstResponder];
    }
    if (sender == self.orderTableWare) {
        [self.orderTableWare resignFirstResponder];
    }
}

@end
