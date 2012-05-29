//
//  NSCoder+withDefaults.h
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSCoder (withDefaults)
-(NSString *)stringForKey:(NSString *)key;
-(NSString *)stringForKey:(NSString *)key default:(NSString *)default_;
-(NSDate *)dateForKey:(NSString *)key;
@end
