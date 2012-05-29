//
//  PWItem.m
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import "PWItem.h"
#import "NSCoder+withDefaults.h"

#define kPropKeyTitle         @"t"
#define kPropKeyLogin         @"l"
#define kPropKeyPassword      @"p"
#define kPropKeyEmail         @"e"
#define kPropKeyUrl           @"u"
#define kPropKeyNotes         @"n"
#define kPropKeyCreated       @"c"
#define kPropKeyUpdated       @"m"

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
@synthesize created = created_;
@synthesize updated = updated_;

-(id)init {
    self = [super init];
    if( self ) {
        title_ = [NSString string];
        login_ = [NSString string];
        password_ = [NSString string];
        url_ = [NSString string];
        email_ = [NSString string];
        notes_ = [NSString string];
        created_ = [NSDate date];
        updated_ = [NSDate date];
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
    [created_ release];
    [updated_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding
// Note: This is all likely to change if/when I move to a property array
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //[super encodeWithCoder:aCoder];
    [aCoder encodeObject:title_ forKey:kPropKeyTitle];
    [aCoder encodeObject:login_ forKey:kPropKeyLogin];
    [aCoder encodeObject:password_ forKey:kPropKeyPassword];
    [aCoder encodeObject:email_ forKey:kPropKeyEmail];
    [aCoder encodeObject:url_ forKey:kPropKeyUrl];
    [aCoder encodeObject:notes_ forKey:kPropKeyNotes];
    [aCoder encodeObject:updated_ forKey:kPropKeyUpdated];
    [aCoder encodeObject:created_ forKey:kPropKeyCreated];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    //[super initWithCoder];
    self.title = [aDecoder stringForKey:kPropKeyTitle];
    self.login = [aDecoder stringForKey:kPropKeyLogin];
    self.password = [aDecoder stringForKey:kPropKeyPassword];
    self.email = [aDecoder stringForKey:kPropKeyEmail];
    self.url = [aDecoder stringForKey:kPropKeyUrl];
    self.notes = [aDecoder stringForKey:kPropKeyNotes];
    self.created = [aDecoder dateForKey:kPropKeyCreated];
    self.updated = [aDecoder dateForKey:kPropKeyUpdated];
    return self;
}


@end
