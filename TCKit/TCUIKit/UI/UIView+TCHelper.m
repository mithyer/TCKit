//
//  UIView+TCHelper.m
//  TCKit
//
//  Created by cdk on 15/5/12.
//  Copyright (c) 2015年 TCKit. All rights reserved.
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

@implementation UISearchBar (TCHelper)

- (nullable __kindof UITextField *)tc_textField
{
    if (@available(iOS 13, *)) {
        return self.searchTextField;
    }
    
    UITextField *searchTf = nil;
    for (__kindof UIView *subView in self.subviews) {
        if ([subView isKindOfClass:UITextField.class]) {
            searchTf = subView;
            break;
        }
    }
    
    if (nil == searchTf) {
        for (UIView *subView in self.subviews) {
            for (__kindof UIView *subView2 in subView.subviews) {
                if ([subView2 isKindOfClass:UITextField.class]) {
                    searchTf = subView2;
                    break;
                }
                
                if (nil != searchTf) {
                    break;
                }
            }
        }
    }
    return searchTf;
}

@end

@implementation UITableView (TCFixLayoutMargin)

+ (void)load
{
    [self tc_swizzle:@selector(initWithFrame:style:)];
}

- (instancetype)tc_initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    UITableView *tableView = [self tc_initWithFrame:frame style:style];
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    return tableView;
}

@end


#endif
