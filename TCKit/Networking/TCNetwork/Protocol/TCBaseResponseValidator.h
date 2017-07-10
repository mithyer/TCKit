//
//  TCBaseResponseValidator.h
//  TCKit
//
//  Created by dake on 13-3-27.
//  Copyright (c) 2013年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCHTTPRespValidator.h"


NS_ASSUME_NONNULL_BEGIN

@interface TCBaseResponseValidator : NSObject <TCHTTPRespValidator>

@property (nonatomic, strong, nullable) id data;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, copy, nullable) NSString *successMsg;
@property (nonatomic, strong, nullable) NSError *error;

@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSArray<NSNumber *> *> *errorFilter;

- (BOOL)validateHTTPResponse:(id)obj fromCache:(BOOL)fromCache forRequest:(id<TCHTTPRequest>)request error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
