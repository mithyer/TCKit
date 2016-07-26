//
//  UIWebView+TCWKWebView.m
//  TCKit
//
//  Created by jia on 16/2/29.
//  Copyright © 2016年 dake. All rights reserved.
//

#import "UIWebView+TCWKWebView.h"
#import <objc/runtime.h>

@implementation UIWebView (TCWKWebView)

@dynamic webHeaderView;
@dynamic originalRequest;
@dynamic reloadOriRequestEnterForeground;


+ (void)load
{
    [self tc_swizzle:@selector(loadRequest:)];
    [self tc_swizzle:NSSelectorFromString(@"dealloc")];
}

- (void)tc_dealloc
{
    self.enterForgrdObsvr = nil;
}

- (void)setDelegateViews:(id<UIWebViewDelegate>)delegateView
{
    self.delegate = delegateView;
}

- (void)clearCookies
{
    for (NSHTTPCookie *cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
        NSRange domainRange = [cookie.domain rangeOfString:self.request.URL.host];
        if (domainRange.location != NSNotFound) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    NSString *string = [self stringByEvaluatingJavaScriptFromString:javaScriptString];
    
    if (nil != completionHandler) {
        completionHandler(string, nil);
    }
}

- (NSURLRequest *)originalRequest
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setOriginalRequest:(NSURLRequest *)request
{
    objc_setAssociatedObject(self, @selector(originalRequest), request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)tc_loadRequest:(NSURLRequest *)request
{
    self.originalRequest = request;
    [self tc_loadRequest:request];
}


- (id)enterForgrdObsvr
{
    return [self bk_associatedValueForKey:_cmd];
}

- (void)setEnterForgrdObsvr:(id)obsvr
{
    id oldObsvr = self.enterForgrdObsvr;
    if (nil != oldObsvr) {
        [[NSNotificationCenter defaultCenter] removeObserver:oldObsvr];
    }
    
    [self bk_weaklyAssociateValue:obsvr withKey:@selector(enterForgrdObsvr)];
}

- (BOOL)reloadOriRequestEnterForeground
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setReloadOriRequestEnterForeground:(BOOL)reload
{
    if (reload) {
        if (nil == self.enterForgrdObsvr) {
            __weak typeof(self) wSelf = self;
            self.enterForgrdObsvr = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
                [wSelf loadRequest:wSelf.originalRequest];
            }];
        }
    } else {
        self.enterForgrdObsvr = nil;
    }
    objc_setAssociatedObject(self, @selector(reloadOriRequestEnterForeground), @(reload), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark -


- (UIView *)webHeaderView
{
    return [self bk_associatedValueForKey:_cmd];
}

- (void)setWebHeaderView:(UIView *)webHeaderView
{
    BOOL needResetTopInsets = NO;
    UIScrollView *scrollView = self.scrollView;
    
    UIView *headerView = self.webHeaderView;
    if (nil == headerView) {
        if (nil != webHeaderView) {
            needResetTopInsets = YES;
            headerView = webHeaderView;
        }
    } else {
        needResetTopInsets = YES;
        
        if (headerView != webHeaderView) {
            needResetTopInsets = YES;
            [headerView removeFromSuperview];
            headerView = webHeaderView;
        } else if (nil == webHeaderView) {
            [self bk_weaklyAssociateValue:nil withKey:@selector(webHeaderView)];
        }
    }
    
    CGRect frame = CGRectZero;
    if (nil != headerView) {
        frame = headerView.frame;
        frame.origin = CGPointZero;
        headerView.frame = frame;
        
        if (headerView.superview == nil) {
            [scrollView addSubview:headerView];
            headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            [self bk_weaklyAssociateValue:headerView withKey:@selector(webHeaderView)];
        }
        
        NSParameterAssert(headerView.superview == scrollView);
    }
    
    if (needResetTopInsets) {
        for (UIView *subView in scrollView.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UIWebBrowserView")]) {
                CGRect rect = subView.frame;
                rect.origin.y = CGRectGetMaxY(frame);
                subView.frame = rect;
                break;
            }
        }
    }
}

@end
