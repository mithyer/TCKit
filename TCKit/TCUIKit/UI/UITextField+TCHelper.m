//
//  UITextField+TCHelper.m
//  TCKit
//
//  Created by dake on 15/9/15.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#if !defined(TARGET_IS_EXTENSION) || defined(TARGET_IS_UI_EXTENSION)

#import "UITextField+TCHelper.h"
#import <objc/runtime.h>
#import "NSObject+TCUtilities.h"


@interface TCTextFieldTarget : NSObject

+ (void)textFieldEditChanged:(UITextField *)textField;

@end


@implementation TCTextFieldTarget

+ (void)textFieldEditChanged:(UITextField *)textField
{
    NSString *toBeString = textField.text;
    UITextRange *selectedRange = textField.markedTextRange;
    // check highlight selection position
    UITextPosition *position = nil;
    if (nil != selectedRange) {
        position = [textField positionFromPosition:selectedRange.start offset:0];
    }
    // no highlight selection
    if (nil == position) {
        NSInteger maxLength = textField.tc_maxTextLength;
        
        if (maxLength >= 0 && toBeString.length > maxLength) {
            NSRange range = [toBeString rangeOfComposedCharacterSequenceAtIndex:(NSUInteger)maxLength];
            textField.text = [toBeString substringToIndex:range.location == NSNotFound ? (NSUInteger)maxLength : range.location];
        }
    } else {
    }
    
    id<TCTextFieldHelperDelegate> tc_delegate = textField.tc_delegate;
    if (nil != tc_delegate && [tc_delegate respondsToSelector:@selector(tc_textFieldValueChanged:)]) {
        [tc_delegate tc_textFieldValueChanged:textField];
    }
}

@end

#ifndef __IPHONE_13_0
@implementation UISearchBar (Xcode10)

@dynamic searchTextField;

@end
#endif


@implementation UITextField (TCHelper)

- (id<TCTextFieldHelperDelegate>)tc_delegate
{
    return [self bk_associatedValueForKey:_cmd];
}

- (void)setTc_delegate:(id<TCTextFieldHelperDelegate>)tc_delegate
{
    [self bk_weaklyAssociateValue:tc_delegate withKey:@selector(tc_delegate)];
    
    id target = (id)TCTextFieldTarget.class;
    if (![self.allTargets containsObject:target]) {
        [self addTarget:target action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    }
}


- (NSInteger)tc_maxTextLength
{
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    return nil == value ? -1 : value.integerValue;
}

- (void)setTc_maxTextLength:(NSInteger)tc_maxTextLength
{
    objc_setAssociatedObject(self, @selector(tc_maxTextLength), @(tc_maxTextLength), OBJC_ASSOCIATION_RETAIN);
    
    id target = (id)TCTextFieldTarget.class;
    if (![self.allTargets containsObject:target]) {
        [self addTarget:target action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    }
}


#pragma mark - paste

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self tc_swizzle:@selector(paste:)];
    });
}

- (void)tc_paste:(UIMenuController *)sender
{
    id<TCTextFieldHelperDelegate> tc_delegate = self.tc_delegate;
    
    if (nil != tc_delegate && [tc_delegate respondsToSelector:@selector(tc_textField:stringForPaste:)]) {
        UIPasteboard *board = UIPasteboard.generalPasteboard;
        NSString *raw = board.string;
        board.string = [tc_delegate tc_textField:self stringForPaste:raw];
        [self tc_paste:sender];
        board.string = raw;
    } else {
        [self tc_paste:sender];
    }
}

@end


/*
static char const kInputFormatKey;
static char const kInputTextKey;
static char const kNumberOfSepecialCharactersKey;

@implementation UITextField (InputFormat)

- (void)setInputFormat:(NSString *)inputFormat
{
    objc_setAssociatedObject(self, &kInputFormatKey, inputFormat, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)inputFormat
{
    return objc_getAssociatedObject(self, &kInputFormatKey);
}

- (void)setInputText:(NSString *)inputText
{
    objc_setAssociatedObject(self, &kInputTextKey, inputText, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)inputText
{
    return objc_getAssociatedObject(self, &kInputTextKey);
}

- (void)setNumberOfSepecialCharacters:(NSInteger)numberOfSepecialCharacters
{
    objc_setAssociatedObject(self, &kNumberOfSepecialCharactersKey, @(numberOfSepecialCharacters), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)numberOfSepecialCharacters
{
    return [objc_getAssociatedObject(self, &kNumberOfSepecialCharactersKey) integerValue];
}

- (NSString *)generateFormattedTextInRange:(NSRange)range withString:(NSString *)string
{
    NSString *inputText = self.inputText;
    if (nil == inputText) {
        inputText = NSString.string;
    }
    
    if (string.length < 1) {
        inputText = [inputText substringToIndex:inputText.length - (inputText.length > 0 ? 1 : 0)];
    } else {
        inputText = [inputText stringByAppendingString:string];
    }
    
    NSString *toBeString = inputText;
    UITextRange *selectedRange = self.markedTextRange;
    // check highlight selection position
    UITextPosition *position = nil;
    if (nil != selectedRange) {
        position = [self positionFromPosition:selectedRange.start offset:0];
    }
    // no highlight selection
    if (nil == position) {
        
        NSInteger maxLength = self.tc_maxTextLength - self.numberOfSepecialCharacters;
        
        if (maxLength >= 0 && toBeString.length > maxLength) {
            NSRange range = [toBeString rangeOfComposedCharacterSequenceAtIndex:(NSUInteger)maxLength];
            inputText = [toBeString substringToIndex:range.location == NSNotFound ? (NSUInteger)maxLength : range.location];
        }
    } else {
    }
    self.inputText = inputText;
    
    return [self formattedText:self.text inRange:range withString:string];
}

- (NSString *)formattedText:(NSString *)text inRange:(NSRange)range withString:(NSString *)string
{
    NSString *changedString = [text stringByReplacingCharactersInRange:range withString:string];
    
    if (range.length == 1 && string.length < range.length && [[text substringWithRange:range] isEqualToString:@"\x20"]) {
        if (changedString.length > 1) {
            NSUInteger location = changedString.length - 1;
            for (; location > 0; --location) {
                if (isdigit([changedString characterAtIndex:location])) {
                    break;
                }
            }
            changedString = [changedString substringToIndex:location];
        }
    }
    
    return [self formattedString:changedString withFormat:self.inputFormat];
}

- (NSString *)formattedString:(NSString *)string {
    return [self formattedString:string withFormat:self.inputFormat];
}

// 输入时 显示指定的固定的格式
- (NSString *)formattedString:(NSString *)string withFormat:(NSString *)format
{
    NSUInteger onOriginal = 0, onFilter = 0, onOutput = 0;
    char outputString[format.length];
    BOOL done = NO;
    
    while (onFilter < format.length && !done) {
        unichar filterChar = [format characterAtIndex:onFilter];
        unichar originalChar = onOriginal >= string.length ? '\0' : [string characterAtIndex:onOriginal];
        switch (filterChar) {
            case '#': {
                if (originalChar == '\0') {
                    // We have no more input numbers for the filter.  We're done.
                    done = YES;
                    break;
                }
                // !!!: do not ignore non digit (by jia)
                //                if(isdigit(originalChar))
                //                {
                outputString[onOutput] = (char)originalChar;
                onOriginal++;
                onFilter++;
                onOutput++;
                //                }
                //                else
                //                {
                //                    onOriginal++;
                //                }
                break;
            }
            default: {
                outputString[onOutput] = (char)filterChar;
                onOutput++;
                onFilter++;
                if (originalChar == filterChar) {
                    onOriginal++;
                }
                break;
            }
        }
    }
    outputString[onOutput] = '\0'; // Cap the output string
    return [NSString stringWithUTF8String:(const char *)outputString];
    
}

@end
 
 */

#endif
