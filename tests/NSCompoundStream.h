
#import <Foundation/Foundation.h>

@interface NSCompoundStream : NSInputStream {
    NSMutableArray *streams_;
    NSStreamStatus status_;
}
-(id)init;
-(void)appendStream:(NSInputStream *)stream;
#pragma mark -
#pragma mark NSStream
-(NSStreamStatus)streamStatus;
@end
