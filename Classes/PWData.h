//
//  PWData.h
//  PWStore
//
//  Created by Andy Sawyer on 31/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
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
-(PWItem *)objectAtIndex:(NSUInteger)index;
@end
