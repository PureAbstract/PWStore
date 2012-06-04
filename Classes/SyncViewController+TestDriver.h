//
//  SyncViewController+TestDriver.h
//  PWStore
//
//  Created by Andy Sawyer on 04/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncViewController.h"

@class PWData;
@interface SyncViewController (TestDriver)
-(PWData *)getRootData;
-(void)testXmlImport;
-(void)testXmlExport;
@end
