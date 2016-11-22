//
//  UILabel+TCHelper.m
//  TCKit
//
//  Created by dake on 15/3/10.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#if !defined(TARGET_IS_EXTENSION) || defined(TARGET_IS_UI_EXTENSION)

#import "UILabel+TCHelper.h"
#import <objc/runtime.h>
#import "NSObject+TCUtilities.h"

static char const kTextVerticalAlignmentKey;
static char const kContentEdgeInsetsKey;

@implementation UILabel (TCHelper)

@dynamic contentEdgeInsets;

+ (void)load
{
    [self tc_swizzle:@selector(textRectForBounds:limitedToNumberOfLines:)];
    [self tc_swizzle:@selector(drawTextInRect:)];
}

- (UIEdgeInsets)contentEdgeInsets
{
    NSValue *value = objc_getAssociatedObject(self, &kContentEdgeInsetsKey);
    return nil != value ? [value UIEdgeInsetsValue] : UIEdgeInsetsZero;
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets
{
    objc_setAssociatedObject(self, &kContentEdgeInsetsKey, [NSValue valueWithUIEdgeInsets:contentEdgeInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsDisplay];
}

- (TCTextVerticalAlignment)textVerticalAlignment
{
    NSNumber *alignment = objc_getAssociatedObject(self, &kTextVerticalAlignmentKey);
    
    if (nil != alignment) {
        return alignment.integerValue;
    }
    
    objc_setAssociatedObject(self, &kTextVerticalAlignmentKey, @(kTCTextVerticalAlignmentDefault), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return kTCTextVerticalAlignmentDefault;
}

- (void)setTextVerticalAlignment:(TCTextVerticalAlignment)textVerticalAlignment
{
    objc_setAssociatedObject(self, &kTextVerticalAlignmentKey, @(textVerticalAlignment), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsDisplay];
}

- (CGRect)tc_textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect textRect = [self tc_textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    
    switch (self.textVerticalAlignment) {
        case kTCTextVerticalAlignmentTop:
            textRect.origin.y = bounds.origin.y;
            break;
            
        case kTCTextVerticalAlignmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            break;
            
        case kTCTextVerticalAlignmentDefault:
        case kTCTextVerticalAlignmentMiddle:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0f;
            break;
            
        default:
            break;
    }
    
    return textRect;
}

- (void)tc_drawTextInRect:(CGRect)rect
{
    CGRect fixRect = rect;
    UIEdgeInsets edge = self.contentEdgeInsets;
    if (self.textVerticalAlignment != kTCTextVerticalAlignmentDefault || !UIEdgeInsetsEqualToEdgeInsets(edge, UIEdgeInsetsZero)) {
        CGRect actualRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
        fixRect = UIEdgeInsetsInsetRect(actualRect, edge);
    }
    [self tc_drawTextInRect:fixRect];
}

@end

#endif
