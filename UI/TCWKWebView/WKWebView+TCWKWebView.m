//
//  WKWebView+TCWKWebView.m
//  TCKit
//
//  Created by jia on 16/2/29.
//  Copyright © 2016年 dake. All rights reserved.
//

#import "WKWebView+TCWKWebView.h"
#import <objc/runtime.h>

@implementation WKWebView (TCWKWebView)

@dynamic scalesPageToFit;
//@dynamic dataDetectorTypes;
@dynamic delegate;
@dynamic webHeaderView;


+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self tc_swizzle:@selector(loadRequest:)];
        [self tc_swizzle:@selector(initWithFrame:configuration:)];
        [self tc_swizzle:NSSelectorFromString(@"dealloc")];
    });
}

- (void)tc_dealloc
{
    for (UIView *subView in self.kvoSubviews) {
        [subView removeObserver:self forKeyPath:PropertySTR(frame)];
    }
}

- (instancetype)tc_initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration
{
    [self tc_initWithFrame:frame configuration:configuration];
    if (self) {
        self.kvoSubviews = self.scrollView.subviews.copy;
        for (UIView *subView in self.kvoSubviews) {
            [subView addObserver:self forKeyPath:PropertySTR(frame) options:NSKeyValueObservingOptionNew context:NULL];
        }
    }
    return self;
}

- (id<WKNavigationDelegate, WKUIDelegate>)delegate
{
    id delegate = self.navigationDelegate ?: (id)self.UIDelegate;
    return (id<WKNavigationDelegate, WKUIDelegate>)delegate;
}

- (void)setDelegate:(id<WKNavigationDelegate, WKUIDelegate>)delegate
{
    self.navigationDelegate = delegate;
    self.UIDelegate = delegate;
}

- (BOOL)scalesPageToFit
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setScalesPageToFit:(BOOL)scalesPageToFit
{
    if (scalesPageToFit == self.scalesPageToFit) {
        return;
    }
    
    static NSString *const jScript = @"var meta = document.createElement('meta'); \
    meta.name = 'viewport'; \
    meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
    var head = document.getElementsByTagName('head')[0];\
    head.appendChild(meta);";
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    
    if (scalesPageToFit) {
        [self.configuration.userContentController addUserScript:wkUScript];
    } else {
        NSMutableArray *userScripts = self.configuration.userContentController.userScripts.copy;
        NSInteger index = NSNotFound;
        for (WKUserScript *script in userScripts) {
            if ([script.source isEqualToString:jScript]) {
                index = [userScripts indexOfObject:script];
                break;
            }
        }
        
        if (index != NSNotFound) {
            [userScripts removeObjectAtIndex:index];
        }
        
        for (WKUserScript *script in userScripts) {
            [self.configuration.userContentController addUserScript:script];
        }
    }

    objc_setAssociatedObject(self, @selector(scalesPageToFit), @(scalesPageToFit), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURLRequest *)request
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRequest:(NSURLRequest *)request
{
    objc_setAssociatedObject(self, @selector(request), request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)tc_loadRequest:(NSURLRequest *)request
{
    self.request = request;
    [self tc_loadRequest:request];
}

/*
- (void)setDataDetectorTypes:(NSUInteger)dataDetectorTypes
{
    return;
}

- (NSUInteger)dataDetectorTypes
{
    return 0; // UIDataDetectorTypeNone
}
 */

- (void)clearCookies
{
    if (Nil != WKWebsiteDataStore.class) {
        WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
        [dateStore fetchDataRecordsOfTypes:WKWebsiteDataStore.allWebsiteDataTypes completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
            for (WKWebsiteDataRecord *record in records) {
                NSRange range = [record.displayName rangeOfString:self.request.URL.host];
                if (range.location != NSNotFound) {
                    [dateStore removeDataOfTypes:record.dataTypes
                                  forDataRecords:@[record]
                               completionHandler:^{
                                   DLog(@"Cookies for %@ deleted successfully",record.displayName);
                               }];
                }
            }
        }];
        
    } else {
        NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
        NSString *cookiesFolderPath = [libraryPath stringByAppendingPathComponent:@"Cookies"];
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:NULL];
    }
}



- (NSArray<__kindof UIView *> *)kvoSubviews
{
    return [self bk_associatedValueForKey:_cmd];
}

- (void)setKvoSubviews:(NSArray<__kindof UIView *> *)kvoSubviews
{
    [self bk_associateValue:kvoSubviews withKey:@selector(kvoSubviews)];
}

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
        CGFloat h = CGRectGetMaxY(frame);
        for (UIView *subView in self.kvoSubviews) {
            // bug fix for iOS8
            CGRect rect = subView.frame;
            if (CGRectGetMinY(rect) < h) {
                rect.origin.y = h;
                subView.frame = rect;
            }
        }
    }
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context
{
    if ([self.kvoSubviews containsObject:object] && [keyPath isEqualToString:PropertySTR(frame)]) { // bug fix for iOS9
        NSValue *value = change[NSKeyValueChangeNewKey];
        if ([value isKindOfClass:NSValue.class]) {
            CGRect frame = value.CGRectValue;
            CGFloat head = CGRectGetHeight(self.webHeaderView.frame);
            if (CGRectGetMinY(frame) < head) {
                frame.origin.y = head;
                ((UIView *)object).frame = frame;
            }
        }
    }
}

@end


@implementation UIScrollView (HeaderView)

+ (void)load
{
    if (Nil != WKWebView.class) {
        [self tc_swizzle:@selector(setContentSize:)];
    }
}

- (void)tc_setContentSize:(CGSize)contentSize
{
    if ([self isKindOfClass:NSClassFromString(@"WKScrollView")]) {
        
        CGFloat height = 0;
        for (UIView *view in self.subviews) {
            CGFloat h = CGRectGetMaxY(view.frame);
            if (h > height) {
                height = h;
            }
        }
        
        if (contentSize.height < height) {
            contentSize.height = height;
        }
    }
    
    [self tc_setContentSize:contentSize];
}

@end

