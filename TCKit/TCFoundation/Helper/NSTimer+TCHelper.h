//
//  NSTimer+TCHelper.h
//  TCKit
//
//  Created by dake on 15/5/9.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (TCHelper)

@property (nonatomic, assign) NSUInteger executeCount;
@property (nonatomic, assign, readonly) NSUInteger index;

@property (nullable, nonatomic, copy) void (^executeBlock)(NSTimer *timer);
@property (nullable, nonatomic, copy) void (^completeBlock)(NSTimer *timer);

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval
                                  executeBlock:(void (^__nullable)(NSTimer *timer))executeBlock
                                 completeBlock:(void (^__nullable)(NSTimer *timer))completeBlock
                                  executeCount:(NSUInteger)executeCount;

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)timeInterval
                         executeBlock:(void (^__nullable)(NSTimer *timer))executeBlock
                        completeBlock:(void (^__nullable)(NSTimer *timer))completeBlock
                         executeCount:(NSUInteger)executeCount;

- (void)tc_invalidate;

@end


NS_ASSUME_NONNULL_END
