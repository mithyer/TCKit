//
//  UIImageView+TCHelper.h
//  TCKit
//
//  Created by dake on 2017/1/7.
//  Copyright © 2017年 dake. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (TCHelper)

+ (nullable instancetype)imageViewWithMode:(UIViewContentMode)mode image:(UIImage *)img insets:(UIEdgeInsets)insets;

@end

NS_ASSUME_NONNULL_END
