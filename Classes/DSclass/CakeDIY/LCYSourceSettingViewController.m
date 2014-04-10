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
#import "UnityAppController.h"
#import "DefaultCake.h"

//#define patternNumber 12
#define diyNumber 88
@interface LCYSourceSettingViewController ()
<UICollectionViewDelegate,UICollectionViewDataSource,UIAlertViewDelegate>
{
    BOOL LCYSourceSettingCollectionCellRegistered;
    BOOL LCYSettingDIYCellRegistered;
    NSInteger patternNumber;
    BOOL isSettingSaved;
}

/**
 *  蛋糕样式是否选中
 */
@property (strong, nonatomic) NSMutableArray * settingPatternStatus;
/**
 *  DIY素材是否选中
 */
@property (strong, nonatomic) NSMutableArray * diyStatus;


///**
// *  蛋糕样式--Deprecated;
// */
//@property (strong, nonatomic) NSMutableArray *cakeSource;

@property (strong, nonatomic) NSManagedObjectContext *context;

/**
 *  蛋糕样式数组-由CoreData加载
 */
@property (strong, nonatomic) NSArray *defaultCakeArray;

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
    isSettingSaved = YES;
    UnityAppController *ad = (UnityAppController *)[UIApplication sharedApplication].delegate;
    self.context = ad.managedObjectContext;
    
    // 加载蛋糕样式
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DefaultCake" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    self.defaultCakeArray = [NSArray arrayWithArray:fetchedObjects];
    patternNumber = [self.defaultCakeArray count];
    
    //    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DefaultCake" ofType:@"plist"];
    //    self.cakeSource = [NSMutableArray arrayWithContentsOfFile:filePath];
    //    patternNumber = [self.cakeSource count];
    
    
    
    self.settingPatternStatus = [[NSMutableArray alloc] init];
    for (int i=0 ; i<patternNumber; i++) {
        //        [self.settingPatternStatus addObject:[[self.cakeSource objectAtIndex:i] objectForKey:@"selected"]];
        DefaultCake *cake = [self.defaultCakeArray objectAtIndex:i];
        [self.settingPatternStatus addObject:cake.selected];
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
    if (isSettingSaved) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"您有未保存的设置，是否需要保存"
                                                       delegate:self
                                              cancelButtonTitle:@"是"
                                              otherButtonTitles:@"否", nil];
        [alert show];
    }
    
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
        for (int i=0; i<[self.defaultCakeArray count]; i++) {
            DefaultCake *cake = [self.defaultCakeArray objectAtIndex:i];
            cake.selected = [self.settingPatternStatus objectAtIndex:i];
        }
        NSError *error;
        [self.context save:&error];
        
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
    if (!isSettingSaved) {
        isSettingSaved = YES;
    }
    // 蛋糕样式开启状态
    if (self.cakePatternView.superview) {
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
    if (isSettingSaved) {
        isSettingSaved = NO;
    }
    if (collectionView == self.patternCollectionView) {
        BOOL isTicked = [[self.settingPatternStatus objectAtIndex:indexPath.row] boolValue];
        BOOL newIsTicked = !isTicked;
        [self.settingPatternStatus replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:newIsTicked]];
        //        DefaultCake *cake = [self.defaultCakeArray objectAtIndex:indexPath.row];
        //        cake.selected = [NSNumber numberWithBool:newIsTicked];
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            // 保存
            [self performSelector:@selector(confirmButtonPressed:) withObject:nil];
            [self performSelector:@selector(backButtonPressed:) withObject:nil];
            break;
        case 1:
            // 不保存
            isSettingSaved = YES;
            [self performSelector:@selector(backButtonPressed:) withObject:nil];
            break;
        default:
            break;
    }
}

@end
