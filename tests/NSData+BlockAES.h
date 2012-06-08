
#import <Foundation/NSData.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSData (BlockAES)
-(NSData *)blockEncrypt:(NSData *)key;
-(NSData *)blockDecrypt:(NSData *)key;
@end
