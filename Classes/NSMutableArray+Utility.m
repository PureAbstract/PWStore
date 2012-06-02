//
//  NSMutableArray+Utility.m
//  PWStore
//
//  Created by Andy Sawyer on 02/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import "NSMutableArray+Utility.h"


@implementation NSMutableArray (Utility)
-(void)removeObjectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    NSIndexSet *toRemove = [self indexesOfObjectsPassingTest:predicate];
    [self removeObjectsAtIndexes:toRemove];
}

@end
