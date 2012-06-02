//
//  PWItem+StringExport.m
//  PWStore
//
//  Created by Andy Sawyer on 02/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import "PWItem+StringExport.h"


@interface NSString (EscapeString)
-(NSString *)escapedString;
-(NSString *)unescapedString;
@end

@implementation NSString (EscapeString)

typedef struct {
    const unichar unescaped;
    const unichar escaped;
} escape_char_t;

static const escape_char_t escape_chars [] = {
    {  '\t', 't' },
    {  '\n', 'n' },
    {  '\\', '\\' },
    { 0, 0 },
};

static unichar find_escape( unichar unescaped )
{
    for( const escape_char_t *p = escape_chars ;
         p->unescaped ;
         ++p )
        {
            if( p->unescaped == unescaped ) {
                return p->escaped;
            }
        }
    return 0;
}

static unichar find_unescape( unichar escaped )
{
    for( const escape_char_t *p = escape_chars ;
         p->unescaped ;
         ++p )
        {
            if( p->escaped == escaped ) {
                return p->unescaped;
            }
        }
    return 0;
}


-(NSString *)escapedString
{
    // Chars we need to escape
    NSCharacterSet *escapeMe = [NSCharacterSet characterSetWithCharactersInString:@"\\\n\t"];
    if( [self rangeOfCharacterFromSet:escapeMe].length == 0 ) {
        return self;
    }
    NSUInteger l = self.length;
    unichar * const srcbfr = (unichar *)malloc((l+1)*sizeof(unichar));
    [self getCharacters:srcbfr range:NSMakeRange(0,l)];
    unichar * const dstbfr = (unichar *)malloc((l+1)*2*sizeof(unichar));
    unichar * dstptr = dstbfr;
    for( NSUInteger i = 0 ; i < l ; ++i ) {
        unichar ch = srcbfr[i];
        unichar esc = find_escape( ch );
        if( esc ) {
            *dstptr++ = '\\';
            ch = esc;
        }
        *dstptr++ = ch;
    }
    *dstptr = 0;
    NSString *rv = [NSString stringWithCharacters:dstbfr length:(dstptr-dstbfr)];
    free( dstbfr );
    free( srcbfr );
    return rv;
}

-(NSString *)unescapedString
{
    // Check to see if we need to unescape anything
    if( [self rangeOfString:@"\\"].length == 0 ) {
        // No, so don't bother...
        return self;
    }
    NSUInteger l = self.length;

    unichar * const src = (unichar *)malloc( (l+1) * sizeof(unichar) );
    [self getCharacters:src range:NSMakeRange(0,l)];
    src[l] = 0;
    unichar * const dst = (unichar *)malloc( (l+1) * sizeof(unichar) );
    unichar * dstptr = dst;
    for( NSUInteger i = 0 ; i < l ; ) {
        unichar ch = src[i++];
        if( ch != '\\' ) {
            *dstptr++ = ch;
            continue;
        }
        // Hokey. This may overrun the actual buffer, but will hit the
        // '0' we added, so we'll get away with it...
        ch = find_unescape( src[i++] );
        if( ch ) {
            *dstptr++ = ch;
        }
    }
    NSString *rv = [NSString stringWithCharacters:dst length:dstptr-dst];
    free( dst );
    free( src );
    return rv;
}
@end


@implementation PWItem (StringExport)
#pragma mark -
#pragma mark Import/Export
-(NSString *)asString
{
    NSMutableString *m = [NSMutableString string];
    [m appendFormat:@"%@\t",[self.title escapedString]];
    [m appendFormat:@"%@\t",[self.login escapedString]];
    [m appendFormat:@"%@\t",[self.password escapedString]];
    [m appendFormat:@"%@\t",[self.email escapedString]];
    [m appendFormat:@"%@\t",[self.url escapedString]];
    [m appendFormat:@"%@",[self.notes escapedString]];
    return m;
}

+(PWItem *)fromString:(NSString *)string
{
    NSArray *content = [string componentsSeparatedByString:@"\t"];
    if( content.count != 6 ) {
        NSLog(@"Too short");
        return nil;
    }
    PWItem *item = [[PWItem new] autorelease];
    item.title = [[content objectAtIndex:0] unescapedString];
    item.login = [[content objectAtIndex:1] unescapedString];
    item.password = [[content objectAtIndex:2] unescapedString];
    item.email = [[content objectAtIndex:3] unescapedString];
    item.url = [[content objectAtIndex:4] unescapedString];
    item.notes = [[content objectAtIndex:5] unescapedString];
    return item;
}
@end
