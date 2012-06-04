//
//  XmlWrapper.h
//  PWStore
//
//  Created by Andy Sawyer on 04/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <libxml/parser.h>

@interface XmlWrapper : NSObject {
    xmlDocPtr docPtr_;
}
-(id)initWithData:(NSData *)data;
+(id)xmlWithData:(NSData *)data;

-(NSArray *)xpathQuery:(NSString *)xpath;

@end
