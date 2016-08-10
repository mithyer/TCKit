//
//  UIImage+TCHelper.h
//  TCKit
//
//  Created by cdk on 15/5/13.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TCHelper)

// main bundle
+ (instancetype)imageWithContentsOfName:(NSString *)name;
+ (instancetype)imageWithContentsOfName:(NSString *)name inBundle:(NSBundle *)bundle;

+ (instancetype)launchImage;

- (instancetype)fitToScreenScale;



@end
