//
//  UIView+TCWKWebView.h
//  TCKit
//
//  Created by dake on 16/7/27.
//  Copyright © 2016年 dake. All rights reserved.
//

#if !defined(TARGET_IS_EXTENSION) || defined(TARGET_IS_UI_EXTENSION)

#import <UIKit/UIKit.h>

@interface UIView (TCWKWebView)

@property (nonatomic, strong) NSURLRequest *originalRequest;

+ (NSString *)tc_systemUserAgent;

@end

#endif
