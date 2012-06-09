//
//  NSData+CryptoHash.m
//  PWStore
//
//  Created by Andy Sawyer on 09/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import "NSData+CryptoHash.h"
//#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>


@implementation NSData (CryptoHash)
-(NSMutableData *)sha256
{
    NSMutableData *hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256( self.bytes, self.length, hash.mutableBytes );
    return hash;
}

-(NSMutableData *)sha1
{
    NSMutableData *hash = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CC_SHA1( self.bytes, self.length, hash.mutableBytes );
    return hash;
}
@end
