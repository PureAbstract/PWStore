//
//  UIApplication+Utility.h
//  PWStore
//
//  Created by Andy Sawyer on 30/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import <Foundation/Foundation.h>


@interface UIApplication (Utility)
+(NSString *)directoryPath:(NSSearchPathDirectory)directory;
+(NSString *)documentsDirectory;
+(NSString *)cacheDirectory;

+(NSString *)documentPath:(NSString *)filename;

@end
