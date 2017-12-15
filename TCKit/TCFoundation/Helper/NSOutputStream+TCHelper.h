//
//  NSOutputStream+TCHelper.h
//  TCFoundation
//
//  Created by cdk on 2017/12/15.
//  Copyright © 2017年 PixelCyber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOutputStream (TCHelper)

- (NSInteger)syncWrite:(const uint8_t *)buffer length:(NSUInteger)len;

@end
