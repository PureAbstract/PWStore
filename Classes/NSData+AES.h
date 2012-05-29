//
//  NSData+AES.h
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import <Foundation/Foundation.h>


@interface NSData (AES)
-(NSMutableData *)encryptWithKey:(NSData *)key;
-(NSMutableData *)decryptWithKey:(NSData *)key;
-(NSMutableData *)encryptWithKey:(NSData *)key saltLength:(size_t)length;
-(NSMutableData *)decryptWithKey:(NSData *)key saltLength:(size_t)length;

@end
