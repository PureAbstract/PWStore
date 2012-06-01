//
//  PWData.m
//  PWStore
//
//  Created by Andy Sawyer on 31/05/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
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
-(NSUInteger)count
{
    return [self.data count];
}

-(void)sortByTitle
{
    [self.data sortUsingComparator:^(id obj1, id obj2 ) {
            PWItem *p1 = (PWItem *)obj1;
            PWItem *p2 = (PWItem *)obj2;
            return [p1.title caseInsensitiveCompare:p2.title];
        }];
}

-(void)addObject:(PWItem *)item
{
    NSAssert1( [item isKindOfClass:[PWItem class]], @"Expected a PWItem, got %@", item );
    NSAssert( ![self containsObject:item], @"Object already present" );
    [self.data addObject:item];
    // Resort... this probably isn't the best place to do it...
    [self sortByTitle];
    // TODO: notify anyone who cares
    [[NSNotificationCenter defaultCenter] postNotificationName:kPWDataUpdated
                                                        object:self];
}

-(PWItem *)objectAtIndex:(NSUInteger)index
{
    NSObject *obj = [self.data objectAtIndex:index];
    NSAssert( [obj isKindOfClass:[PWItem class]], @"Expected PWItem" );
    return (PWItem *)obj;
}

-(BOOL)containsObject:(PWItem *)item
{
    return [self.data containsObject:item];
}

-(NSUInteger)indexOfObject:(PWItem *)item
{
    return [self.data indexOfObject:item];
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


#pragma mark -
#pragma mark NSFastEnumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
    return [self.data countByEnumeratingWithState:state
                                          objects:stackbuf
                                            count:len];
}

@end
