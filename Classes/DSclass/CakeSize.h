//
//  CakeSize.h
//  CoreDataGenerator
//
//  Created by eagle on 14-4-9.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DefaultToSize;

@interface CakeSize : NSManagedObject

@property (nonatomic, retain) NSString * description__;
@property (nonatomic, retain) NSNumber * id__;
@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) NSSet *cakes;
@end

@interface CakeSize (CoreDataGeneratedAccessors)

- (void)addCakesObject:(DefaultToSize *)value;
- (void)removeCakesObject:(DefaultToSize *)value;
- (void)addCakes:(NSSet *)values;
- (void)removeCakes:(NSSet *)values;

@end
