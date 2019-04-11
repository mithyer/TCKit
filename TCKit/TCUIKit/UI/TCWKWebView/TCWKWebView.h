//
//  TCWKWebView.h
//  TCKit
//
//  Created by jia on 16/2/26.
//  Copyright © 2016年 dake. All rights reserved.
//

#if !defined(TARGET_IS_EXTENSION) || defined(TARGET_IS_UI_EXTENSION)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TCWKWebView <NSObject>

@required
@property (nonatomic, strong) NSURLRequest *originalRequest;
@property (nonatomic, assign) BOOL scalesPageToFit;
//@property (nonatomic, assign) UIDataDetectorTypes dataDetectorTypes;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, weak) id delegate;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
//@property (nonatomic, strong) UIView *webHeaderView;

+ (NSString *)tc_systemUserAgent;

- (void)loadRequest:(NSURLRequest *)request;
- (nullable id)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(nullable NSURL *)readAccessURL;
- (nullable id)tc_loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;

- (BOOL)canGoBack;
- (id)tc_goBack;
- (void)tc_reload;

- (void)stopLoading;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^_Nullable)(id _Nullable result, NSError *error))completionHandler;

// refer: http://www.jianshu.com/p/d2c478bbcca5?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io
- (void)clearCookies;

@end

NS_ASSUME_NONNULL_END

#endif
