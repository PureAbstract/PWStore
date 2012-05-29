//
//  PWItem.m
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import "PWItem.h"


enum {
    kItemPropTitle,
    kItemPropLogin,
    kItemPropPassword,
    kItemPropEmail,
    kItemPropUrl,
    kItemPropNotes,

    kItemPropertyCount
};

@implementation PWItem
@synthesize title = title_;
@synthesize login = login_;
@synthesize password = password_;
@synthesize url = url_;
@synthesize email = email_;
@synthesize notes = notes_;

-(id)init {
    self = [super init];
    if( self ) {
        title_ = @"";
        login_ = @"";
        password_ = @"";
        url_ = @"";
        email_ = @"";
        notes_ = @"";
    }
    return self;
}

-(void)dealloc {
    [title_ release];
    [login_ release];
    [password_ release];
    [url_ release];
    [email_ release];
    [notes_ release];
    [super dealloc];
}


@end
