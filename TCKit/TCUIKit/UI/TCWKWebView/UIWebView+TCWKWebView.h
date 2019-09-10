//
//  UIWebView+TCWKWebView.h
//  TCKit
//
//  Created by jia on 16/2/29.
//  Copyright © 2016年 dake. All rights reserved.
//

#if !defined(__IPHONE_13_0) && (!defined(TARGET_IS_EXTENSION) || defined(TARGET_IS_UI_EXTENSION))

#import <UIKit/UIKit.h>
#import "TCWKWebView.h"

@interface UIWebView (TCWKWebView) <TCWKWebView>

@end

#endif
