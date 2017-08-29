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
#import "NSObject+TCUtilities.h"


NSString *const kTCUIApplicationDelegateChangedNotification = @"TCUIApplicationDelegateChangedNotification";

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation UIApplication (TCHelper)

+ (void)load
{
    SEL sel = @selector(openURL:options:completionHandler:);
    if (NULL == sel) {
        sel = NSSelectorFromString(@"openURL:options:completionHandler:");
    }
    Method m1 = class_getInstanceMethod(self, sel);
    
    if (NULL != sel && NULL == m1) {
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
        
        if (!class_addMethod(self, sel, handler, "v40@0:8@16@24@?32")) {
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


@implementation UIViewController (UIApplication)

+ (CGFloat)statusBarHeight
{
    // Landscape mode on iPad, UIApplication.sharedApplication.statusBarFrame.size.height is bigger, so we get the smaller
    CGSize size = UIApplication.sharedApplication.statusBarFrame.size;
    return MIN(size.width, size.height);
}

- (CGFloat)statusBarHeight
{
    return self.class.statusBarHeight;
}

@end


@implementation NSString (UIApplication)

- (void)phoneCall:(void(^)(BOOL success))complete
{
    BOOL ret = self.length > 1;
    if (ret) {
        NSURL *phoneNumber = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:self]];
        ret = [UIApplication.sharedApplication canOpenURL:phoneNumber];
        if (ret) {
            [UIApplication.sharedApplication openURL:phoneNumber options:@{} completionHandler:complete];
        }
    }
}

@end

#endif
