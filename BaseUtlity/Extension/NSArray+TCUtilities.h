/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>


typedef id (^MapBlock)(id object);
typedef BOOL (^TestingBlock)(id object);


@interface NSArray<ObjectType> (TCUtilities)

// Utility
@property (nonatomic, strong, readonly) NSArray<ObjectType> *reversed;
@property (nonatomic, strong, readonly) NSArray<ObjectType> *sorted;
@property (nonatomic, strong, readonly) NSArray<ObjectType> *sortedCaseInsensitive;


// Setification
@property (nonatomic, strong, readonly) NSArray<ObjectType> *uniqueElements;

- (id)topObject;

- (instancetype)unionWithArray:(NSArray<ObjectType> *)anArray;
- (instancetype)intersectionWithArray:(NSArray<ObjectType> *)anArray;
- (instancetype)differenceToArray:(NSArray<ObjectType> *)anArray;


// Lisp
- (instancetype)map:(MapBlock)aBlock;
- (instancetype)collect:(TestingBlock)aBlock;
- (instancetype)reject:(TestingBlock)aBlock;

@end

@interface NSMutableArray<ObjectType> (TCUtilities)
- (instancetype)reverse;
//- (NSMutableArray *) scramble;

@end

@interface NSMutableArray (TC_StackAndQueueExtensions)

- (id)popObject;
- (id)pullObject;
- (instancetype)pushObject:(id)object;
- (instancetype)pushObjects:(id)object, ...;

@end

