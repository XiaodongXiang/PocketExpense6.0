//
//  NSDate+XDExtension.m
//  PocketExpense
//
//  Created by 晓东 on 2018/1/30.
//

#import "NSDate+XDExtension.h"

@implementation NSDate (XDExtension)


+(NSDate *)initCurrentDate{
    NSCalendarUnit dayInfoUnits  = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents* components = [[NSCalendar currentCalendar] components:dayInfoUnits fromDate:[NSDate date]];
    
    NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    return date;
}
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
-(NSDate*)initDate{
    NSCalendar* calendar = [NSCalendar currentCalendar];
//    calendar.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSCalendarUnit dayInfoUnits  = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents* components = [calendar components:dayInfoUnits fromDate:self];
    
    NSDate* date = [calendar dateFromComponents:components];
    
    return date;
}

-(NSDate*)endDate{
    NSCalendarUnit dayInfoUnits  = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents* components = [[NSCalendar currentCalendar] components:dayInfoUnits fromDate:self];
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    return date;
    
}

-(NSDate *)initYearDate{
    NSCalendarUnit dayInfoUnits  = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents* components = [[NSCalendar currentCalendar] components:dayInfoUnits fromDate:self];
    components.month = 1;
    components.day = 2;
    NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    return date;
}

-(NSDate *)initYearEndDate{
    NSCalendarUnit dayInfoUnits  = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents* components = [[NSCalendar currentCalendar] components:dayInfoUnits fromDate:self];
    components.month = 12;
    components.day = 31;
    NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    return date;
}

@end
