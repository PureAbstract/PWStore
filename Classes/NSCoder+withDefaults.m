//
//  NSCoder+withDefaults.m
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import "NSCoder+withDefaults.h"


@implementation NSCoder (withDefaults)
-(NSString *)stringForKey:(NSString *)key default:(NSString *)default_
{
    id obj = [self decodeObjectForKey:key];
    if( obj && [obj isKindOfClass:[NSString class]] ) {
        return (NSString *)obj;
    }
    return default_;
}

-(NSString *)stringForKey:(NSString *)key
{
    return [self stringForKey:key default:[NSString string]];
}

-(NSDate *)dateForKey:(NSString *)key
{
    id obj = [self decodeObjectForKey:key];
    if( obj && [obj isKindOfClass:[NSDate class]] ) {
        return (NSDate *)obj;
    }
    return [NSDate date];
}

@end
