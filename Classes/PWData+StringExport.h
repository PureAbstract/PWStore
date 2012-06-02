//
//  PWData+StringExport.h
//  PWStore
//
//  Created by Andy Sawyer on 02/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWData.h"

@interface PWData (StringExport)
-(NSString *)asString;
+(PWData *)fromString:(NSString *)string;
@end
