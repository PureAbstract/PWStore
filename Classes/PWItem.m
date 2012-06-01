//
//  PWItem.m
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import "PWItem.h"
#import "NSCoder+withDefaults.h"


NSString * const kPWDataUpdated = @"kPWDataUpdated";


static NSString * const kPropKeyTitle    = @"t";
static NSString * const kPropKeyLogin    = @"l";
static NSString * const kPropKeyPassword = @"p";
static NSString * const kPropKeyEmail    = @"e";
static NSString * const kPropKeyUrl      = @"u";
static NSString * const kPropKeyNotes    = @"n";
static NSString * const kPropKeyCreated  = @"c";
static NSString * const kPropKeyUpdated  = @"m";

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
        self.title = [NSString string];
        self.login = [NSString string];
        self.password = [NSString string];
        self.url = [NSString string];
        self.email = [NSString string];
        self.notes = [NSString string];
        self.created = [NSDate date];
        self.updated = [NSDate date];
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
