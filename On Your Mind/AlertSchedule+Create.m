//
//  AlertSchedule+Create.m
//  On Your Mind
//
//  Created by Daniel Bradford on 9/2/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "AlertSchedule+Create.h"

@implementation AlertSchedule (Create)
+(AlertSchedule*)saveAlertScheduleForDayOfWeek:(NSString*)dayOfWeek withAlertTime:(NSDate*)alertTime inManagedObjectContext:(NSManagedObjectContext*)context;
{
    AlertSchedule *schedule = [NSEntityDescription insertNewObjectForEntityForName:@"AlertSchedule" inManagedObjectContext:context];
    schedule.dayOfWeek = dayOfWeek;
    schedule.alertTime = alertTime;
    
    return schedule;
}

@end
