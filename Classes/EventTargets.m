//
//  EventTargets.m
//  PWStore
//
//  Created by Andy Sawyer on 02/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import "EventTargets.h"

@implementation EventTarget
@synthesize target = target_;
@synthesize action = action_;

-(id)initWithTarget:(id)aTarget action:(SEL)aAction
{
    NSAssert( aTarget, @"NULL Target" );
    NSAssert( aAction, @"NULL Action" );
    NSAssert( [(NSObject *)aTarget respondsToSelector:aAction], @"Bad target/selector" );
    self = [super init];
    if( self ) {
        target_ = aTarget;
        action_ = aAction;
    }
    return self;
}

-(void)sendActionWithObject:(id)object
{
    [target_ performSelector:action_ withObject:object];
}

@end

@implementation EventTargets
-(id)init
{
    self = [super init];
    if( self ) {
        targets = [NSMutableArray array];
    }
    return self;
}

-(void)dealloc
{
    [targets release];
    [super dealloc];
}

-(void)addTarget:(id)target action:(SEL)action
{
    EventTarget *tgt = [[EventTarget alloc] initWithTarget:target
                                                    action:action];
    [targets addObject:tgt];
    [tgt release];
}

-(void)removeTarget:(id)target action:(SEL)action
{
    NSIndexSet *toRemove = [targets indexesOfObjectsPassingTest:^(id obj, NSUInteger index, BOOL *stop ) {
            EventTarget *tgt = (EventTarget *)obj;
            if( tgt.target == target ) {
                if( !action ) {
                    return YES;
                }
                if( tgt.action == action ) {
                    return YES;
                }
            }
            return NO;
        }];
    [targets removeObjectsAtIndexes:toRemove];
}

-(void)sendActionsWithObject:(id)object
{
    for( EventTarget *tgt in targets ) {
        [tgt sendActionWithObject:object];
    }
}

@end
