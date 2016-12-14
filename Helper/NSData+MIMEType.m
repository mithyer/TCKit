//
//  NSData+MIMEType.m
//  Thor
//
//  Created by cdk on 16/12/14.
//  Copyright © 2016年 PixelCyber. All rights reserved.
//

#import "NSData+MIMEType.h"


typedef struct _TCMIMETypes {
    uint8_t *sign;
    int len;
    __unsafe_unretained NSString *type;
} _TCMIMETypes;

#define BYTE_ARRY(...) (uint8_t[]){__VA_ARGS__}
#define MIME_ELEM(value, type) {value, sizeof(value), type}


// https://en.wikipedia.org/wiki/List_of_file_signatures
// http://www.iana.org/assignments/media-types/media-types.xhtml

// https://github.com/aidansteele/MagicKit

static _TCMIMETypes s_types[] = {
    MIME_ELEM(BYTE_ARRY('B', 'M'), @"image/x-ms-bmp"),
    MIME_ELEM(BYTE_ARRY('G', 'I', 'F'), @"image/gif"),
    MIME_ELEM(BYTE_ARRY(0xff, 0xd8, 0xff), @"image/jpeg"),
    MIME_ELEM(BYTE_ARRY('8', 'B', 'P', 'S'), @"image/psd"),
    MIME_ELEM(BYTE_ARRY('F', 'O', 'R', 'M'), @"image/iff"),
    MIME_ELEM(BYTE_ARRY('R', 'I', 'F', 'F'), @"image/webp"),
    MIME_ELEM(BYTE_ARRY(0x00, 0x00, 0x01, 0x00), @"image/vnd.microsoft.icon"),
    MIME_ELEM(BYTE_ARRY('I','I', 0x2A, 0x00), @"image/tiff"),
    MIME_ELEM(BYTE_ARRY('M','M', 0x00, 0x2A), @"image/tiff"),
    MIME_ELEM(BYTE_ARRY(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a), @"image/png"),
    MIME_ELEM(BYTE_ARRY(0x00, 0x00, 0x00, 0x0c, 0x6a, 0x50, 0x20, 0x20, 0x0d, 0x0a, 0x87, 0x0a), @"image/jp2"),
    
    MIME_ELEM(BYTE_ARRY(0x52, 0x61, 0x72, 0x1a, 0x07, 0x00), @"application/vnd.rar"),
    MIME_ELEM(BYTE_ARRY(0x52, 0x61, 0x72, 0x1a, 0x07, 0x01, 0x00), @"application/vnd.rar"),
    MIME_ELEM(BYTE_ARRY(0x25, 0x50, 0x44, 0x46), @"application/pdf"),
    
    
    MIME_ELEM(BYTE_ARRY(0x66, 0x74, 0x79, 0x70, 0x33, 0x67), @"audio/3gpp"),

    MIME_ELEM(BYTE_ARRY(0x50, 0x4b, 0x03, 0x04), @"application/zip"),
    MIME_ELEM(BYTE_ARRY(0x50, 0x4b, 0x05, 0x06), @"application/zip"),
    MIME_ELEM(BYTE_ARRY(0x50, 0x4b, 0x07, 0x08), @"application/zip"),
};

@implementation NSData (MIMEType)

- (nullable NSString *)MIMEType
{
    uint8_t bytes[12] = {0};
    [self getBytes:&bytes length:12];
    
    for (NSInteger i = 0; i < sizeof(s_types)/sizeof(s_types[0]); ++i) {
        _TCMIMETypes mime = s_types[i];
        if (0 == memcmp(bytes, mime.sign, mime.len)) {
            return mime.type;
        }
    }
    
    return @"application/octet-stream"; // default type
}

@end
