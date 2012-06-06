//
//  XmlDocument.h
//  PWStore
//
//  Created by Andy Sawyer on 04/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

// XmlNode, XmlDocument - wrappers for libxml2's xmlNodePtr and
// xmlDocPtr respectively. Note that, in this header, the pointers are
// declared as void *, in order to avoid this header having to pull in
// the libxml headers.

#import <Foundation/Foundation.h>

// Wrap up an xmlNodePtr It's important to note that this does NOT own
// the nodePtr, and so does NOT free it when it's done. That's left up
// to the XmlDocument (see below)
@interface XmlNode : NSObject {
    void *nodePtr_;             // xmlNodePtr
}
@property (nonatomic,readonly) NSString *name;
@property (nonatomic,copy) NSString *content;

// An array of XmlNode
-(NSArray *)childNodes;
// A map (string->string) of attributes
-(NSDictionary *)attributes;
// Find the first child with the specified name
-(XmlNode *)childWithName:(NSString *)name;

// Add a child node with the specified name
-(XmlNode *)addChildNode:(NSString *)name;
// Add a child node with the specified name and content
-(XmlNode *)addChildNode:(NSString *)name content:(NSString *)content;
// Set the named attribute to the specified value
-(void)setAttribute:(NSString *)name value:(NSString *)value;
@end

// Wrap up an xmlDocPtr. Unlike XmlNode, this DOES owen the docPtr,
// and so will free it when it is dealloc'd.
@interface XmlDocument : NSObject {
    void *docPtr_;              // xmlDocPtr
}

@property (readonly) XmlNode *rootNode;
// Creata a document with a root node called 'root'
-(id)init;
// Parse the data as XML
-(id)initWithData:(NSData *)data;
+(id)xmlWithData:(NSData *)data;

// Return an array of XmlNodes fulfilling the supplied xpath query
-(NSArray *)xpathQuery:(NSString *)xpath;
// Return the document as an Xml string
-(NSString *)toString;

@end
