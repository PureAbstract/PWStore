
#import "NSCompoundStream.h"


@implementation NSCompoundStream
-(id)init
{
    self = [super init];
    if( self ) {
        streams_ = [NSMutableArray new];
        status_ = NSStreamStatusNotOpen;
    }
    return self;
}

-(void)dealloc
{
    [self close];
    [streams_ release];
    [super dealloc];
}

-(void)appendStream:(NSInputStream*)stream
{
    [streams_ addObject:stream];
}

#pragma mark -
#pragma mark NSStream
-(void)open
{
    if( status_ == NSStreamStatusNotOpen ) {
        status_ = NSStreamStatusOpen;
    }
}

-(void)close
{
    status_ = NSStreamStatusClosed;
    for( NSInputStream *stream in streams_ ) {
        [stream close];
    }
    [streams_ removeAllObjects];
}

-(NSStreamStatus)streamStatus
{
    return status_;
}

-(NSError *)streamError
{
    return nil;
}
#pragma mark -
#pragma mark NSInputStream
// reads up to length bytes into the supplied buffer, which must be at least of size len. Returns the actual number of bytes read.
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    if( !len ) {
        // Nothing to do
        return 0;
    }
    NSAssert( buffer, @"Null buffer" );
    NSInteger remaining = len;
    while( remaining > 0 ) {
        if( !streams_.count ) {
            // No more streams
            status_ = NSStreamStatusAtEnd;
            break;
        }
        NSInputStream *stream = [streams_ objectAtIndex:0];
        NSInteger read = [stream read:buffer maxLength:remaining];
        if( read < 0 ) {
            // Stream error
            status_ = NSStreamStatusError;
            return read;
        }
        if( read == 0 ) {
            // Assume it's the end of stream
            [streams_ removeObjectAtIndex:0];
            continue;
        }
        remaining -= read;
        buffer += read;
    }
    return len - remaining;
}
// returns in O(1) a pointer to the buffer in 'buffer' and by
// reference in 'len' how many bytes are available. This buffer is
// only valid until the next stream operation. Subclassers may return
// NO for this if it is not appropriate for the stream type. This may
// return NO if the buffer is not available.
- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
#pragma unused(buffer)
#pragma unused(len)
    return NO;
}

// returns YES if the stream has bytes available or if it impossible
// to tell without actually doing the read.
-(BOOL)hasBytesAvailable
{
    // Save the fancy stuff for later...
    return streams_.count > 0;
}

@end
