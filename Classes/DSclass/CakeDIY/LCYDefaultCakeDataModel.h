//
//  LCYDefaultCakeDataModel.h
//  CakeDIY
//
//  Created by eagle on 14-3-28.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCYDefaultCakeDataModel : NSObject

@property NSUInteger sizeIndex;

@property (strong, nonatomic) NSString *id__;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *image;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *material;
@property (strong, nonatomic) NSString *description__;
@property (strong, nonatomic) NSArray *size;

@end
