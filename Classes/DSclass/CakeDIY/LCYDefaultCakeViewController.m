//
//  LCYDefaultCakeViewController.m
//  CakeDIY
//
//  Created by eagle on 14-3-26.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import "LCYDefaultCakeViewController.h"
#import "LCYDefaultCakeCell.h"
#import "LCYDefaultDetailViewController.h"
#import "UnityAppController.h"

#import "DefaultCake.h"

@interface LCYDefaultCakeViewController ()
<UICollectionViewDelegate,UICollectionViewDataSource>
{
    BOOL isNibRegistered;
}

@property (strong, nonatomic) NSArray *defaultCakeArray;

@property (strong, nonatomic) NSManagedObjectContext *context;

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
    
    UnityAppController *ad = (UnityAppController *)[UIApplication sharedApplication].delegate;
    self.context = ad.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DefaultCake" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selected == 1"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        abort();
    }
    self.defaultCakeArray = [NSArray arrayWithArray:fetchedObjects];
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
    if (self.defaultCakeArray) {
        return [self.defaultCakeArray count];
    }
    return 0;
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
    DefaultCake *cake = [self.defaultCakeArray objectAtIndex:indexPath.row];
    NSString *imageName = cake.image;
    NSString *cakeName = cake.name;
    cell.icyImageView.image = [UIImage imageNamed:imageName];
    cell.nameLabel.font = [UIFont fontWithName:@"GJJZQJW--GB1-0" size:22];
    cell.nameLabel.text = cakeName;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LCYDefaultDetailViewController *detailVC = [[LCYDefaultDetailViewController alloc] init];
    detailVC.icyCake = [self.defaultCakeArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
}
@end
