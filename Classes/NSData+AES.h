//
//  NSData+AES.h
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import <Foundation/Foundation.h>


@interface NSData (AES)
//
// Note that all these funtions return NSMutableData (vs NSData).
// This is primarily so they can be wiped after use if necessary
+(NSMutableData *)randomBytes:(size_t)length;

// These are though
-(NSMutableData *)encryptWithKey:(NSData *)key;
-(NSMutableData *)decryptWithKey:(NSData *)key;
// As above, but add 'length' bytes of random salt
-(NSMutableData *)encryptWithKey:(NSData *)key saltLength:(size_t)length;
// Decrypt and remove salt.
-(NSMutableData *)decryptWithKey:(NSData *)key saltLength:(size_t)length;

@end

@interface NSMutableData (AES)
// NOTE: These fill with self.length bytes.
// Fill with zeros
-(void)wipeZero;
// Fill with random data
-(void)wipeRandom;
@end
