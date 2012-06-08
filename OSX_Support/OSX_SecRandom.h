#if !TARGET_OS_IPHONE
#import <stdint.h>
#import <sys/types.h>
typedef const struct __SecRandom * SecRandomRef;
extern const SecRandomRef kSecRandomDefault;
int SecRandomCopyBytes( SecRandomRef rnd, size_t count, uint8_t *bytes );
#endif
