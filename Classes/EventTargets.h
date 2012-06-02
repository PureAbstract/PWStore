//
//  EventTargets.h
//  PWStore
//
//  Created by Andy Sawyer on 02/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//
// A simple mechanism to wrap up multiple event targets

#import <Foundation/Foundation.h>

// TODO: This could (should!) probably be made private to the EventTargets implementation
@interface EventTarget : NSObject {
    id target_;
    SEL action_;
}
@property (nonatomic,readonly) id target;
@property (nonatomic,readonly) SEL action;
-(id)initWithTarget:(id)target action:(SEL)action;
-(void)sendAction;
-(void)sendActionWithObject:(id)object;

@end

@interface EventTargets : NSObject {
    NSMutableArray *targets;
}
-(void)addTarget:(id)target action:(SEL)action;
-(void)removeTarget:(id)target action:(SEL)action;
-(void)sendActions;
-(void)sendActionsWithObject:(id)object;
@end
