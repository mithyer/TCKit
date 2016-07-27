//
//  UIViewController+PopBackHandler.m
//
//  Created by dake on 10/4/15.
//  Copyright 2013 dake. All rights reserved.
//

#import "UIViewController+PopBackHandler.h"
#import <objc/runtime.h>

@implementation UINavigationController (TCPopBackHandler)

+ (void)load
{
    [self tc_swizzle:@selector(navigationBar:shouldPopItem:)];
    [self tc_swizzle:@selector(popViewControllerAnimated:)];
    [self tc_swizzle:@selector(popToViewController:animated:)];
    [self tc_swizzle:@selector(popToRootViewControllerAnimated:)];
}


#pragma mark - UINavigationBarDelegate

- (nullable UIViewController *)tc_popViewControllerAnimated:(BOOL)animated
{
    UIViewController *vc = self.topViewController;
    [vc.view endEditing:YES];
    if ([vc respondsToSelector:@selector(tc_navigationWillPopBackController)]) {
        [vc tc_navigationWillPopBackController];
    }
    return [self tc_popViewControllerAnimated:animated];
}

- (nullable NSArray<__kindof UIViewController *> *)tc_popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIViewController *vc = self.topViewController;
    [vc.view endEditing:YES];
    if ([vc respondsToSelector:@selector(tc_navigationWillPopBackController)]) {
        [vc tc_navigationWillPopBackController];
    }
    
    return [self tc_popToViewController:viewController animated:animated];
}

- (nullable NSArray<__kindof UIViewController *> *)tc_popToRootViewControllerAnimated:(BOOL)animated
{
    UIViewController *vc = self.topViewController;
    [vc.view endEditing:YES];
    if ([vc respondsToSelector:@selector(tc_navigationWillPopBackController)]) {
        [vc tc_navigationWillPopBackController];
    }
    
    return [self tc_popToRootViewControllerAnimated:animated];
}


- (BOOL)tc_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    BOOL shouldPop = YES;
    // normal pop
    if (self.viewControllers.count != navigationBar.items.count) {
        return [self tc_navigationBar:navigationBar shouldPopItem:item];
    }
    
    UIViewController *vc = self.topViewController;
    if ([vc respondsToSelector:@selector(tc_navigationShouldPopOnBackButton)]) {
        shouldPop = [vc tc_navigationShouldPopOnBackButton];
    }
    
    if (shouldPop) {
        return [self tc_navigationBar:navigationBar shouldPopItem:item];
    } else {
        // Workaround for iOS7.1 and iOS9.2. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        NSArray *subviews = [navigationBar.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"alpha < 1.0"]];
        
        if (subviews.count > 0) {
            [UIView animateWithDuration:0.25f animations:^{
                [subviews setValue:@1.0f forKeyPath:@"alpha"];
            }];
        }
    }
    
    return shouldPop;
}


#ifndef __TCKit__
#pragma mark - helper

+ (BOOL)tc_swizzle:(SEL)aSelector
{
    Method m1 = class_getInstanceMethod(self, aSelector);
    if (NULL == m1) {
        return NO;
    }
    
    SEL bSelector = NSSelectorFromString([NSString stringWithFormat:@"tc_%@", NSStringFromSelector(aSelector)]);
    Method m2 = class_getInstanceMethod(self, bSelector);
    
    if (class_addMethod(self, aSelector, method_getImplementation(m2), method_getTypeEncoding(m2))) {
        class_replaceMethod(self, bSelector, method_getImplementation(m1), method_getTypeEncoding(m1));
    } else {
        method_exchangeImplementations(m1, m2);
    }
    
    return YES;
}
#endif

@end
