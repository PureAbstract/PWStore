//
//  PWData+StringExport.m
//  PWStore
//
//  Created by Andy Sawyer on 02/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import "PWData+StringExport.h"
#import "PWItem+StringExport.h"

@implementation PWData (StringExport)
-(NSString *)asString
{
    NSMutableString *str = [NSMutableString string];
    for( PWItem *item in self ) {
        NSString *istr = [item asString];
        if( istr ) {
            [str appendFormat:@"%@\n",istr];
        }
    }
    return str;
}

+(PWData *)fromString:(NSString *)string
{
    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    PWData *data = [[PWData new] autorelease];
    for( NSString *line in lines ) {
        PWItem *item = [PWItem fromString:line];
        if( item ) {
            [data addObject:item];
        }
    }
    return data;
}

@end
