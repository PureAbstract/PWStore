#if !TARGET_OS_IPHONE

#import <unistd.h>
#import <errno.h>
#import <sys/fcntl.h>
#import "OSX_SecRandom.h"

const SecRandomRef kSecRandomDefault = NULL;

int SecRandomCopyBytes( SecRandomRef rnd, size_t count, uint8_t *bytes )
{
    if( count == 0 )
        return 0;

    int fd = open("/dev/urandom",O_RDONLY);
    if( fd < 0 ) {
        return -1;
    }
  
    size_t bytesRead;
    uint8_t *p = bytes;
  
    do {
        bytesRead = read( fd, p, count - ( p -bytes ) );
        if( bytesRead > 0 ) {
            p += bytesRead;
        }
    } while( bytesRead > 0 || ( bytesRead < 0 && errno == EINTR ) );
    close( fd );
  
    return bytesRead < 0 ? -1 : 0;
}
#endif
