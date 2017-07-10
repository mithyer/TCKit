//
//  TCAlertController.h
//  TCKit
//
//  Created by dake on 15/3/12.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#ifndef TARGET_IS_EXTENSION

#import <Foundation/Foundation.h>
#import "TCAlertAction.h"


typedef NS_ENUM(NSInteger, TCAlertControllerStyle) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    kTCAlertControllerStyleActionSheet = UIAlertControllerStyleActionSheet,
    kTCAlertControllerStyleAlert = UIAlertControllerStyleAlert,
#else
    kTCAlertControllerStyleActionSheet = 0,
    kTCAlertControllerStyleAlert,
#endif
};

NS_ASSUME_NONNULL_BEGIN

@interface TCAlertController : NSObject

@property (nonatomic, assign) TCAlertControllerStyle preferredStyle;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
@property (nullable, nonatomic, readonly) UIPopoverPresentationController *popoverPresentationController NS_AVAILABLE_IOS(8_0);
#endif

- (instancetype)initAlertViewWithTitle:(NSString *__nullable)title
                               message:(NSString *__nullable)message
                         presentCtrler:(UIViewController *__nullable)viewCtrler
                          cancelAction:(TCAlertAction *__nullable)cancelAction
                           otherAction:(TCAlertAction *__nullable)otherAction, ... NS_REQUIRES_NIL_TERMINATION;

- (instancetype)initActionSheetWithTitle:(NSString *__nullable)title
                           presentCtrler:(UIViewController *__nullable)viewCtrler
                            cancelAction:(TCAlertAction *__nullable)cancelAction
                       destructiveAction:(TCAlertAction *__nullable)destructiveAction
                             otherAction:(TCAlertAction *__nullable)otherAction, ... NS_REQUIRES_NIL_TERMINATION;

- (instancetype)initAlertViewWithTitle:(NSString *__nullable)title
                               message:(NSString *__nullable)message
                         presentCtrler:(UIViewController *__nullable)viewCtrler
                          cancelAction:(TCAlertAction *__nullable)cancelAction
                          otherActions:(NSArray *__nullable)otherActions;

- (instancetype)initActionSheetWithTitle:(NSString *__nullable)title
                           presentCtrler:(UIViewController *__nullable)viewCtrler
                            cancelAction:(TCAlertAction *__nullable)cancelAction
                       destructiveAction:(TCAlertAction *__nullable)destructiveAction
                            otherActions:(NSArray *__nullable)otherActions;

- (void)addAction:(TCAlertAction *)action;
- (void)show;

@end

NS_ASSUME_NONNULL_END

#endif
