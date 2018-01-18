//
//  TCECDSA.h
//  TCFoundation
//
//  Created by cdk on 2018/1/18.
//  Copyright © 2018年 PixelCyber. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCECDSA : NSObject

+ (nullable NSData *)signData:(NSData *)plainData withPrivateKey:(NSData *)p12Data passwd:(NSString *_Nullable)passwd;

@end

NS_ASSUME_NONNULL_END
