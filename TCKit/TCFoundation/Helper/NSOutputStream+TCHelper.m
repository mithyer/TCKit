//
//  NSOutputStream+TCHelper.m
//  TCFoundation
//
//  Created by cdk on 2017/12/15.
//  Copyright © 2017年 PixelCyber. All rights reserved.
//

#import "NSOutputStream+TCHelper.h"

@implementation NSOutputStream (TCHelper)

- (NSInteger)syncWrite:(const uint8_t *)buffer length:(NSUInteger)len
{
    NSUInteger size = len;
    NSUInteger writedSize = 0;
    do {
        NSInteger wSize = [self write:buffer+writedSize maxLength:size];
        if (wSize > 0) {
            writedSize += (NSUInteger)wSize;
            size -= (NSUInteger)wSize;
        }
        if (size < 1 || (wSize < 1 && !self.hasSpaceAvailable)) {
            return (NSInteger)writedSize;
        }
    } while (true);
}

@end
