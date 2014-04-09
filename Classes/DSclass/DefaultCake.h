//
//  DefaultCake.h
//  CoreDataGenerator
//
//  Created by eagle on 14-4-9.
//  Copyright (c) 2014年 Duostec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DefaultToSize;

@interface DefaultCake : NSManagedObject

@property (nonatomic, retain) NSString * description__;
@property (nonatomic, retain) NSNumber * id__;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * material;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSSet *sizes;
@end

@interface DefaultCake (CoreDataGeneratedAccessors)

- (void)addSizesObject:(DefaultToSize *)value;
- (void)removeSizesObject:(DefaultToSize *)value;
- (void)addSizes:(NSSet *)values;
- (void)removeSizes:(NSSet *)values;

@end
