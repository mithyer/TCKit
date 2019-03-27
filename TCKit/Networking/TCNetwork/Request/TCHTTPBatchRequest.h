//
//  TCHTTPBatchRequest.h
//  TCKit
//
//  Created by dake on 15/3/26.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import "TCHTTPRequest.h"


NS_ASSUME_NONNULL_BEGIN

NS_CLASS_AVAILABLE_IOS(7_0) @interface TCHTTPBatchRequest : TCHTTPRequest

@property (nonatomic, copy) NSArray<id<TCHTTPRequest>> *batchRequests;
@property (nonatomic, assign) BOOL continueAfterSubRequestFailed;

+ (instancetype)requestWithRequests:(NSArray<id<TCHTTPRequest>> *)requests;
- (instancetype)initWithRequests:(NSArray<id<TCHTTPRequest>> *)requests;

- (BOOL)start:(NSError * _Nullable __strong * _Nullable)error;


@end

NS_ASSUME_NONNULL_END
