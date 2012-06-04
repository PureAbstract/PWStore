//
//  SyncViewController+TestDriver.m
//  PWStore
//
//  Created by Andy Sawyer on 04/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import "SyncViewController+TestDriver.h"
#import "PWData.h"
#import "UIApplication+Utility.h"
#import "XmlDocument.h"
#import "PWStoreAppDelegate.h"
#import "PWData+StringExport.h"

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
    if( ![[NSFileManager defaultManager] fileExistsAtPath:import] ) {
        NSLog(@"file not found %@",import);
        return;
    }

    NSData *data = [NSData dataWithContentsOfFile:import];
    if( !data ) {
        NSLog(@"dataWithContentsOfFile failed");
        return;
    }

    XmlDocument *xml = [XmlDocument xmlWithData:data];
    if( !xml ) {
        NSLog(@"failed to load xml");
        return;
    }

    NSArray *results = [xml xpathQuery:@"//root/item"];
    if( results ) {
        NSLog(@"xpath failed");
        return;
    }

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
        item.title = [self getStringFromDictionary:attributes forKey:@"title"];
        item.login = [self getStringFromDictionary:attributes forKey:@"login"];
        item.password = [self getStringFromDictionary:attributes forKey:@"password"];
        item.url = [self getStringFromDictionary:attributes forKey:@"url"];
        item.email = [self getStringFromDictionary:attributes forKey:@"email"];
        XmlNode *notes = [node childWithName:@"notes"];
        if( notes && notes.content ) {
            item.notes = [notes.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        [[self getRootData] addObject:item];
        [item release];
    }
}

-(void)testXmlExport
{
    XmlDocument *xml = [[XmlDocument alloc] init];
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

-(void)testTextImport
{
    NSString *filename = [UIApplication documentPath:@"import.txt"];
    if( ![[NSFileManager defaultManager] fileExistsAtPath:filename] ) {
        NSLog(@"File not found : %@",filename);
        return;
    }
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError *error = nil;
    NSString *text = [NSString stringWithContentsOfFile:filename
                                           usedEncoding:&encoding
                                                  error:&error];
    if( !text || error ) {
        NSLog(@"stringWithContentsOfFile failed");
        return;
    }
    PWData *decoded = [PWData fromString:text];
    // Do something with this...
    for( PWItem *item in decoded ) {
        NSLog(@"Item: %@", item.title );
    }
}

-(void)testTextExport
{
    NSString *filename = [UIApplication documentPath:@"export.txt"];
    PWData *data = [self getRootData];
    NSString *text = [data asString];
    NSError *error = nil;
    BOOL ok = [text writeToFile:filename
                     atomically:YES
                       encoding:NSUTF8StringEncoding
                          error:&error];
    if( !ok || error ) {
        NSLog(@"Save error");
    }
}
@end
