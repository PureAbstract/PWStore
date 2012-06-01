//
//  PWItem.h
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import <Foundation/Foundation.h>

extern NSString * const kPWDataUpdated;

@interface PWItem : NSObject<NSCoding> {
    // Note: It may be a better plan to store these as an array,
    // with specified indices.
    NSString *title_;
    NSString *login_;
    NSString *password_;
    NSString *url_;
    NSString *email_;
    NSString *notes_;

    NSDate *_created;
    NSDate *_updated;
}
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *login;
@property (nonatomic,copy) NSString *password;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *email;
@property (nonatomic,copy) NSString *notes;
@property (nonatomic,retain) NSDate *created;
@property (nonatomic,retain) NSDate *updated;
@end
