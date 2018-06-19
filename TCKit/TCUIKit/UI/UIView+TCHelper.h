//
//  UIView+TCHelper.h
//  SudiyiClient
//
//  Created by cdk on 15/5/12.
//  Copyright (c) 2015年 Sudiyi. All rights reserved.
//

#if !defined(TARGET_IS_EXTENSION) || defined(TARGET_IS_UI_EXTENSION)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (TCHelper)

+ (CGFloat)pointWithPixel:(NSUInteger)pixel;

- (void)setAlignmentRectInsets:(UIEdgeInsets)alignmentRectInsets;

- (nullable UIViewController *)nearestController;

@end

@interface UISearchBar (TCHelper)

- (nullable __kindof UITextField *)tc_textField;

@end

NS_ASSUME_NONNULL_END


#endif
