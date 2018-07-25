/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook 3.x and beyond
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, TCDateFormatType) {
    kTCDateFormatTypeIOS8601,
    kTCDateFormatTypeRFC3339 = kTCDateFormatTypeIOS8601,
    kTCDateFormatTypeRFC822,
    kTCDateFormatTypeRFC850,
    kTCDateFormatTypeRFC1123,
    kTCDateFormatTypeASCTIME,
};

NS_ASSUME_NONNULL_BEGIN

extern NSInteger const D_MINUTE;
extern NSInteger const D_HOUR;
extern NSInteger const D_DAY;
extern NSInteger const D_WEEK;
extern NSInteger const D_YEAR;

@interface NSDate (TCUtilities)

+ (NSCalendar *)currentCalendar; // avoid bottlenecks
+ (NSDateFormatter *)dateFormatter;


/*
 2010-07-09T16:13:30+12:00
 2011-01-11T11:11:11+0000
 2011-01-26T19:06:43Z
 */
extern NSString *const kTCDateIOS8601ReadFormat;

/*
 2010-07-09T16:13:30.3+12:00
 2011-01-11T11:11:11.322+0000
 2011-01-26T19:06:43.554Z
 */
extern NSString *const kTCDateIOS8601SubReadFormat;

/*
 2011-01-26T19:06:43Z
 */
extern NSString *const kTCDateIOS8601WriteZuluFormat;

/*
 2011-01-26T19:06:43.554Z
 */
extern NSString *const kTCDateIOS8601WriteSubZuluFormat;

/*
 2010-07-09T16:13:30+0000
 */
extern NSString *const kTCDateIOS8601WriteZoneFormat;

/*
 2011-01-11T11:11:11.322+0000
 */
extern NSString *const kTCDateIOS8601WriteSubZoneFormat;

/*
 2010-07-09T16:13:30+00:00
 */
extern NSString *const kTCDateIOS8601WriteColonZoneFormat;

/*
 2011-01-11T11:11:11.322+00:00
 */
extern NSString *const kTCDateIOS8601WriteSubColonZoneFormat;


/*
 Wed, 02 Oct 2002 08:00:00 EST
 Wed, 02 Oct 2002 13:00:00 GMT
 Wed, 02 Oct 2002 15:00:00 +0200
 // Mon, 15 Aug 05 15:52:01 +0000
 */
extern NSString *const kTCDateRFC822Format;

/*
 Monday, 15-Aug-05 15:52:01 UTC
 */
extern NSString *const kTCDateRFC850Format;

/*
 Mon, 15 Aug 2005 15:52:01 +0000
 */
extern NSString *const kTCDateRFC1123Format;

/*
 Wed Oct 2 15:00:00 2002
 */
extern NSString *const kTCDateASCFormat;

+ (NSDateFormatter *)dateFormatterForType:(TCDateFormatType)type fmt:(NSString *)fmt timeZone:(NSTimeZone *_Nullable)timeZone;

// Relative dates from the current date
+ (instancetype)dateTomorrow;
+ (instancetype)dateYesterday;
+ (instancetype)dateWithDaysFromNow:(NSInteger)days;
+ (instancetype)dateWithDaysBeforeNow:(NSInteger)days;
+ (instancetype)dateWithHoursFromNow:(NSInteger)dHours;
+ (instancetype)dateWithHoursBeforeNow:(NSInteger)dHours;
+ (instancetype)dateWithMinutesFromNow:(NSInteger)dMinutes;
+ (instancetype)dateWithMinutesBeforeNow:(NSInteger)dMinutes;

// Short string utilities
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;
- (NSString *)stringWithFormat:(NSString *)format;

@property (nonatomic, readonly) NSString *shortString;
@property (nonatomic, readonly) NSString *shortDateString;
@property (nonatomic, readonly) NSString *shortTimeString;
@property (nonatomic, readonly) NSString *mediumString;
@property (nonatomic, readonly) NSString *mediumDateString;
@property (nonatomic, readonly) NSString *mediumTimeString;
@property (nonatomic, readonly) NSString *longString;
@property (nonatomic, readonly) NSString *longDateString;
@property (nonatomic, readonly) NSString *longTimeString;

// Comparing dates
- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate;

- (BOOL)isToday;
- (BOOL)isTomorrow;
- (BOOL)isYesterday;

- (BOOL)isSameWeekAsDate:(NSDate *)aDate;
- (BOOL)isThisWeek;
- (BOOL)isNextWeek;
- (BOOL)isLastWeek;

- (BOOL)isSameMonthAsDate:(NSDate *)aDate;
- (BOOL)isThisMonth;
- (BOOL)isNextMonth;
- (BOOL)isLastMonth;

- (BOOL)isSameYearAsDate:(NSDate *)aDate;
- (BOOL)isThisYear;
- (BOOL)isNextYear;
- (BOOL)isLastYear;

- (BOOL)isEarlierThanDate:(NSDate *)aDate;
- (BOOL)isLaterThanDate:(NSDate *)aDate;

- (BOOL)isInFuture;
- (BOOL)isInPast;

// Date roles
- (BOOL)isTypicallyWorkday;
- (BOOL)isTypicallyWeekend;

// Adjusting dates
- (instancetype)dateByAddingYears:(NSInteger)dYears;
- (instancetype)dateBySubtractingYears:(NSInteger)dYears;
- (instancetype)dateByAddingMonths:(NSInteger)dMonths;
- (instancetype)dateBySubtractingMonths:(NSInteger)dMonths;
- (instancetype)dateByAddingDays:(NSInteger)dDays;
- (instancetype)dateBySubtractingDays:(NSInteger)dDays;
- (instancetype)dateByAddingHours:(NSInteger)dHours;
- (instancetype)dateBySubtractingHours:(NSInteger)dHours;
- (instancetype)dateByAddingMinutes:(NSInteger)dMinutes;
- (instancetype)dateBySubtractingMinutes:(NSInteger)dMinutes;

// Date extremes
- (instancetype)dateAtStartOfYear;
- (instancetype)dateAtStartOfMonth;
- (instancetype)dateAtStartOfDay;
- (instancetype)dateAtEndOfDay;

// Retrieving intervals
- (NSInteger)minutesAfterDate:(NSDate *)aDate;
- (NSInteger)minutesBeforeDate:(NSDate *)aDate;
- (NSInteger)hoursAfterDate:(NSDate *)aDate;
- (NSInteger)hoursBeforeDate:(NSDate *)aDate;
- (NSInteger)daysAfterDate:(NSDate *)aDate;
- (NSInteger)daysBeforeDate:(NSDate *)aDate;
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate;

// Decomposing dates
@property (nonatomic, readonly) NSInteger nearestHour;
@property (nonatomic, readonly) NSInteger hour;
@property (nonatomic, readonly) NSInteger minute;
@property (nonatomic, readonly) NSInteger seconds;
@property (nonatomic, readonly) NSInteger day;
@property (nonatomic, readonly) NSInteger month;
@property (nonatomic, readonly) NSInteger weekOfYear;
@property (nonatomic, readonly) NSInteger weekOfMonth;
@property (nonatomic, readonly) NSInteger weekday;
@property (nonatomic, readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (nonatomic, readonly) NSInteger year;

@end

NS_ASSUME_NONNULL_END
