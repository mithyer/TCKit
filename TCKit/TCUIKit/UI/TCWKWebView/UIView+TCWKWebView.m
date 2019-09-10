//
//  UIView+TCWKWebView.m
//  TCKit
//
//  Created by dake on 16/7/27.
//  Copyright © 2016年 dake. All rights reserved.
//

#if !defined(TARGET_IS_EXTENSION) || defined(TARGET_IS_UI_EXTENSION)

#import "UIView+TCWKWebView.h"
#import <objc/runtime.h>
#import "TCWKWebView.h"

#import "UIWebView+TCWKWebView.h"
#import "WKWebView+TCWKWebView.h"


@implementation UIView (TCWKWebView)

+ (NSString *)tc_systemUserAgent
{
#ifdef __IPHONE_13_0
    return WKWebView.tc_systemUserAgent;
#else
    if (Nil != WKWebView.class) {
        return WKWebView.tc_systemUserAgent;
    }
    return UIWebView.tc_systemUserAgent;
#endif
}

- (NSURLRequest *)originalRequest
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setOriginalRequest:(NSURLRequest *)request
{
    objc_setAssociatedObject(self, @selector(originalRequest), request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#endif
