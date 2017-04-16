/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (TCUtilities)

typedef id _Nullable (^MapBlock)(ObjectType object);
typedef BOOL (^TestingBlock)(ObjectType object);

// Utility
@property (nonatomic, strong, readonly) NSArray<ObjectType> *reversed;
@property (nonatomic, strong, readonly) NSArray<ObjectType> *sorted;
@property (nonatomic, strong, readonly) NSArray<ObjectType> *sortedCaseInsensitive;


// Setification
@property (nonatomic, strong, readonly) NSArray<ObjectType> *uniqueElements;

- (ObjectType)topObject;

- (instancetype)unionWithArray:(NSArray<ObjectType> *)anArray;
- (instancetype)intersectionWithArray:(NSArray<ObjectType> *)anArray;
- (instancetype)differenceToArray:(NSArray<ObjectType> *)anArray;


// Lisp
- (nullable instancetype)map:(MapBlock)aBlock;
- (nullable instancetype)collect:(TestingBlock)aBlock;
- (nullable instancetype)reject:(TestingBlock)aBlock;

@end

@interface NSMutableArray<ObjectType> (TCUtilities)
- (instancetype)reverse;
//- (NSMutableArray *) scramble;
- (void)replaceObjectIdenticalTo:(id)obj withObject:(id)anObject;


@end

@interface NSMutableArray<ObjectType> (TC_StackAndQueueExtensions)

- (nullable ObjectType)popObject;
- (nullable ObjectType)pullObject;
- (instancetype)pushObject:(ObjectType)object;
- (instancetype)pushObjects:(ObjectType)object, ...;

@end

NS_ASSUME_NONNULL_END
