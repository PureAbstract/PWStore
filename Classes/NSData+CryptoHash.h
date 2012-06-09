//
//  NSData+CryptoHash.h
//  PWStore
//
// Hash functions for NSData objects
//
//  Created by Andy Sawyer on 09/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CryptoHash)
// Cryptographic Hash Functions Note that the returned objects are
// mutable so you can wipe them if you like
-(NSMutableData *)sha256;
-(NSMutableData *)sha1;
@end
