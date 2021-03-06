/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <Foundation/Foundation.h>

@interface NSDate (KalAdditions)

// All of the following methods use [NSCalendar currentCalendar] to perform
// their calculations.

- (NSDate *)cc_dateByMovingToBeginningOfDay;
- (NSDate *)cc_dateByMovingToEndOfDay;
- (NSDate *)cc_dateByMovingToFirstDayOfTheMonth;
- (NSDate *)cc_dateByMovingToFirstDayOfThePreviousMonth;
- (NSDate *)cc_dateByMovingToFirstDayOfTheFollowingMonth;
- (NSDateComponents *)cc_componentsForMonthDayAndYear;
- (NSUInteger)cc_weekday;
- (NSUInteger)cc_numberOfDaysInMonth;

- (NSDate *)cc_dateByMovingToFirstDayOfTheWeek;
- (NSDate *)cc_dateByMovingToFirstDayOfThePreviousWeek;
- (NSDate *)cc_dateByMovingToFirstDayOfTheFollowingWeek;
-(NSDate *)cc_dateByMovingToFirstDayOfTheCurrentWeek;
-(NSDate *)cc_dateByMovingToFirstDayOfTheCurrentMonth;


//HMJMonthView
-(NSDate *)hmj_dateByMovingToFirstDayofthePrevious5Monthes;
-(NSDate *)hmj_dateByMovingToFirstDayoftheFollowing5Monthes;



@end