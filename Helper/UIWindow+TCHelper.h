//
//  UIWindow+TCHelper.h
//  TCKit
//
//  Created by dake on 15-7-29.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#ifndef TARGET_IS_EXTENSION

#import <UIKit/UIKit.h>

@interface UIWindow (TCHelper)

+ (UIViewController *)keyWindowTopController;

- (UIViewController *)topMostViewController;

#ifdef __IPHONE_7_0
- (UIViewController *)viewControllerForStatusBarStyle;
- (UIViewController *)viewControllerForStatusBarHidden;
#endif

@end

#endif
