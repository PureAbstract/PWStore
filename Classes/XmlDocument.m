//
//  XmlDocument.m
//  PWStore
//
//  Created by Andy Sawyer on 04/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import "XmlDocument.h"
#import <libxml/parser.h>
#import <libxml/xpath.h>
#import <libxml/xmlwriter.h>

#pragma mark -
#pragma mark Utility Functions
static NSString *stringFromXmlString( const xmlChar *p ) {
    if( p ) {
        return [NSString stringWithUTF8String:(const char *)p];
    } else {
        return [NSString string];
    }
}

static const xmlChar *xmlStringFromString( NSString *s ) {
    return (const xmlChar *)[s UTF8String];
}

typedef void (^nodeTraversal)( xmlNodePtr node, BOOL *stop );
static void traverseNodeList( xmlNodePtr node, nodeTraversal func )
{
    BOOL stop = NO;
    while( node && !stop ) {
        func( node, &stop );
        node = node->next;
    }
}

typedef void (^attrTraversal)( xmlAttrPtr attr, BOOL *stop );
static void traverseAttrList( xmlAttrPtr attr, attrTraversal func )
{
    BOOL stop = NO;
    while( attr && !stop ) {
        func( attr, &stop );
        attr = attr->next;
    }
}


static NSMutableDictionary *dictionaryFromAttributes( xmlAttrPtr attribute ) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    traverseAttrList( attribute, ^(xmlAttrPtr attr, BOOL *stop) {
            NSString *name = stringFromXmlString( attr->name );
            NSString *value = nil;
            xmlNodePtr p = attr->children;
            if( p && p->content ) {
                value = stringFromXmlString( p->content );
            }
            if( !value ) {
                value = [NSString string];
            }
            [dict setObject:value forKey:name];
        } );
    return dict;
}

@interface XmlNode ()
@property (readonly) xmlNodePtr nodePtr;
@end

@implementation XmlNode
#pragma mark -
#pragma mark Initialisation
-(id)initWithNode:(xmlNodePtr)node
{
    self = [super init];
    if( self ) {
        nodePtr_ = node;
    }
    return self;
}

+(id)nodeForNode:(xmlNodePtr)node
{
    return [[[XmlNode alloc] initWithNode:node] autorelease];
}

#pragma mark -
#pragma mark Properties
-(xmlNodePtr)nodePtr
{
    NSAssert( nodePtr_, @"NULL nodePtr" );
    return (xmlNodePtr)nodePtr_;
}

-(NSString *)name
{
    return stringFromXmlString( self.nodePtr->name );
}

-(NSDictionary *)attributes
{
    return dictionaryFromAttributes( self.nodePtr->properties );
}

-(NSString *)content
{
    return self.nodePtr->content ? stringFromXmlString( self.nodePtr->content ) : nil;
}

-(void)setContent:(NSString *)content
{
    xmlNodeSetContent( self.nodePtr,
                       content ? xmlStringFromString( content ) : NULL );
}

-(NSArray *)childNodes
{
    NSMutableArray *children = [NSMutableArray array];

    traverseNodeList( self.nodePtr->children, ^( xmlNodePtr child, BOOL *stop ) {
            [children addObject:[XmlNode nodeForNode:child]];
        });

    return children;
}

#pragma mark -
#pragma mark Methods
-(XmlNode *)childWithName:(NSString *)name
{
    for( XmlNode *node in self.childNodes ) {
        if( [name isEqualToString:node.name] ) {
            return node;
        }
    }
    return nil;
}

-(XmlNode *)addChildNode:(NSString *)name content:(NSString *)content
{
    xmlNodePtr node = xmlNewChild( self.nodePtr,
                                   NULL,
                                   xmlStringFromString( name ),
                                   content ? xmlStringFromString( content ) : NULL
                                   );
    if( node ) {
        return [XmlNode nodeForNode:node];
    }
    return nil;
}


-(XmlNode *)addChildNode:(NSString *)name
{
    return [self addChildNode:name content:nil];
}

-(void)setAttribute:(NSString *)name value:(NSString *)value
{
    xmlSetProp( self.nodePtr,
                xmlStringFromString( name ),
                value ? xmlStringFromString( value ) : NULL );
}
@end

#pragma mark -
#pragma mark XmlDocument private interface
@interface XmlDocument ()
@property (nonatomic,readonly) xmlDocPtr docPtr;
@end

#pragma mark -
#pragma mark XmlDocument implementation

@implementation XmlDocument
#pragma mark -
#pragma mark Class Init
+(void)load
{
    xmlInitParser();
}

#pragma mark -
#pragma mark Properties
-(xmlDocPtr)docPtr
{
    NSAssert( docPtr_, @"Null DocPtr" );
    return (xmlDocPtr)docPtr_;
}

-(XmlNode *)rootNode
{
    return [XmlNode nodeForNode:self.docPtr->children];
}

#pragma mark -
#pragma mark Initialisation
-(id)init
{
    self = [super init];
    if( self ) {
        xmlDocPtr doc = xmlNewDoc( (xmlChar *)"1.0" );
        docPtr_ = doc;
        // Hack... stuff in a root node called 'root'
        xmlNodePtr root = xmlNewNode( NULL, (xmlChar *)"root" );
        NSAssert( root, @"Null root" );
        xmlDocSetRootElement( doc, root );
    }
    return self;
}

-(id)initWithData:(NSData *)data
{
    self = [super init];
    if( self ) {
        xmlDocPtr doc = xmlReadMemory( data.bytes, data.length,
                                        "", NULL, XML_PARSE_RECOVER );
        docPtr_ = doc;
        if( !doc ) {
            NSLog(@"Error parsing xml");
            return nil;
        }
    }
    return self;
}

+(id)xmlWithData:(NSData *)data
{
    XmlDocument *xml = [[[XmlDocument alloc] initWithData:data] autorelease];
    if( !xml ) {
        NSLog(@"xmlWithData: failed");
    }
    return xml;
}


#pragma mark -
#pragma mark XPath Query
-(NSArray *)xpathQuery:(NSString *)xpath
{
    xmlDocPtr doc = self.docPtr;
    if( !doc ) {
        NSAssert( NO, @"xpathQuery on null doc" );
        return nil;
    }

    xmlXPathContextPtr context = xmlXPathNewContext(doc);
    if( !context ) {
        NSAssert( context, @"Can't create XPath context" );
        return nil;
    }

    xmlXPathObjectPtr xobj = xmlXPathEvalExpression( xmlStringFromString( xpath ),
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
            [results addObject:[XmlNode nodeForNode:node]];
        }
    }
    xmlXPathFreeObject( xobj );
    xmlXPathFreeContext(context);
    return results;
}

#pragma mark -
#pragma mark Write to String
-(NSString *)toString
{
    NSString *result = nil;
    xmlChar *buf = NULL;
    int size = 0;
    xmlDocDumpFormatMemory( self.docPtr, &buf, &size, 0 );
    result = stringFromXmlString( buf );
    xmlFree( buf );
    return result;
}


#pragma mark -
#pragma mark Memory Management
-(void)dealloc
{
    xmlDocPtr doc = self.docPtr;
    docPtr_ = NULL;
    if( doc ) {
        xmlFreeDoc( doc );
    }
    [super dealloc];
}
@end

