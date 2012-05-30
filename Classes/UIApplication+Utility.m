//
//  UIApplication+Utility.m
//  PWStore
//
//  Created by Andy Sawyer on 30/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import "UIApplication+Utility.h"


@implementation UIApplication (Utility)

+(NSString *)directoryPath:(NSSearchPathDirectory)directory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    NSAssert( paths != nil, @"nil Search Path" );
    NSAssert( paths.count > 0, @"empty Search Path" );
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+(NSString *)documentsDirectory
{
    return [self directoryPath:NSDocumentDirectory];
}

+(NSString *)cacheDirectory
{
    return [self directoryPath:NSCachesDirectory];
}

+(NSString *)documentPath:(NSString *)filename
{
    return [[self documentsDirectory] stringByAppendingPathComponent:filename];
}


@end
