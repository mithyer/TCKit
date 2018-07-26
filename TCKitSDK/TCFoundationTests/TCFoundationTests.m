//
//  TCFoundationTests.m
//  TCFoundationTests
//
//  Created by cdk on 2017/7/10.
//  Copyright © 2017年 PixelCyber. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDate+TCUtilities.h"

@interface TCFoundationTests : XCTestCase

@end

@implementation TCFoundationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDateISO8601Format {
    NSDate *date = NSDate.date;
    
    // zulu
    // 2018-07-26T06:05:13Z
    NSDateFormatter *wfmt = [NSDate dateFormatterForType:kTCDateFormatTypeIOS8601 fmt:kTCDateIOS8601WriteZuluFormat timeZone:NSTimeZone.localTimeZone];
    NSString *str = [wfmt stringFromDate:date];
    XCTAssertNotNil(str);
    NSDateFormatter *rfmt = [NSDate dateFormatterForType:kTCDateFormatTypeIOS8601 fmt:kTCDateIOS8601ReadFormat timeZone:NSTimeZone.localTimeZone];
    NSDate *outputDate = [rfmt dateFromString:str];
    XCTAssertEqual(outputDate.timeIntervalSince1970, floor(date.timeIntervalSince1970));
    
    // time zone
    // 2018-07-26T14:05:13+0800
    wfmt = [NSDate dateFormatterForType:kTCDateFormatTypeIOS8601 fmt:kTCDateIOS8601WriteZoneFormat timeZone:NSTimeZone.localTimeZone];
    str = [wfmt stringFromDate:date];
    XCTAssertNotNil(str);
    rfmt = [NSDate dateFormatterForType:kTCDateFormatTypeIOS8601 fmt:kTCDateIOS8601ReadFormat timeZone:NSTimeZone.localTimeZone];
    outputDate = [rfmt dateFromString:str];
    XCTAssertEqual(outputDate.timeIntervalSince1970, floor(date.timeIntervalSince1970));
    
    // time zone colon
    // 2018-07-26T14:04:21+08:00
    wfmt = [NSDate dateFormatterForType:kTCDateFormatTypeIOS8601 fmt:kTCDateIOS8601WriteColonZoneFormat timeZone:NSTimeZone.localTimeZone];
    str = [wfmt stringFromDate:date];
    XCTAssertNotNil(str);
    rfmt = [NSDate dateFormatterForType:kTCDateFormatTypeIOS8601 fmt:kTCDateIOS8601ReadFormat timeZone:NSTimeZone.localTimeZone];
    outputDate = [rfmt dateFromString:str];
    XCTAssertEqual(outputDate.timeIntervalSince1970, floor(date.timeIntervalSince1970));
    
    
    // time zone ms
    // 2018-07-26T14:04:21.842+0800
    wfmt = [NSDate dateFormatterForType:kTCDateFormatTypeIOS8601 fmt:kTCDateIOS8601WriteSubZoneFormat timeZone:NSTimeZone.localTimeZone];
    str = [wfmt stringFromDate:date];
    XCTAssertNotNil(str);
    rfmt = [NSDate dateFormatterForType:kTCDateFormatTypeIOS8601 fmt:kTCDateIOS8601SubReadFormat timeZone:NSTimeZone.localTimeZone];
    outputDate = [rfmt dateFromString:str];
    NSTimeInterval value = outputDate.timeIntervalSince1970 - date.timeIntervalSince1970;
    XCTAssertTrue(value > -1e-3f && value < 1e-3f);
    
    rfmt = [NSDate dateFormatterForType:kTCDateFormatTypeIOS8601 fmt:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ" timeZone:NSTimeZone.localTimeZone];
    outputDate = [rfmt dateFromString:str];
    value = outputDate.timeIntervalSince1970 - date.timeIntervalSince1970;
    XCTAssertTrue(value > -1e-3f && value < 1e-3f);
    
    
    // time zone ms colon
    // 2018-07-26T14:07:21.280+08:00
    wfmt = [NSDate dateFormatterForType:kTCDateFormatTypeIOS8601 fmt:kTCDateIOS8601WriteSubColonZoneFormat timeZone:NSTimeZone.localTimeZone];
    str = [wfmt stringFromDate:date];
    XCTAssertNotNil(str);
    rfmt = [NSDate dateFormatterForType:kTCDateFormatTypeIOS8601 fmt:kTCDateIOS8601SubReadFormat timeZone:NSTimeZone.localTimeZone];
    outputDate = [rfmt dateFromString:str];
    value = outputDate.timeIntervalSince1970 - date.timeIntervalSince1970;
    XCTAssertTrue(value > -1e-3f && value < 1e-3f);
    
    
    // time zone ms long
    // 2018-07-26T14:15:21.6790000+0800
    wfmt = [NSDate dateFormatterForType:kTCDateFormatTypeIOS8601 fmt:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ" timeZone:NSTimeZone.localTimeZone];
    str = [wfmt stringFromDate:date];
    XCTAssertNotNil(str);
    rfmt = [NSDate dateFormatterForType:kTCDateFormatTypeIOS8601 fmt:kTCDateIOS8601SubReadFormat timeZone:NSTimeZone.localTimeZone];
    outputDate = [rfmt dateFromString:str];
    value = outputDate.timeIntervalSince1970 - date.timeIntervalSince1970;
    XCTAssertTrue(value > -1e-3f && value < 1e-3f);
    
    rfmt = [NSDate dateFormatterForType:kTCDateFormatTypeIOS8601 fmt:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ" timeZone:NSTimeZone.localTimeZone];
    outputDate = [rfmt dateFromString:str];
    value = outputDate.timeIntervalSince1970 - date.timeIntervalSince1970;
    XCTAssertTrue(value > -1e-3f && value < 1e-3f);
    
}


- (void)testDateFormat {
    NSDate *date = NSDate.date;
    
    // RFC1123/RFC822
    // Thu, 26 Jul 2018 14:26:56 +0800
    NSDateFormatter *wfmt = [NSDate dateFormatterForType:kTCDateFormatTypeRFC1123 fmt:kTCDateRFC1123Format timeZone:NSTimeZone.localTimeZone];
    NSString *str = [wfmt stringFromDate:date];
    XCTAssertNotNil(str);
    NSDateFormatter *rfmt = [NSDate dateFormatterForType:kTCDateFormatTypeRFC1123 fmt:kTCDateRFC1123Format timeZone:NSTimeZone.localTimeZone];
    NSDate *outputDate = [rfmt dateFromString:str];
    XCTAssertEqual(outputDate.timeIntervalSince1970, floor(date.timeIntervalSince1970));
    
    
    // Thu, 26 Jul 2018 14:26:56 GMT
    wfmt = [NSDate dateFormatterForType:kTCDateFormatTypeRFC1123 fmt:@"EEE',' dd MMM yyyy HH:mm:ss z" timeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    str = [wfmt stringFromDate:date];
    XCTAssertNotNil(str);
    rfmt = [NSDate dateFormatterForType:kTCDateFormatTypeRFC1123 fmt:kTCDateRFC1123Format timeZone:NSTimeZone.localTimeZone];
    outputDate = [rfmt dateFromString:str];
    XCTAssertEqual(outputDate.timeIntervalSince1970, floor(date.timeIntervalSince1970));
    
    
    // RFC850
    // Thursday, 26-Jul-18 07:26:27 GMT
    wfmt = [NSDate dateFormatterForType:kTCDateFormatTypeRFC850 fmt:kTCDateRFC850Format timeZone:NSTimeZone.localTimeZone];
    str = [wfmt stringFromDate:date];
    XCTAssertNotNil(str);
    rfmt = [NSDate dateFormatterForType:kTCDateFormatTypeRFC850 fmt:kTCDateRFC850Format timeZone:NSTimeZone.localTimeZone];
    outputDate = [rfmt dateFromString:str];
    XCTAssertEqual(outputDate.timeIntervalSince1970, floor(date.timeIntervalSince1970));
    
    
    // ASCTIME
    // Thu Jul 26 07:33:30 2018
    wfmt = [NSDate dateFormatterForType:kTCDateFormatTypeASCTIME fmt:kTCDateASCFormat timeZone:NSTimeZone.localTimeZone];
    str = [wfmt stringFromDate:date];
    XCTAssertNotNil(str);
    rfmt = [NSDate dateFormatterForType:kTCDateFormatTypeASCTIME fmt:kTCDateASCFormat timeZone:NSTimeZone.localTimeZone];
    outputDate = [rfmt dateFromString:str];
    XCTAssertEqual(outputDate.timeIntervalSince1970, floor(date.timeIntervalSince1970));
    
    // Unix
    // Thu Jul 26 07:55:53 GMT 2018
    wfmt = [NSDate dateFormatterForType:kTCDateFormatTypeUnix fmt:kTCDateUnixFormat timeZone:NSTimeZone.localTimeZone];
    str = [wfmt stringFromDate:date];
    XCTAssertNotNil(str);
    rfmt = [NSDate dateFormatterForType:kTCDateFormatTypeUnix fmt:kTCDateUnixFormat timeZone:NSTimeZone.localTimeZone];
    outputDate = [rfmt dateFromString:str];
    XCTAssertEqual(outputDate.timeIntervalSince1970, floor(date.timeIntervalSince1970));
    
    
    // Ruby
    // Thu Jul 26 15:38:33 +0800 2018
    wfmt = [NSDate dateFormatterForType:kTCDateFormatTypeRuby fmt:kTCDateRubyFormat timeZone:NSTimeZone.localTimeZone];
    str = [wfmt stringFromDate:date];
    XCTAssertNotNil(str);
    rfmt = [NSDate dateFormatterForType:kTCDateFormatTypeRuby fmt:kTCDateRubyFormat timeZone:NSTimeZone.localTimeZone];
    outputDate = [rfmt dateFromString:str];
    XCTAssertEqual(outputDate.timeIntervalSince1970, floor(date.timeIntervalSince1970));
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
