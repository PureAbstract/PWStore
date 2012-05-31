//
//  PWData.m
//  PWStore
//
//  Created by Andy Sawyer on 31/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PWData.h"
#import "NSCoder+withDefaults.h"

@implementation PWData

static NSString *kPropKeyItems = @"i";

#pragma mark -
#pragma mark Initialisation
-(id)init
{
    self = [super init];
    if( self ) {
    }
    return self;
}

#pragma mark -
#pragma mark Properties
-(NSMutableArray *)data {
    if( !data_ ) {
        data_ = [NSMutableArray new];
    }
    return data_;
}

#pragma mark -
#pragma mark Data access
-(NSUInteger)count {
    return [self.data count];
}

-(void)addObject:(PWItem *)item
{
    NSAssert( [item isKindOfClass:[PWItem class]], @"Not a PWItem" );
    [self.data addObject:item];
    // TODO: Resort collection - notify observers
}

#pragma mark -
#pragma mark Memory management
-(void)dealloc {
    if( data_ ) {
        [data_ release];
    }
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.data
                  forKey:kPropKeyItems];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if( self ) {
        NSArray *items = [aDecoder arrayForKey:kPropKeyItems];
        if( items ) {
            [self.data removeAllObjects];
            for( NSObject *obj in items ) {
                NSAssert( [obj isKindOfClass:[PWItem class]], @"Not a PWItem" );
            }
            [self.data addObjectsFromArray:items];
        }
    }
    return self;
}

@end
