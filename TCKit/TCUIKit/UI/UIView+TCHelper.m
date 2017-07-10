//
//  UIView+TCHelper.m
//  SudiyiClient
//
//  Created by cdk on 15/5/12.
//  Copyright (c) 2015年 Sudiyi. All rights reserved.
//

#if !defined(TARGET_IS_EXTENSION) || defined(TARGET_IS_UI_EXTENSION)

#import "UIView+TCHelper.h"
#import <objc/runtime.h>
#import "NSObject+TCUtilities.h"


static char const kAlignmentRectInsetsKey;

@implementation UIView (TCHelper)

+ (void)load
{
    [self tc_swizzle:@selector(alignmentRectInsets)];
}

+ (CGFloat)pointWithPixel:(NSUInteger)pixel
{
    return pixel / UIScreen.mainScreen.scale;
}

- (UIEdgeInsets)tc_alignmentRectInsets
{
    NSValue *value = objc_getAssociatedObject(self, &kAlignmentRectInsetsKey);
    return nil != value ? value.UIEdgeInsetsValue : self.tc_alignmentRectInsets;
}

- (void)setAlignmentRectInsets:(UIEdgeInsets)alignmentRectInsets
{
    objc_setAssociatedObject(self, &kAlignmentRectInsetsKey, [NSValue valueWithUIEdgeInsets:alignmentRectInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//- (void)viewRoundedRect:(UIView *)itemView byConers:(UIRectCorner)corners
//{
//    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:itemView.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(7.0, 7.0)];
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame = itemView.bounds;
//    maskLayer.path = cornerPath.CGPath;
//    itemView.layer.mask = maskLayer;
//}

- (UIViewController *)nearestController
{
    UIResponder *responder = self.nextResponder;

    if ([responder isKindOfClass:UIViewController.class]) {
        return (UIViewController *)responder;
    }
    
    return ((UIView *)responder).nearestController;
}

@end

#endif
