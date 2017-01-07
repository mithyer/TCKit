//
//  UIImageView+TCHelper.m
//  TCKit
//
//  Created by dake on 2017/1/7.
//  Copyright © 2017年 dake. All rights reserved.
//

#import "UIImageView+TCHelper.h"

@implementation UIImageView (TCHelper)

+ (instancetype)imageViewWithMode:(UIViewContentMode)mode image:(UIImage *)img insets:(UIEdgeInsets)insets
{
    if (nil == img) {
        return nil;
    }
    
    UIImageView *view = [[self alloc] initWithImage:img];
    view.contentMode = mode;
    [view sizeToFit];
    CGRect bounds = view.bounds;
    bounds.size.width += insets.left + insets.right;
    bounds.size.height += insets.top + insets.bottom;
    view.bounds = bounds;

    return view;
}

@end
