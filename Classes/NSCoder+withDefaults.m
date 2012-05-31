//
//  NSCoder+withDefaults.m
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import "NSCoder+withDefaults.h"


@implementation NSCoder (withDefaults)
-(id)objectOfType:(Class)clas forKey:(NSString *)key
{
    id obj = [self decodeObjectForKey:key];
    if( !obj ) {
        NSLog(@"No object for key %@",key);
        return nil;
    }
    if( ![obj isKindOfClass:clas] ) {
        NSLog(@"Key %@ : Expected %@, got %@",key,clas,[obj class]);
        return nil;
    }
    return obj;
}

-(NSString *)stringForKey:(NSString *)key default:(NSString *)default_
{
    NSString *obj = (NSString *)[self objectOfType:[NSString class] forKey:key];
    if( obj ) {
        return obj;
    }
    return default_;
}

-(NSString *)stringForKey:(NSString *)key
{
    return [self stringForKey:key default:[NSString string]];
}

-(NSDate *)dateForKey:(NSString *)key
{
    NSDate *obj = (NSDate *)[self objectOfType:[NSDate class] forKey:key];
    if( obj ) {
        return obj;
    }
    return [NSDate date];
}

-(NSArray *)arrayForKey:(NSString *)key
{
    return (NSArray *)[self objectOfType:[NSArray class] forKey:key];
}


@end
