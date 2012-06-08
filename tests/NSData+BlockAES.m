
#import "NSData+BlockAES.h"
#import "NSData+AES.h"
#import "NSData+CryptoHash.h"

@interface NSCryptor : NSObject {
    CCCryptorRef cryptor_;
}
@property (nonatomic,readonly) CCCryptorRef cryptor;
-(id)initWithCryptor:(CCCryptorRef)cryptor;
+(id)cryptorWithCryptor:(CCCryptorRef)cryptor;
@end

@implementation NSCryptor
@synthesize cryptor = cryptor_;
-(id)initWithCryptor:(CCCryptorRef)cryptor
{
    NSAssert( cryptor, @"Creat with NULL CCCryptorRef");
    self = [super init];
    if( self ) {
        cryptor_ = cryptor;
    }
    return self;
}

+(id)cryptorWithCryptor:(CCCryptorRef)cryptor
{
    return [[[NSCryptor alloc] initWithCryptor:cryptor] autorelease];
}

-(void)dealloc {
    if( cryptor_ ) {
        CCCryptorRelease( cryptor_ );
    }
    [super dealloc];
}
@end

@implementation NSData (BlockAES)

static BOOL streamWrite( NSOutputStream *stream, const uint8_t *bytes, NSUInteger length, NSError **error )
{
    assert( error );
    *error = nil;
    assert( stream );
    assert( bytes );
    if( length == 0 ) {
        return YES;
    }
    NSInteger written = [stream write:bytes maxLength:length];
    if( written < 0 ) {
        NSLog(@"streamWrite: error, status %d, error %@",stream.streamStatus,stream.streamError);
        *error = stream.streamError;
        return NO;
    }
    if( written == length ) {
        return YES;
    }
    // FIXME: Propbably ought to retry somehow?
    NSLog(@"streamWrite: Wrote %d of %d",written,length);
    *error = stream.streamError;
    return NO;
}

static BOOL streamCrypt( CCOperation operation, NSData *key, NSData *iv, NSInputStream *input, NSOutputStream *output, NSError **error )
{
    NSError *err = 0;
    CCCryptorRef cryptor = NULL;
    BOOL rv = NO;

    if( !error ) {
        NSLog(@"streamCrypt: Warning - NULL error");
    }
    *error = nil;
    if( !key ) {
        NSLog(@"streamCrypt: NULL key");
        goto cleanup;
    }
    if( !input ) {
        NSLog(@"streamCrypt: NULL input" );
        goto cleanup;
    }
    if( !output ) {
        NSLog(@"streamCrypt: NULL output" );
        goto cleanup;
    }

    if( key.length != kCCKeySizeAES256 ) {
        NSLog(@"streamCrypt: key length is %d - need %d; using hash",key.length,kCCKeySizeAES256);
        key = [key sha256];
    }
    assert( key.length == kCCKeySizeAES256 );

    // TODO: Check this...
    if( iv && iv.length != kCCBlockSizeAES128 ) {
        NSLog(@"streamCrypt: incorrect iv length %d, expected %d",iv.length,kCCBlockSizeAES128);
        goto cleanup;
    }

    CCCryptorStatus status = CCCryptorCreate( operation,
                                              kCCAlgorithmAES128,
                                              kCCOptionPKCS7Padding,
                                              key.bytes,
                                              key.length,
                                              ( iv ? iv.bytes : NULL ),
                                              &cryptor );
    if( kCCSuccess != status ) {
        NSLog(@"streamCrypt: CCCryptorCreate failed : %d",status);
        goto cleanup;
    }
    if( !cryptor ) {
        NSLog(@"streamCrypt: CCCryptorCreate NULL cryptor");
        goto cleanup;
    }


    while( YES ) {
        uint8_t inBuffer[kCCBlockSizeAES128];
        uint8_t outBuffer[kCCBlockSizeAES128*2];
        NSInteger read = [input read:inBuffer maxLength:sizeof(inBuffer)];
        if( read < 0 ) {
            err = input.streamError;
            NSLog(@"streamCrypt: Input Stram Read Error - status %d, error %@",input.streamStatus,err);
            goto cleanup;
        }
        if( read > 0 ) {
            size_t outSize = 0;
            status = CCCryptorUpdate( cryptor,
                                      inBuffer,
                                      read,
                                      outBuffer,
                                      sizeof(outBuffer),
                                      &outSize );
            if( kCCSuccess != status ) {
                NSLog(@"streamCrypt: CCCryptorUpdate returns %d",status);
                goto cleanup;
            }
            if( !streamWrite( output, outBuffer, outSize, &err ) ) {
                NSLog(@"streamCrypt: streamWrite failed");
                goto cleanup;
            }
            continue;
        }
        if( read == 0 ) {
            // End of stream
            size_t outSize = 0;
            status = CCCryptorFinal( cryptor,
                                     outBuffer,
                                     sizeof(outBuffer),
                                     &outSize);
            if( kCCSuccess != status ) {
                NSLog(@"streamCrypt: CCCryptorFinal returns %d",status);
                goto cleanup;
            }
            if( !streamWrite( output, outBuffer, outSize, &err ) ) {
                NSLog(@"streamCrypt: streamWrite failed");
                goto cleanup;
            }
            // All done.
            rv = YES;
            break;
        }
    }

 cleanup:
    if( cryptor ) {
        CCCryptorRelease( cryptor );
    }
    if( error ) {
        *error = err;
    }
    return rv;
}

static NSMutableData *blockCrypt( NSData *self, CCOperation operation, NSData *key )
{
    NSLog(@"kCCBlockSizeAES128 %d",kCCBlockSizeAES128);
    if( key.length != kCCKeySizeAES256 ) {
        key = [key sha256];
    }
    assert( key.length == kCCKeySizeAES256 );
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = CCCryptorCreate( operation,
                                              kCCAlgorithmAES128,
                                              kCCOptionPKCS7Padding,
                                              key.bytes,
                                              key.length,
                                              NULL, // Init. Vector
                                              &cryptor );
    if( status != kCCSuccess ) {
        NSLog(@"CCCryptorCreate returns %d",status);
        return nil;
    }
    if( !cryptor ) {
        NSLog(@"CCCryptorCreate NULL cryptor");
        return nil;
    }
    // ugh...
    uint8_t buf[kCCBlockSizeAES128*2];
    size_t dataOut = 0;
    NSMutableData *output = [[NSMutableData new] initWithCapacity:self.length+kCCBlockSizeAES128];
    NSUInteger i = 0;
    for( i = 0 ; i < self.length ; ++i ) {
        uint8_t byte = ((const uint8_t *)self.bytes)[i];
        dataOut = 0;
        status = CCCryptorUpdate( cryptor,
                                  &byte,
                                  1,
                                  buf,
                                  sizeof(buf),
                                  &dataOut );
        if( status != kCCSuccess ) {
            NSLog(@"CCCryptorUpdate returns %d",status);
            CCCryptorRelease( cryptor );
            return nil;
        }
        if( dataOut > 0 ) {
            [output appendBytes:buf length:dataOut];
        }
    }
    dataOut = 0;
    status = CCCryptorFinal( cryptor,
                             buf,
                             sizeof(buf),
                             &dataOut );
    CCCryptorRelease( cryptor );
    if( status != kCCSuccess ) {
        NSLog(@"CCCryptorFinal returns %d",status);
        return nil;
    }
    if( dataOut > 0 ) {
        NSLog(@"Final Append:%d",dataOut);
        [output appendBytes:buf length:dataOut];
    }
    return output;
}
-(NSData *)blockEncrypt:(NSData *)key
{
    return blockCrypt( self, kCCEncrypt, key );
}
-(NSData *)blockDecrypt:(NSData *)key
{
    return blockCrypt( self, kCCDecrypt, key );
}
@end

