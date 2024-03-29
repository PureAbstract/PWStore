//
//  NSData+AES.m
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import "NSData+AES.h"
#import "NSData+CryptoHash.h"
#import <CommonCrypto/CommonCryptor.h>

#if !TARGET_OS_IPHONE
#import "OSX_SecRandom.h"
#endif

@implementation NSData (AES)
#pragma mark -
#pragma mark Random data generator
// see also 'wipeRandom'
+(NSMutableData *)randomBytes:(size_t)length
{
    NSMutableData *bytes = [NSMutableData dataWithLength:length];
    if( length > 0 ) {
        SecRandomCopyBytes( kSecRandomDefault, length, bytes.mutableBytes );
    }
    return bytes;
}

#pragma mark -
#pragma mark Internal: cryptOperation
-(NSMutableData *)cryptOperation:(CCOperation) operation
                         withKey:(NSData *)key
                      initVector:(NSData *)iv // init vector; may be NULL
{
    if( !key ) {
        NSAssert( key, @"Null key");
        return nil;
    }
    // Null init vector is ok
    if( iv && ( iv.length != kCCBlockSizeAES128 ) ) {
        NSLog(@"Init Vector too short (have %d, need %d)",iv.length,kCCBlockSizeAES128);
        return nil;
    }
    if( key.length != kCCKeySizeAES256 ) {
        // Key the wrong size, go hash with SHA256...
        key = [key sha256];
    }
    // This should never fail...
    NSAssert( key.length == kCCKeySizeAES256, @"Bad key size" );
    if( key.length != kCCKeySizeAES256 ) {
        return nil;
    }

    // Calculate the required output buffer size.
    // This may be slightly pessimistic, but AFAICT, the worst case is
    // we allocate an extra kCCBlockSizeAES128 (=16) bytes, which
    // isn't really a big deal.
    NSUInteger outputLen = (1+self.length/kCCBlockSizeAES128)*kCCBlockSizeAES128;
    NSMutableData *result = [NSMutableData dataWithLength:outputLen];
    size_t dataOut = 0;
    CCCryptorStatus status = CCCrypt( operation,
                                      kCCAlgorithmAES128,
                                      kCCOptionPKCS7Padding,
                                      key.bytes,
                                      key.length,
                                      ( iv ? iv.bytes : NULL ),
                                      self.bytes,
                                      self.length,
                                      result.mutableBytes,
                                      result.length,
                                      &dataOut );
    if( kCCSuccess != status ) {
        NSLog(@"CCCrypt error %d",status);
        result = nil;
    } else {
        NSAssert( dataOut <= result.length, @"Result buffer too short" );
        NSLog(@"CCCrypt : Allocated %d, Output was %d@", result.length, dataOut );
        result.length = dataOut;
    }
    return result;
}

#pragma mark -
#pragma mark encrypt/decrypt data with key
-(NSMutableData *)encryptWithKey:(NSData *)key
{
    return [self cryptOperation:kCCEncrypt
                        withKey:key
                     initVector:nil];
}

-(NSMutableData *)decryptWithKey:(NSData *)key
{
    return [self cryptOperation:kCCDecrypt
                        withKey:key
                     initVector:nil];
}

#pragma mark -
#pragma mark encrypt/decrypt data with key and salt
// Append some random salt, and then encrypt with key
// Note: We append rather than prepend, primarily so when we decrypt
// we can remve the salt by simple truncation, rather than by copying.
-(NSMutableData *)encryptWithKey:(NSData *)key saltLength:(size_t)saltLength
{
    if( saltLength == 0 ) {
        // Avoid the copy where we can
        return [self encryptWithKey:key];
    }
    NSMutableData *buf = [NSMutableData dataWithCapacity:self.length + saltLength];
    [buf appendData:self];
    [buf appendData:[NSData randomBytes:saltLength]];
    NSMutableData *enc = [buf encryptWithKey:key];
    // Wipe the buffer
    bzero( buf.mutableBytes, buf.length );
    return enc;
}

// Decrypt the data, and then strip off the salt
-(NSMutableData *)decryptWithKey:(NSData *)key saltLength:(size_t)saltLength
{
    NSMutableData *decrypted = [self decryptWithKey:key];
    if( !decrypted ) {
        NSLog(@"decryptWithKey: Decryption failted");
        return nil;
    }

    if( saltLength > decrypted.length ) {
        NSAssert( decrypted.length >= saltLength, @"Not enough data to strip salt" );
        bzero( decrypted.mutableBytes, decrypted.length );
        return nil;
    }

    if( saltLength > 0 ) {
        // Paranoia: zero the salt.
        uint8_t *ptr =(uint8_t *)decrypted.mutableBytes;
        ptr += decrypted.length - saltLength;
        bzero( ptr, saltLength );
        // And truncate the data
        decrypted.length -= saltLength;
    }

    return decrypted;
}

@end

@implementation NSMutableData (AES)
#pragma mark -
#pragma mark Zero fill data
-(void)wipeZero
{
    if( self.length ) {
        bzero( self.mutableBytes, self.length );
    }
}

#pragma mark -
#pragma mark Random fill data
-(void)wipeRandom
{
    if( self.length ) {
        SecRandomCopyBytes( kSecRandomDefault,
                            self.length,
                            self.mutableBytes );
    }
}
@end
