//
//  UIApplication+TCHelper.m
//  TCKit
//
//  Created by dake on 16/9/28.
//  Copyright © 2016年 dake. All rights reserved.
//

#ifndef TARGET_IS_EXTENSION

#import "UIApplication+TCHelper.h"
#import <objc/runtime.h>


NSString *const kTCUIApplicationDelegateChangedNotification = @"TCUIApplicationDelegateChangedNotification";

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation UIApplication (TCHelper)

+ (void)load
{
    SEL sel = @selector(openURL:options:completionHandler:);
    if (![self instancesRespondToSelector:@selector(openURL:options:completionHandler:)]) {
        IMP handler = imp_implementationWithBlock(^(UIApplication *app, NSURL *url, NSDictionary<NSString *, id> *options, void (^ __nullable completion)(BOOL success)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
            BOOL ret = [app openURL:url];
#pragma clang diagnostic pop
            if (nil != completion) {
                if (NSThread.isMainThread) {
                    completion(ret);
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(ret);
                    });
                }
            }
        });
        
        if (!class_addMethod(self, sel, handler, method_getTypeEncoding(class_getInstanceMethod(self, sel)))) {
            NSAssert(false, @"add %@ failed", NSStringFromSelector(sel));
        }
    }
    
    [self tc_swizzle:@selector(setDelegate:)];
}

#pragma clang diagnostic pop

- (void)tc_setDelegate:(id<UIApplicationDelegate>)delegate
{
    [self tc_setDelegate:delegate];
    
    if (nil != delegate) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSNotificationCenter.defaultCenter postNotificationName:kTCUIApplicationDelegateChangedNotification object:delegate];
        });
    }
}

@end

#endif
