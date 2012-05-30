//
//  NSData+AES.m
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import "NSData+AES.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (AES)
-(NSData *)sha256
{
    NSMutableData *hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256( self.bytes, self.length, hash.mutableBytes );
    return hash;
}

-(NSData *)sha1
{
    NSMutableData *hash = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CC_SHA1( self.bytes, self.length, hash.mutableBytes );
    return hash;
}

+(NSData *)randomBytes:(size_t)length
{
    NSMutableData *bytes = [NSMutableData dataWithLength:length];
    if( length > 0 ) {
        SecRandomCopyBytes( kSecRandomDefault, length, bytes.mutableBytes );
    }
    return bytes;
}


-(NSMutableData *)cryptOperation:(CCOperation) operation
                         withKey:(NSData *)key
{
    if( key.length != kCCKeySizeAES256 ) {
        // Key the wrong size, go hash with SHA256...
        NSAssert( CC_SHA256_DIGEST_LENGTH == kCCKeySizeAES256, @"This is odd...");
        key = [key sha256];
    }
    NSAssert( key.length == kCCKeySizeAES256, @"Bad key size" );

    // Calculate the required output buffer size
    NSUInteger outputLen = (1+self.length/kCCBlockSizeAES128)*kCCBlockSizeAES128;
    NSMutableData *result = [NSMutableData dataWithLength:outputLen];
    // Init vector
    NSData *iv = [NSMutableData dataWithLength:kCCBlockSizeAES128];
    size_t dataOut = 0;
    CCCryptorStatus status = CCCrypt( operation,
                                      kCCAlgorithmAES128,
                                      kCCOptionPKCS7Padding,
                                      key.bytes,
                                      key.length,
                                      iv.bytes,
                                      self.bytes,
                                      self.length,
                                      result.mutableBytes,
                                      result.length,
                                      &dataOut );
    if( kCCSuccess != status ) {
        NSLog(@"CCCrypt error %d",status);
        result = nil;
    } else {
        result.length = dataOut;
    }
    return result;
}

-(NSMutableData *)encryptWithKey:(NSData *)key
{
    return [self cryptOperation:kCCEncrypt
                        withKey:key];
}

-(NSMutableData *)decryptWithKey:(NSData *)key
{
    return [self cryptOperation:kCCDecrypt
                        withKey:key];
}

// Append some random salt, and then encrypt with key
-(NSMutableData *)encryptWithKey:(NSData *)key saltLength:(size_t)saltLength
{
    if( saltLength == 0 ) {
        return [self encryptWithKey:key];
    }
    NSMutableData *buf = [NSMutableData dataWithCapacity:self.length + saltLength];
    [buf appendData:self];
    [buf appendData:[NSData randomBytes:saltLength]];
    return [buf encryptWithKey:key];
}

// Decrypt the data, and then strip off the salt
-(NSMutableData *)decryptWithKey:(NSData *)key saltLength:(size_t)saltLength
{
    NSMutableData *decrypted = [self decryptWithKey:key];
    if( decrypted ) {
        if( saltLength > decrypted.length ) {
            NSAssert( decrypted.length >= saltLength, @"Not enough data" );
            return nil;
        }
        if( saltLength > 0 ) {
            decrypted.length -= saltLength;
        }
    } else {
        NSLog(@"decryptWithKey: Decryption failted");
    }
    return decrypted;
}

@end
