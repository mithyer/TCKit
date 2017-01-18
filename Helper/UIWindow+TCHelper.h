//
//  UIWindow+TCHelper.h
//  TCKit
//
//  Created by dake on 15-7-29.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#ifndef TARGET_IS_EXTENSION

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (TCHelper)

+ (nullable UIViewController *)keyWindowTopController;

- (nullable UIViewController *)topMostViewController;

#ifdef __IPHONE_7_0
- (nullable UIViewController *)viewControllerForStatusBarStyle;
- (nullable UIViewController *)viewControllerForStatusBarHidden;
#endif

@end

NS_ASSUME_NONNULL_END

#endif

