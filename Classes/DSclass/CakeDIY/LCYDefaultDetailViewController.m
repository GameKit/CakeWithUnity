//
//  LCYDefaultDetailViewController.m
//  CakeDIY
//
//  Created by eagle on 14-3-26.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import "LCYDefaultDetailViewController.h"
#import "LCYDefaultDetailTableViewCell.h"
#import "LCYDefaultOrderViewController.h"

#import "DefaultToSize.h"
#import "CakeSize.h"

@interface LCYDefaultDetailViewController ()
<UITableViewDelegate, UITableViewDataSource>
{
    BOOL isNibRegistered;
    NSNumber *sizeID;
}

/**
 *  所有Label，用于修改字体
 */
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *detailHeaderLabels;

/**
 *  蛋糕名
 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
/**
 *  蛋糕价格
 */
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
/**
 *  配料
 */
@property (weak, nonatomic) IBOutlet UILabel *materialLabel;
/**
 *  详细介绍
 */
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
/**
 *  尺寸
 */
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
/**
 *  尺寸弹窗
 */
@property (strong, nonatomic) IBOutlet UIView *sizePopView;
/**
 *  尺寸数组
 */
@property (strong, nonatomic) NSArray *sizeArray;

@end

@implementation LCYDefaultDetailViewController

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
    
    isNibRegistered = NO;
    
    // 设置字体
    for (UILabel *label in self.detailHeaderLabels) {
        [label setFont:[UIFont fontWithName:@"GJJZQJW--GB1-0" size:20]];
    }
    [self.descriptionTextView setFont:[UIFont fontWithName:@"GJJZQJW--GB1-0" size:18]];
    
    
    // 载入蛋糕数据
    NSAssert(self.icyCake!=nil, @"载入蛋糕信息失败");
    self.nameLabel.text = self.icyCake.name;
    self.priceLabel.text = [NSString stringWithFormat:@"%@ 元",self.icyCake.price];
    self.materialLabel.text = self.icyCake.material;
    self.descriptionTextView.text = self.icyCake.description__;
    
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    for (DefaultToSize *sz in self.icyCake.sizes) {
        [tmpArray addObject:sz];
    }
    self.sizeArray = [NSArray arrayWithArray:[tmpArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        DefaultToSize *ob1 = obj1;
        DefaultToSize *ob2 = obj2;
        if (ob1.theSize.id__.integerValue < ob2.theSize.id__.integerValue) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }]];
    DefaultToSize *relation = [self.sizeArray firstObject];
    CakeSize *oneSize = relation.theSize;
    sizeID = oneSize.id__;
    self.sizeLabel.text = [NSString stringWithFormat:@"%@ %@",oneSize.size,oneSize.description__];

    
    // 弹窗样式
    [self.sizePopView.layer setCornerRadius:5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - Actions
- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)listButtonPressed:(id)sender {
    CGRect frame = CGRectMake(580, 364, self.sizePopView.frame.size.width, self.sizePopView.frame.size.height);
    [self.sizePopView setFrame:frame];
    if (!self.sizePopView.superview) {
        [self.view addSubview:self.sizePopView];
    } else {
        [self.sizePopView removeFromSuperview];
    }
}

- (IBAction)backgroundTouched:(id)sender {
    if (self.sizePopView.superview) {
        [self.sizePopView removeFromSuperview];
    }
}

- (IBAction)orderButtonPressed:(id)sender {
    LCYDefaultOrderViewController *orderVC = [[LCYDefaultOrderViewController alloc] init];
    orderVC.icyCake = self.icyCake;
    orderVC.sizeID = sizeID;
    [self.navigationController pushViewController:orderVC animated:YES];
}


#pragma mark - UITableView Data Source And Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSAssert(self.icyCake!=nil, @"生成表单时，无法载入蛋糕信息");
    return [self.icyCake.sizes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"defaultDetailIdentifier";
    if (!isNibRegistered) {
        UINib *nib = [UINib nibWithNibName:@"LCYDefaultDetailTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
        isNibRegistered = YES;
    }
    LCYDefaultDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSUInteger row = [indexPath row];
    DefaultToSize *size = [self.sizeArray objectAtIndex:row];
    cell.icyLabel.text = [NSString stringWithFormat:@"%@ %@",size.theSize.size,size.theSize.description__];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row = [indexPath row];
    DefaultToSize *size = [self.sizeArray objectAtIndex:row];
    self.sizeLabel.text = [NSString stringWithFormat:@"%@ %@",size.theSize.size,size.theSize.description__];
    if (self.sizePopView.superview) {
        [self.sizePopView removeFromSuperview];
    }
    sizeID = size.theSize.id__;
}

@end
