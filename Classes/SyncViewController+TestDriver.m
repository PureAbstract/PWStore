//
//  SyncViewController+TestDriver.m
//  PWStore
//
//  Created by Andy Sawyer on 04/06/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncViewController+TestDriver.h"
#import "PWData.h"
#import "UIApplication+Utility.h"
#import "XmlWrapper.h"
#import "PWStoreAppDelegate.h"


@implementation SyncViewController (TestDriver)
-(PWData *)getRootData
{
    UIApplication *app = [UIApplication sharedApplication];
    NSAssert( app, @"NULL Application" );
    NSObject *delegate = app.delegate;
    NSAssert( delegate, @"NULL Delegate" );
    NSAssert( [delegate isKindOfClass:[PWStoreAppDelegate class]], @"Not a PWStoreAppDelegate" );
    return ((PWStoreAppDelegate *)delegate).pwitems;
}

#pragma mark -
#pragma mark Test Functions
-(NSString *)getStringFromDictionary:(NSDictionary *)dict forKey:(NSString *)key
{
    NSObject *obj = [dict objectForKey:key];
    if( obj && [obj isKindOfClass:[NSString class]] ) {
        return (NSString *)obj;
    }
    return [NSString string];
}

-(void)testXmlImport
{
    NSString *import = [UIApplication documentPath:@"import.xml"];
    if( [[NSFileManager defaultManager] fileExistsAtPath:import] ) {
        NSData *data = [NSData dataWithContentsOfFile:import];
        if( data ) {
            XmlWrapper *xml = [XmlWrapper xmlWithData:data];
            NSAssert( xml, @"failed to load xml" );
            if( xml ) {
                NSArray *results = [xml xpathQuery:@"//root/item"];
                if( results ) {
                    for( XmlNode *node in results ) {
                        NSLog(@"node : %@", node.name);
                        for( XmlNode *child in node.childNodes ) {
                            NSLog(@"child: %@",child.name);
                        }
                        NSDictionary *attributes = node.attributes;
                        for( NSString *attr in attributes ) {
                            NSLog(@"attr: %@=%@",attr,[attributes objectForKey:attr]);
                        }
                        PWItem *item = [PWItem new];
                        item.title = [self getStringFromDictionary:attributes forKey:@"name"];
                        item.login = [self getStringFromDictionary:attributes forKey:@"user"];
                        item.password = [self getStringFromDictionary:attributes forKey:@"pass"];
                        item.url = [self getStringFromDictionary:attributes forKey:@"url"];
                        item.email = [self getStringFromDictionary:attributes forKey:@"email"];
                        XmlNode *notes = [node childWithName:@"notes"];
                        if( notes && notes.content ) {
                            item.notes = notes.content;
                        }
                        [[self getRootData] addObject:item];
                        [item release];
                    }
                }
            }
        }
    }
}

-(void)testXmlExport
{
    XmlWrapper *xml = [[XmlWrapper alloc] init];
    PWData *data = [self getRootData];
    for( PWItem *item in data ) {
        XmlNode *node = [xml.rootNode addChildNode:@"item"];
        [node setAttribute:@"title" value:item.title];
        [node setAttribute:@"login" value:item.login];
        [node setAttribute:@"password" value:item.password];
        [node setAttribute:@"url" value:item.url];
        [node setAttribute:@"email" value:item.email];
        [node addChildNode:@"notes"
                   content:item.notes];
    }
    NSString *exp = [xml toString];
    NSError *error = nil;
    BOOL ok = [exp writeToFile:[UIApplication documentPath:@"export.xml"]
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:&error];
    if( !ok || error ) {
        NSLog(@"Save failed");
    }
    [xml release];
}
@end
