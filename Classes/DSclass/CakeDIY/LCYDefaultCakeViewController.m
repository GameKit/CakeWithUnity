//
//  LCYDefaultCakeViewController.m
//  CakeDIY
//
//  Created by eagle on 14-3-26.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import "LCYDefaultCakeViewController.h"
#import "LCYDefaultCakeCell.h"
#import "LCYDefaultCakeDataModel.h"
#import "LCYDefaultDetailViewController.h"
#import "UnityAppController.h"

@interface LCYDefaultCakeViewController ()
<UICollectionViewDelegate,UICollectionViewDataSource>
{
    BOOL isNibRegistered;
}

@property (strong, nonatomic) NSArray *defaultCakeArray;
@property (strong, nonatomic) NSArray *defaultCakeDataModelArray;

@end

@implementation LCYDefaultCakeViewController

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
    
    NSString *plistFilePath = [[NSBundle mainBundle] pathForResource:@"DefaultCake" ofType:@"plist"];
    self.defaultCakeArray = [NSArray arrayWithContentsOfFile:plistFilePath];
    NSAssert(self.defaultCakeArray!=nil, @"载入配置文件失败");
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    for (NSDictionary *oneDictionary in self.defaultCakeArray) {
        LCYDefaultCakeDataModel *oneCakeDataModel = [[LCYDefaultCakeDataModel alloc] init];
        oneCakeDataModel.id__ = [(NSNumber *)[oneDictionary objectForKey:@"id"] stringValue];
        oneCakeDataModel.name = [oneDictionary objectForKey:@"name"];
        oneCakeDataModel.image = [oneDictionary objectForKey:@"image"];
        oneCakeDataModel.price = [oneDictionary objectForKey:@"prise"];
        oneCakeDataModel.material = [oneDictionary objectForKey:@"material"];
        oneCakeDataModel.description__ = [oneDictionary objectForKey:@"description"];
        oneCakeDataModel.size = [NSArray arrayWithArray:[oneDictionary objectForKey:@"size"]];
        [tmpArray addObject:oneCakeDataModel];
    }
    self.defaultCakeDataModelArray = [NSArray arrayWithArray:tmpArray];
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
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)diyButtonPressed:(id)sender {
    UnityAppController * appController = (UnityAppController*)[UIApplication sharedApplication].delegate;
    [appController dsStartUnity];
}



#pragma mark - UICollectionView DataSource And Delegate Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.defaultCakeDataModelArray) {
        return [self.defaultCakeDataModelArray count];
    }
    return 88;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identifier = @"LCYDefaultCakeCellIdentifier";
    if (!isNibRegistered) {
        UINib *nib = [UINib nibWithNibName:@"LCYDefaultCakeCell" bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
        isNibRegistered = YES;
    }
    LCYDefaultCakeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                         forIndexPath:indexPath];
    cell.icyImageView.image = [UIImage imageNamed:@"defaultCakeDemo.png"];
    cell.nameLabel.font = [UIFont fontWithName:@"GJJZQJW--GB1-0" size:22];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LCYDefaultDetailViewController *detailVC = [[LCYDefaultDetailViewController alloc] init];
    detailVC.icyCake = [self.defaultCakeDataModelArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
}
@end
