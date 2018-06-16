//
//  NSDate+XDExtension.h
//  PocketExpense
//
//  Created by 晓东 on 2018/1/30.
//

#import <Foundation/Foundation.h>

@interface NSDate (XDExtension)

+(NSDate*)initCurrentDate;

-(NSDate*)initDate;

-(NSDate*)endDate;

-(NSDate*)initYearDate;

-(NSDate*)initYearEndDate;
@end
