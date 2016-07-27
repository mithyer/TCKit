//
//  UILabel+TCHelper.h
//  TCKit
//
//  Created by dake on 15/3/10.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TCTextVerticalAlignment) {
    kTCTextVerticalAlignmentDefault = 0,
    kTCTextVerticalAlignmentTop,
    kTCTextVerticalAlignmentMiddle,
    kTCTextVerticalAlignmentBottom,
};

@interface UILabel (TCHelper)

@property (nonatomic, assign) TCTextVerticalAlignment textVerticalAlignment;
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;

@end
