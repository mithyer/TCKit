//
//  UIImage+TCHelper.h
//  TCKit
//
//  Created by cdk on 15/5/13.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TCHelper)

// main bundle
+ (nullable instancetype)imageWithContentsOfName:(NSString *)name;
+ (nullable instancetype)imageWithContentsOfName:(NSString *)name inBundle:(NSBundle *__nullable)bundle;

+ (nullable instancetype)launchImage;

- (instancetype)fitToScreenScale;



@end

NS_ASSUME_NONNULL_END
