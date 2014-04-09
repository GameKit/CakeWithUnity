//
//  LCYSourceSettingViewController.m
//  CakeDIY
//
//  Created by eagle on 14-3-25.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import "LCYSourceSettingViewController.h"
#import "UIViewController+LCYTransitions.h"
#import "LCYCommon.h"
#import "LCYSourceSettingCollectionCell.h"
#import "LCYSettingDIYCell.h"

//#define patternNumber 12
#define diyNumber 88
@interface LCYSourceSettingViewController ()
<UICollectionViewDelegate,UICollectionViewDataSource>
{
    BOOL LCYSourceSettingCollectionCellRegistered;
    BOOL LCYSettingDIYCellRegistered;
    NSInteger patternNumber;
}

/**
 *  蛋糕样式是否选中
 */
@property (strong, nonatomic) NSMutableArray * settingPatternStatus;
/**
 *  DIY素材是否选中
 */
@property (strong, nonatomic) NSMutableArray * diyStatus;
/**
 *  蛋糕样式
 */
@property (strong, nonatomic) NSMutableArray *cakeSource;

@end

@implementation LCYSourceSettingViewController

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
    LCYSourceSettingCollectionCellRegistered = NO;
    LCYSettingDIYCellRegistered = NO;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DefaultCake" ofType:@"plist"];
    self.cakeSource = [NSMutableArray arrayWithContentsOfFile:filePath];
    patternNumber = [self.cakeSource count];
    
    self.settingPatternStatus = [[NSMutableArray alloc] init];
    for (int i=0 ; i<patternNumber; i++) {
        [self.settingPatternStatus addObject:[[self.cakeSource objectAtIndex:i] objectForKey:@"selected"]];
    }
    self.diyStatus = [[NSMutableArray alloc] init];
    for (int i=0; i<diyNumber; i++) {
        [self.diyStatus addObject:[NSNumber numberWithBool:YES]];
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
/**
 *  返回主页
 *
 *  @param sender 按钮
 */
- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *  蛋糕样式
 *
 *  @param sender 按钮
 */
- (IBAction)cakePatternButtonPressed:(id)sender {
    
    if (self.diySourceView.superview) {
        [self performSelector:@selector(diySourceButtonPressed:) withObject:nil];
    }
    
    CGFloat duration_t = 0.5;
    
    self.patternButton.enabled = NO;
    self.diyButton.enabled = NO;
    
    CGRect frame = CGRectMake(100, 37, 721, 723);
    [self.cakePatternView setFrame:frame];
    if (!self.cakePatternView.superview) {
        self.cakePatternView.alpha = 0;
        [self.view addSubview:self.cakePatternView];
        [UIView animateWithDuration:duration_t animations:^{
            self.cakePatternView.alpha = 1;
            [self.confirmButton setHidden:NO];
        } completion:^(BOOL finished) {
            self.patternButton.enabled = YES;
            self.diyButton.enabled = YES;
        }];
    } else {
        [self.confirmButton setHidden:YES];
        [UIView animateWithDuration:duration_t
                         animations:^{
                             self.cakePatternView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [self.cakePatternView removeFromSuperview];
                             self.patternButton.enabled = YES;
                             self.diyButton.enabled = YES;
                         }];
    }
}
/**
 *  DIY素材
 *
 *  @param sender 按钮
 */
- (IBAction)diySourceButtonPressed:(id)sender {
    if (self.cakePatternView.superview) {
        [self performSelector:@selector(cakePatternButtonPressed:) withObject:nil];
    }
    
    
    
    CGFloat duration_t = 0.5;
    
    self.patternButton.enabled = NO;
    self.diyButton.enabled = NO;

    CGRect frame = CGRectMake(100, 37, 723, 729);
    [self.diySourceView setFrame:frame];
    if (!self.diySourceView.superview) {
        self.diySourceView.alpha = 0;
        [self.view addSubview:self.diySourceView];
        [UIView animateWithDuration:duration_t
                         animations:^{
                             self.diySourceView.alpha = 1;
                             [self.confirmButton setHidden:NO];
                         }
                         completion:^(BOOL finished) {
                             self.patternButton.enabled = YES;
                             self.diyButton.enabled = YES;
                         }];
    } else {
        [self.confirmButton setHidden:YES];
        [UIView animateWithDuration:duration_t
                         animations:^{
                             self.diySourceView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [self.diySourceView removeFromSuperview];
                             self.patternButton.enabled = YES;
                             self.diyButton.enabled = YES;
                         }];
    }
    
}

/**
 *  确定
 *
 *  @param sender 按钮
 */
- (IBAction)confirmButtonPressed:(id)sender {
    // 蛋糕样式开启状态
    if (self.cakePatternView.superview) {
        for (int i=0 ; i<patternNumber; i++) {
//            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self.cakeSource objectAtIndex:i]];
            NSMutableDictionary *dic = [self.cakeSource objectAtIndex:i];
            [dic setValue:[self.settingPatternStatus objectAtIndex:i] forKey:@"selected"];
        }
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DefaultCake" ofType:@"plist"];

        NSLog(@"self.cakeSource=%@",self.cakeSource);
        [self.cakeSource writeToFile:filePath atomically:YES];
        [self performSelector:@selector(cakePatternButtonPressed:) withObject:nil];
    }
    // DIY素材开启状态
    if (self.diySourceView.superview) {
        [self performSelector:@selector(diySourceButtonPressed:) withObject:nil];
    }
}



#pragma mark - UICollectionView DataSource And Delegate Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == self.patternCollectionView) {
        return patternNumber;
    } else if(collectionView == self.diyCollectionView){
        return diyNumber;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.patternCollectionView) {
        static NSString * sourceSettingIdentifier = @"LCYSourceSettingCollectionCellIdentifier";
        if (!LCYSourceSettingCollectionCellRegistered) {
            UINib *nib = [UINib nibWithNibName:@"LCYSourceSettingCollectionCell" bundle:nil];
            [collectionView registerNib:nib
             forCellWithReuseIdentifier:sourceSettingIdentifier];
            LCYSourceSettingCollectionCellRegistered = YES;
        }
        LCYSourceSettingCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:sourceSettingIdentifier
                                                                                         forIndexPath:indexPath];
        cell.icyImage.image = [UIImage imageNamed:@"cakeDemo.png"];
        
        BOOL isTicked = [[self.settingPatternStatus objectAtIndex:indexPath.row] boolValue];
        if (isTicked) {
            cell.tickImage.image = [UIImage imageNamed:@"settingTick.png"];
        } else {
            cell.tickImage.image = nil;
        }
        
        return cell;
        //        return cell;
    } else if(collectionView == self.diyCollectionView){
        static NSString * diySettingIdentifier = @"LCYSettingDIYCellIdentifier";
        if (!LCYSettingDIYCellRegistered) {
            UINib *nib = [UINib nibWithNibName:@"LCYSettingDIYCell" bundle:nil];
            [collectionView registerNib:nib
             forCellWithReuseIdentifier:diySettingIdentifier];
            LCYSettingDIYCellRegistered = YES;
        }
        LCYSettingDIYCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:diySettingIdentifier
                                                                            forIndexPath:indexPath];
        
        cell.icyImageView.image = [UIImage imageNamed:@"fruitDemo.png"];
        
        BOOL isTicked = [[self.diyStatus objectAtIndex:indexPath.row] boolValue];
        if (isTicked) {
            cell.tickImageView.image = [UIImage imageNamed:@"settingTick.png"];
        } else {
            cell.tickImageView.image = nil;
        }
        
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.patternCollectionView) {
        BOOL isTicked = [[self.settingPatternStatus objectAtIndex:indexPath.row] boolValue];
        BOOL newIsTicked = !isTicked;
        [self.settingPatternStatus replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:newIsTicked]];
        LCYSourceSettingCollectionCell *cell = (LCYSourceSettingCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (newIsTicked) {
            [cell tickOn];
        } else {
            [cell tickOff];
        }
    } else if(collectionView == self.diyCollectionView){
        BOOL isTicked = [[self.diyStatus objectAtIndex:indexPath.row] boolValue];
        BOOL newIsTicked = !isTicked;
        [self.diyStatus replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:newIsTicked]];
        LCYSettingDIYCell *cell = (LCYSettingDIYCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (newIsTicked) {
            [cell tickOn];
        } else {
            [cell tickOff];
        }
    }
}

@end
