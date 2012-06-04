//
//  XmlWrapper.m
//  PWStore
//
//  Created by Andy Sawyer on 04/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import "XmlWrapper.h"
#import <libxml/xpath.h>

@implementation XmlWrapper
-(id)initWithData:(NSData *)data
{
    self = [super init];
    if( self ) {
        docPtr_ = xmlReadMemory( data.bytes, data.length,
                                 "", NULL, XML_PARSE_RECOVER );
        if( !docPtr_ ) {
            NSLog(@"Error parsing xml");
            return nil;
        }
    }
    return self;
}

+(id)xmlWithData:(NSData *)data
{
    XmlWrapper *xml = [[[XmlWrapper alloc] initWithData:data] autorelease];
    if( !xml ) {
        NSLog(@"xmlWithData: failed");
    }
    return xml;
}

-(NSArray *)xpathQuery:(NSString *)xpath
{
    if( !docPtr_ ) {
        NSAssert( docPtr_, @"xpathQuery on null doc" );
        return nil;
    }

    xmlXPathContextPtr context = xmlXPathNewContext(docPtr_);
    if( !context ) {
        NSAssert( context, @"Can't create XPath context" );
        return nil;
    }

    xmlXPathObjectPtr xobj = xmlXPathEvalExpression( (xmlChar *)[xpath cStringUsingEncoding:NSUTF8StringEncoding],
                                                     context );
    if( !xobj ) {
        NSLog(@"Unable to evaluate query");
        xmlXPathFreeContext(context);
        return nil;
    }

    xmlNodeSetPtr nodeSet = xobj->nodesetval;
    NSMutableArray *results = [NSMutableArray array];
    if( !nodeSet ) {
        NSLog(@"Empty node set" );
    } else {
        for( NSInteger i = 0 ; i < nodeSet->nodeNr ; ++i ) {
            xmlNodePtr node = nodeSet->nodeTab[i];
            // node->type; // element type enum
            // node->name; // element name string
            // node->properties; // xmlAttr -> list of properties
            NSMutableDictionary *props = [NSMutableDictionary dictionary];
            xmlAttrPtr prop = node->properties;
            while( prop ) {
                NSString *name = [NSString stringWithUTF8String:(const char *)prop->name];
                // TODO: Figure this out...
                xmlNodePtr val = prop->children;
                NSString *value = nil;
                if( val ) {
                    xmlChar *content = val->content;
                    if( content ) {
                        value = [NSString stringWithUTF8String:(const char *)content];
                    }
                }
                if( !value ) {
                    value = [NSString string];
                }
                prop = prop->next;
            }
            // ... and a bunch of other stuff...
            NSDictionary *nodeDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       [NSString stringWithUTF8String:(const char *)node->name],@"name",
                                                       [NSNumber numberWithInteger:node->type],@"type",
                                                         props,@"properties",
                                                       nil];
            [results addObject:nodeDictionary];
            // Do stuff
        }
    }
    xmlXPathFreeObject( xobj );
    xmlXPathFreeContext(context);
    return results;
}

-(void)dealloc
{
    if( docPtr_ ) {
        xmlFreeDoc( docPtr_ );
    }
    [super dealloc];
}
@end
