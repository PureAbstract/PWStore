#define CATCH_CONFIG_MAIN
#include "catch.hpp"
#import "NSCompoundStream.h"
#import "NSData+AES.h"
#import "NSData+CryptoHash.h"
#import "NSData+BlockAES.h"
#import "XmlDocument.h"

TEST_CASE("NSCompoundStream/init","Initialise a compound stream")
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    NSCompoundStream *stream = [NSCompoundStream new];
    REQUIRE( stream != nil );
    REQUIRE( stream.streamStatus == NSStreamStatusNotOpen );
    REQUIRE( stream.hasBytesAvailable == NO );
    [stream open];
    // Is this a bug in Catch? Without the cast, this test fails
    REQUIRE( stream.streamStatus == (NSUInteger)NSStreamStatusOpen );
    [stream release];

    [pool release];
}

TEST_CASE("NSMutableData+wipeZero","Wipe data")
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    uint8_t bytes[] = "123456";
    REQUIRE( sizeof(bytes) > 0 );

    NSMutableData *data = [NSMutableData dataWithBytes:bytes length:sizeof(bytes)];
    REQUIRE( data );
    REQUIRE( data.length == sizeof(bytes) );
    REQUIRE( memcmp( data.bytes, bytes, sizeof(bytes) ) == 0 );
    [data wipeZero];
    REQUIRE( memcmp( data.bytes, bytes, sizeof(bytes) ) != 0 );
    bzero( bytes, sizeof(bytes) );
    REQUIRE( memcmp( data.bytes, bytes, sizeof(bytes) ) == 0 );

    [pool release];
}

// This is kind of hard to test for, since we're testing
// for deliberatly random behaviour...
TEST_CASE("NSMutableData/wipeRandom","Random fill data")
{
    static const size_t length = 10;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    NSMutableData *data = [NSMutableData dataWithLength:length];
    NSMutableData *zero = [NSMutableData dataWithLength:length];
    REQUIRE( [data isEqualToData:zero] );
    for( int i = 0 ; i < 5 ; ++i ) {
        [data wipeRandom];
        REQUIRE( ![data isEqualToData:zero] );
    }

    [pool release];
}

TEST_CASE( "NSData+AES/randomBytes/1", "Zero random bytes" )
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    NSData *random = [NSData randomBytes:0];
    REQUIRE( random );
    REQUIRE( random.length == 0 );

    [pool release];
}

TEST_CASE( "NSData+AES/SHA1/empty", "sha1 test - empty data" )
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    NSData *data = [NSMutableData dataWithLength:0];

    // Determined by creating an empty file, then running sha1deep
    static const uint8_t expect[] = {
        0xda, 0x39, 0xa3, 0xee,
        0x5e, 0x6b, 0x4b, 0x0d,
        0x32, 0x55, 0xbf, 0xef,
        0x95, 0x60, 0x18, 0x90,
        0xaf, 0xd8, 0x07, 0x09
    };

    NSData *hash = [data sha1];
    REQUIRE( hash );
    REQUIRE( hash.length == sizeof(expect) );
    REQUIRE( memcmp( hash.bytes, expect, hash.length ) == 0 );


    [pool release];
}

TEST_CASE( "NSData+AES/SHA1/zerobyte", "sha1 test - a single, zero byte" )
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    NSData *data = [NSMutableData dataWithLength:1];
    REQUIRE( data.length == 1 );
    REQUIRE( ((uint8_t *)data.bytes)[0] == 0 );

    static const uint8_t expect[] = {
        0x5b, 0xa9, 0x3c, 0x9d,
        0xb0, 0xcf, 0xf9, 0x3f,
        0x52, 0xb5, 0x21, 0xd7,
        0x42, 0x0e, 0x43, 0xf6,
        0xed, 0xa2, 0x78, 0x4f,
    };

    NSData *hash = [data sha1];
    REQUIRE( hash );
    REQUIRE( hash.length == sizeof(expect) );
    REQUIRE( memcmp( hash.bytes, expect, hash.length ) == 0 );

    [pool release];
}

TEST_CASE( "NSData+AES/SHA1/string", "sha1 test - with a string" )
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    NSData *data = [NSMutableData dataWithBytes:"sha1test" length:8];

    static const uint8_t expect[] = {
        0x12, 0xc4, 0xc6, 0x0e,
        0xe0, 0x87, 0xae, 0x0f,
        0x12, 0xdc, 0x6a, 0xbc,
        0x88, 0x49, 0x5e, 0x45,
        0x9f, 0x6f, 0x26, 0x54,
    };

    NSData *hash = [data sha1];
    REQUIRE( hash );
    REQUIRE( hash.length == sizeof(expect) );
    REQUIRE( memcmp( hash.bytes, expect, hash.length ) == 0 );

    [pool release];
}



TEST_CASE("NSDATA+AES/Encrypt","encrypt")
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    NSData *key = [NSData dataWithBytes:"secret" length:6];
    NSData *data = [NSMutableData dataWithLength:500];
    NSData *enc = [data encryptWithKey:key];
    REQUIRE( ![data isEqualToData:enc] );
    NSData *dec = [enc decryptWithKey:key];
    REQUIRE( [dec isEqualToData:data] );

    [pool release];
}

TEST_CASE("NSDATA+AES/EncryptWithSalt","encrypt with salt")
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    NSUInteger salt = 32;
    NSData *key = [NSData dataWithBytes:"secret" length:6];
    NSData *data = [NSMutableData dataWithLength:500];
    NSData *enc = [data encryptWithKey:key saltLength:salt];
    REQUIRE( ![data isEqualToData:enc] );
    NSData *dec = [enc decryptWithKey:key saltLength:salt];
    REQUIRE( [dec isEqualToData:data] );

    [pool release];
}


TEST_CASE( "NSData/BlockAES", "BlockAES" )
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    NSData *key = [NSData dataWithBytes:"secret" length:6];
    NSData *data = [NSMutableData dataWithLength:1];
    REQUIRE( data != nil );
    NSData *enc = [data blockEncrypt:key];
    REQUIRE( enc != nil );
    NSLog(@"data:%d,enc:%d",data.length,enc.length);
    REQUIRE( ![enc isEqualToData:data] );
    NSData *dec = [enc blockDecrypt:key];
    NSLog(@"data:%d,dec:%d",data.length,dec.length);
    REQUIRE( dec != nil );
    REQUIRE( [dec isEqualToData:data] );

    [pool release];
}


TEST_CASE( "NSData/AES-BlockVsSingle", "NSData (AES) and NSData (BlockAES) interoperability" )
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    NSData *key = [NSData dataWithBytes:"secret" length:6];
    NSData *plain = [NSData dataWithBytes:"hello world" length:10];
    NSLog(@"plain encryptWithKey");
    NSData *enc = [plain encryptWithKey:key];
    REQUIRE( enc != nil );
    REQUIRE( ![enc isEqualToData:plain] );
    NSLog(@"plain %d, enc %d",plain.length,enc.length);
    NSLog(@"enc blockDecrypt");
    NSData *dec = [enc blockDecrypt:key];
    REQUIRE( dec != nil );
    REQUIRE( [plain isEqualToData:dec] );

    [pool release];
}


TEST_CASE( "XMLDocument/init","Init XmlDocument")
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    XmlDocument *doc = [XmlDocument new];
    REQUIRE( doc != nil );
    REQUIRE( doc.rootNode != nil );
    REQUIRE( [doc.rootNode.name isEqualToString:@"root"] );
    REQUIRE( doc.rootNode.childNodes.count == 0 );
    [doc release];

    [pool release];
}

TEST_CASE("XMLDocument/initWithRoo","Init XMLDocument with root")
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    XmlDocument *doc = [[XmlDocument alloc]  initWithRoot:@"document"];
    REQUIRE( doc );
    REQUIRE( doc.rootNode );
    REQUIRE( [doc.rootNode.name isEqualToString:@"document"] );
    REQUIRE( doc.rootNode.childNodes.count == 0 );
    [doc release];

    [pool release];
}

TEST_CASE("XmlDocument/initWithXml","init XmlDocument with Xml")
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    NSString *xml = @"<?xml version='1.0'?><document><children><child id='3'/><child id='2'/><child id='1'/></children></document>";
    XmlDocument *doc = [[[XmlDocument alloc] initWithXml:xml] autorelease];

    REQUIRE( doc );
    REQUIRE( doc.rootNode );
    REQUIRE( [doc.rootNode.name isEqualToString:@"document"] );
    REQUIRE( doc.rootNode.childNodes.count == 1 );
    XmlNode *node = [doc.rootNode.childNodes objectAtIndex:0];
    REQUIRE( [node.name isEqualToString:@"children"] );
    REQUIRE( node.childNodes.count == 3 );
    REQUIRE( [node.childNodes objectAtIndex:0] );
    for( NSUInteger i = 0 ; i < 3 ; ++i ) {
        XmlNode *child = [node.childNodes objectAtIndex:i];
        REQUIRE( child );
        REQUIRE( [child.name isEqualToString:@"child"] );
        REQUIRE( child.childNodes.count == 0 );
        NSDictionary *attr = child.attributes;
        REQUIRE( attr.count == 1 );
        REQUIRE( [attr objectForKey:@"id"] != nil );
        REQUIRE( [[attr objectForKey:@"id"] isKindOfClass:[NSString class]] );
        NSString *val = [attr objectForKey:@"id"];
        NSString *expect = [NSString stringWithFormat:@"%d",3-i];
        REQUIRE( [val isEqualToString:expect] );
    }

    REQUIRE( [doc xpathQuery:@"nothing"].count == 0 );
    REQUIRE( [doc xpathQuery:@"/document"].count == 1 );
    REQUIRE( [doc xpathQuery:@"/document/children"].count == 1 );
    REQUIRE( [doc xpathQuery:@"/document/children/child"].count == 3 );
    REQUIRE( [doc xpathQuery:@"/document/children/child[@id]"].count == 3 );
    REQUIRE( [doc xpathQuery:@"/document/children/child[@id>1]"].count == 2 );

    [pool release];
}

TEST_CASE("XmlDocument/stream","Creata a document, then stream it.")
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    XmlDocument *doc = [[XmlDocument new] autorelease];
    REQUIRE( doc );
    REQUIRE( doc.rootNode );
    REQUIRE( [doc.rootNode.name isEqualToString:@"root"] );
    REQUIRE( doc.rootNode.childNodes.count == 0 );
    REQUIRE( doc.rootNode.attributes.count == 0 );
    [doc.rootNode setAttribute:@"test" value:@"case"];
    REQUIRE( doc.rootNode.attributes.count == 1 );
    REQUIRE( [doc.rootNode.attributes objectForKey:@"test"] );
    REQUIRE( [[doc.rootNode.attributes objectForKey:@"test"] isEqualToString:@"case"] );
    [doc.rootNode addChildNode:@"child" content:@"some <content>"];
    NSString *xml = [doc toString];
    REQUIRE( xml );
    NSLog(@"As Xml [%@]",xml);
    XmlDocument *doc2 = [[[XmlDocument alloc] initWithXml:xml] autorelease];
    REQUIRE( doc2 );
    REQUIRE( doc2.rootNode );
    REQUIRE( [doc2.rootNode.name isEqualToString:@"root"] );
    REQUIRE( doc2.rootNode.attributes.count == 1 );
    REQUIRE( [doc2.rootNode.attributes objectForKey:@"test"] );
    REQUIRE( [[doc2.rootNode.attributes objectForKey:@"test"] isEqualToString:@"case"] );
    REQUIRE( doc2.rootNode.childNodes.count == 1 );
    XmlNode *c = [doc2.rootNode.childNodes objectAtIndex:0];
    REQUIRE( c );
    REQUIRE( [c.name isEqualToString:@"child"] );
    REQUIRE( c.attributes.count == 0 );
    REQUIRE( c.childNodes.count == 1 );
    REQUIRE( c.content != nil );
    REQUIRE( [c.content isEqualToString:@"some <content>"] );

    [pool release];
}


TEST_CASE( "XmlDocument/content", "Set node content" )
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    XmlDocument *doc = [[XmlDocument new] autorelease];
    REQUIRE( doc );
    doc.rootNode.content = @"yada yada";
    NSLog(@"Child: %@",[doc.rootNode.childNodes objectAtIndex:0]);
    NSLog(@"Child: %@",[[doc.rootNode.childNodes objectAtIndex:0] name]);
    //NSLog(@"[%@]",[doc toString]);

    [pool release];
}

TEST_CASE( "NSData+AES/CryptWithSalt", "Test encrypt/decrypt with salt." )
{
    const size_t saltSize = 32;
    const size_t keySize = 32;
    const size_t dataSize = 1024;

    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    // A random key and data...
    NSData *key = [NSData randomBytes:keySize];
    NSData *data = [NSData randomBytes:dataSize];

    // Encrypt
    NSData *encrypted1 = [data encryptWithKey:key
                                  saltLength:saltSize];
    REQUIRE( ![encrypted1 isEqualToData:data] );

    // .. and again
    NSData *encrypted2 = [data encryptWithKey:key
                                   saltLength:saltSize];
    REQUIRE( ![encrypted2 isEqualToData:data] );

    // Now decrypt and verify...
    NSData *decrypted1 = [encrypted1 decryptWithKey:key
                                         saltLength:saltSize];
    REQUIRE( [data isEqualToData:decrypted1] );

    NSData *decrypted2 = [encrypted2 decryptWithKey:key
                                         saltLength:saltSize];
    REQUIRE( [data isEqualToData:decrypted2] );

    // Now the important bit - verify that the salt has done its job!
    // Note that since the salt is random, both salts might be the
    // same, which would result in the encrypted blocks being the
    // same.

    // Possible, but highly improbable (depending on how good a source
    // of entropy SecRandomCopyBytes is)
    REQUIRE( ![encrypted1 isEqualToData:encrypted2] );

    [pool release];
}
