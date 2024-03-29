//
//  PWData.h
//  PWStore
//
//  Created by Andy Sawyer on 31/05/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWItem.h"

@interface PWData : NSObject<NSCoding, NSFastEnumeration> {
    NSMutableArray *data_;
}
@property (nonatomic,readonly) NSMutableArray *data;
// Number of items in collection
-(NSUInteger)count;
-(void)addObject:(PWItem *)item;
-(void)addObjectsFromArray:(NSArray *)array;
-(PWItem *)objectAtIndex:(NSUInteger)index;
-(BOOL)containsObject:(PWItem *)item;
-(NSUInteger)indexOfObject:(PWItem *)item;
-(void)removeObjectAtIndex:(NSUInteger)index;
-(void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
@end
