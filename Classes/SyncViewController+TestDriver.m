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
        [node addAttribute:@"title" value:item.title];
        [node addAttribute:@"login" value:item.login];
        [node addAttribute:@"password" value:item.password];
        [node addAttribute:@"url" value:item.url];
        [node addAttribute:@"email" value:item.email];
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
