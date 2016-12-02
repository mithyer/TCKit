//
//  UITextField+TCHelper.h
//  TCKit
//
//  Created by dake on 15/9/15.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#if !defined(TARGET_IS_EXTENSION) || defined(TARGET_IS_UI_EXTENSION)

#import <UIKit/UIKit.h>


@protocol TCTextFieldHelperDelegate <NSObject>

@optional
- (void)tc_textFieldValueChanged:(UITextField *)sender;
- (NSString *)tc_textField:(UITextField *)sender stringForPaste:(NSString *)string;

@end

@interface UITextField (TCHelper)

@property (nonatomic, assign) NSInteger tc_maxTextLength;
@property (nonatomic, weak) id<TCTextFieldHelperDelegate> tc_delegate;

@end

@interface UITextField (InputFormat)

@property (nonatomic, copy) NSString *inputFormat;
@property (nonatomic, copy) NSString *inputText;
@property (nonatomic, assign) NSInteger numberOfSepecialCharacters;

- (NSString *)generateFormattedTextInRange:(NSRange)range withString:(NSString *)string;
- (NSString *)formattedString:(NSString *)string;

@end

#endif


