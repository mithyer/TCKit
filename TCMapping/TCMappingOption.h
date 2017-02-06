//
//  TCMappingOption.h
//  TCKit
//
//  Created by dake on 16/3/29.
//  Copyright © 2016年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>


@class UIImage, UIColor;

NS_ASSUME_NONNULL_BEGIN


@class TCMappingOption;
@protocol TCMappingOption <NSObject>

@optional
+ (nullable TCMappingOption *)tc_mappingOption;

@end

// TODO: add property callback
@protocol TCMappingTransform <NSObject>

@optional
// UIImage <-> NSData
+ (nullable NSData *)tc_transformDataFromImage:(UIImage *)img;
+ (nullable UIImage *)tc_transformImageFromData:(NSData *)data;
+ (nullable UIImage *)tc_transformImageFromBase64String:(NSString *)str;

// UIColor <-> NSString
+ (nullable UIColor *)tc_transformColorFromString:(NSString *)string;
+ (nullable UIColor *)tc_transformColorFromHex:(uint32_t)hex;
+ (nullable NSString *)tc_transformHexStringFromColor:(UIColor *)color;

// NSData <-> NSString
+ (nullable NSData *)tc_transformDataFromString:(NSString *)hex;
+ (nullable NSString *)tc_transformHexStringFromData:(NSData *)data;

@end


typedef Class __nullable (^TCTypeMappingBlock)(id value);
typedef id __nullable (^TCValueMappingBlock)(id value);

@interface TCMappingOption : NSObject <NSCopying>

@property (nonatomic, assign) BOOL autoMapUntilRoot; // default: YES

#pragma mark - TCMapping

/**
 @brief	format: @{@"propertyName": @"json'propertyName" or NSNull.null for ignore or TCMappingOption}
 */
@property (nullable, nonatomic, strong) NSDictionary<NSString *, id> *nameMapping;

/**
 @brief	format: @{@"propertyName": @"object'class name or Class or `TCTypeMappingBlock`, or yyyy-MM-dd...(-> NSDate)"}
 */
@property (nullable, nonatomic, strong) NSDictionary<NSString *, Class/* Class\TCTypeMappingBlock\yyyy-MM-dd... */> *typeMapping;

@property (nullable, nonatomic, strong) NSDictionary<NSString *, id/* TCValueMappingBlock */> *undefineMapping;

/**
 @brief	format: @{@"primaryKey1": @"value", @"primaryKey2": NSNull.null}
 NSNull.null will be replace with an exact value while mapping.
 */
@property (nullable, nonatomic, strong) NSDictionary<NSString *, id> *primaryKey;


@property (nonatomic, assign) BOOL shouldMappingNSNull; // mapping NSNull -> nil or not
@property (nonatomic, assign) BOOL mappingEmptyDictionaryToNSNull; // mapping {} -> NSNull


@property (nullable, nonatomic, copy) void (^setUpDateFormatter)(SEL property, NSDateFormatter *fmter); // for time string -> NSDate
@property (nullable, nonatomic, copy) NSTimeInterval (^secondSince1970)(SEL property, NSTimeInterval timestamp, BOOL *ignoreReturn);

@property (nullable, nonatomic, copy) BOOL (^mappingValidate)(id obj);

@property (nonatomic, assign) BOOL ignoreUndefineMapping;


+ (instancetype)optionWithNameMapping:(NSDictionary<NSString *, NSString *> *)nameMapping;
+ (instancetype)optionWithTypeMapping:(NSDictionary<NSString *, Class> *)typeMapping;
+ (instancetype)optionWithMappingValidate:(BOOL (^)(id obj))validate;


#pragma mark - TCNSCoding

/**
 @brief	format: @{@"propertyName": @"coding key" or NSNull.null for ignore}
 */
@property (nullable, nonatomic, strong) NSDictionary<NSString *, NSString *> *nameNSCodingMapping;


#pragma mark - TCNSCopying

@property (nonatomic, strong) NSArray<NSString *> *nameCopyIgnore;


#pragma mark - TCCoding

/**
 @brief	format: @{@"propertyName": @"json'propertyName" or NSNull.null for ignore or TCMappingOption}
 */
@property (nullable, nonatomic, strong) NSDictionary<NSString *, id> *nameCodingMapping;
@property (nonatomic, assign) BOOL shouldCodingNSNull; // ignore output NSNull or not
@property (nonatomic, assign) BOOL codingEmptyDataToNil; // default: YES
@property (nonatomic, assign) BOOL codingNSDateToIntSeconds; // default: NO


// TODO: hash, equal  ignore


@end

NS_ASSUME_NONNULL_END


