//
//  XmlDocument.h
//  PWStore
//
//  Created by Andy Sawyer on 04/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XmlNode : NSObject {
    void *nodePtr_;             // xmlNodePtr
}
@property (nonatomic,readonly) NSString *name;
@property (nonatomic,copy) NSString *content;

-(NSArray *)childNodes;
-(NSDictionary *)attributes;
-(XmlNode *)childWithName:(NSString *)name;

-(XmlNode *)addChildNode:(NSString *)name;
-(XmlNode *)addChildNode:(NSString *)name content:(NSString *)content;

-(void)setAttribute:(NSString *)name value:(NSString *)value;
@end

@interface XmlDocument : NSObject {
    void *docPtr_;              // xmlDocPtr
}
@property (readonly) XmlNode *rootNode;
-(id)init;
-(id)initWithData:(NSData *)data;
+(id)xmlWithData:(NSData *)data;

-(NSArray *)xpathQuery:(NSString *)xpath;

-(NSString *)toString;

@end

