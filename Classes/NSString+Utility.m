//
//  NSString+Utility.m
//  PWStore
//
//  Created by Andy Sawyer on 30/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Utility.h"


@implementation NSString (Utility)
-(NSData *)asDataUTF8
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

@end
