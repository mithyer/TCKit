//
//  TCFoundation.h
//  TCKit
//
//  Created by dake on 16/6/2.
//  Copyright © 2016年 dake. All rights reserved.
//

#ifndef TCFoundation_h
#define TCFoundation_h

#import "TCDefines.h"

#import "NSObject+TCUtilities.h"
#import "NSDate+TCUtilities.h"
#import "NSArray+TCUtilities.h"
#import "UIColor+TCUtilities.h"

#import "TCAppInfo.h"
#import "UIDevice+TCHardware.h"


#import "NSObject+TCHelper.h"
#import "NSObject+TCMapping.h"
#import "NSObject+TCPersistent.h"
#import "NSObject+TCCoding.h"
#import "NSData+TCCypher.h"
#import "NSString+TCCypher.h"
#import "NSBundle+TCHelper.h"
#import "NSOutputStream+TCHelper.h"

#import "NSString+TCHelper.h"
#import "NSURL+TCHelper.h"



#define TC_AUTO_COPY_CODING_EQUAL_HASH \
- (NSUInteger)hash {return self.tc_hash;} \
- (BOOL)isEqual:(id)object {return [self tc_isEqual:object];} \
- (void)encodeWithCoder:(NSCoder *)aCoder {[self tc_encodeWithCoder:aCoder];} \
- (instancetype)initWithCoder:(NSCoder *)aDecoder {return [self tc_initWithCoder:aDecoder];} \
- (instancetype)copyWithZone:(NSZone *)zone {return self.tc_copy;}


#define TC_AUTO_COPY_CODING_HASH \
- (NSUInteger)hash {return self.tc_hash;} \
- (void)encodeWithCoder:(NSCoder *)aCoder {[self tc_encodeWithCoder:aCoder];} \
- (instancetype)initWithCoder:(NSCoder *)aDecoder {return [self tc_initWithCoder:aDecoder];} \
- (instancetype)copyWithZone:(NSZone *)zone {return self.tc_copy;}

#define TC_AUTO_COPY_CODING \
- (void)encodeWithCoder:(NSCoder *)aCoder {[self tc_encodeWithCoder:aCoder];} \
- (instancetype)initWithCoder:(NSCoder *)aDecoder {return [self tc_initWithCoder:aDecoder];} \
- (instancetype)copyWithZone:(NSZone *)zone {return self.tc_copy;}

#define TC_AUTO_EQUAL_HASH \
- (NSUInteger)hash {return self.tc_hash;} \
- (BOOL)isEqual:(id)object {return [self tc_isEqual:object];}


#endif /* TCFoundation_h */
