//
//  PWItem+StringExport.h
//  PWStore
//
//  Created by Andy Sawyer on 02/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWItem.h"

@interface PWItem (StringExport)
-(NSString *)asString;
+(PWItem *)fromString:(NSString *)string;
@end
