//
//  TCPopupContainer.h
//  TCKit
//
//  Created by dake on 14-9-4.
//  Copyright (c) 2014年 dake. All rights reserved.
//

#ifndef TARGET_IS_EXTENSION

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TCPopupStyle) {
    kTCPopupStyleCenter,
    kTCPopupStyleFromTop,
    kTCPopupStyleFade,
};

@interface TCPopupContainer : UIView

@property (nonatomic, assign) CGSize shownAreaSize; // default: CGSizeZero
@property (nonatomic, strong) UIViewController *shownCtrler;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, assign) TCPopupStyle presentStyle; // default: TCPopupStyleCenter
@property (nonatomic, assign) BOOL disableTouchOutSide; // default: NO
@property (nonatomic, assign) BOOL shouldShowCloseBtn; // default: YES, only for TCPopupStyleCenter
@property (nonatomic, assign) BOOL shouldFlexContainerWidth; // default: NO, only for kTCPopupStyleFromTop
@property (nonatomic, assign) BOOL allowCustomContainerRect; // default: NO
@property (nullable, nonatomic, copy) void(^dismissdBlock)(void);

@property (nullable, nonatomic, strong) UIColor *maskBackgroundColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;

+ (BOOL)anyContainerVisible;

// animated YES
- (void)show;
- (void)dismiss;

- (void)show:(BOOL)animated;
- (void)dismiss:(BOOL)animated;

- (BOOL)isVisible;

- (nullable UIImage *)closeImageForState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END

#endif
