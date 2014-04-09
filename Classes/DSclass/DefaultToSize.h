//
//  DefaultToSize.h
//  CoreDataGenerator
//
//  Created by eagle on 14-4-9.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CakeSize, DefaultCake;

@interface DefaultToSize : NSManagedObject

@property (nonatomic, retain) NSNumber * cakeID;
@property (nonatomic, retain) NSNumber * sizeID;
@property (nonatomic, retain) DefaultCake *theCake;
@property (nonatomic, retain) CakeSize *theSize;

@end
