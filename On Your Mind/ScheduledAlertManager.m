//
//  ScheduledAlertManager.m
//  On Your Mind
//
//  Created by Daniel Bradford on 9/7/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "ScheduledAlertManager.h"
#import "AlertSchedule.h"
#import "OnYourMindBLL.h"
#import "OnYourMindAppDelegate.h"
#import "UserDefaults.h"

@implementation ScheduledAlertManager

#define scheduledNotificationUserInfo @"OnYourMind.ScheduleBasedNotification"

+(void)cancelAllScheduleBasedLocalNotifications
{
    NSArray *notifications = nil;
    UILocalNotification *notification;
    NSDictionary *userInfo;
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:ScheduledNotificationsEnabled])
    {
        notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        
        for(int i = 0; i < [notifications count]; i++)
        {
            notification = [notifications objectAtIndex:i];
            userInfo = notification.userInfo;
            if([userInfo objectForKey:scheduledNotificationUserInfo] != nil)
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ScheduledNotificationsEnabled];
    }
}

+(void)createLocalNotificationsFromDatabase
{
    OnYourMindAppDelegate *oymAppDelegate = (OnYourMindAppDelegate*)[[UIApplication sharedApplication] delegate];
    OnYourMindBLL *oymBLL = oymAppDelegate.oymBLL;
    
    [ScheduledAlertManager createLocalNotificationsBasedOnSchedule:[oymBLL selectDayOfWeekAlerts]];
}

+(void)createLocalNotificationsBasedOnSchedule:(NSMutableDictionary*)alertSchedule
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:ScheduledNotificationsEnabled] == YES)
    {
        return;
    }
    
    
    NSArray *daysOfWeek = [[[NSDateFormatter alloc] init] weekdaySymbols];
    NSDate *today = [NSDate date];
    NSDate *notificationFireDate;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents = [gregorian components:(NSWeekdayCalendarUnit) fromDate:today];
    NSInteger weekday = [weekdayComponents weekday] - 1; //adjusting since im using 0 as Sunday, instead of 1
    NSArray *scheduleForDayOfWeek;
    UILocalNotification *notification;
    
    NSDateComponents *dayComponentForAdding = [[NSDateComponents alloc]init];
    AlertSchedule *alert;
    NSDate *tempDate;
    
    for(int i = 0; i < 7; i++)
    {
        scheduleForDayOfWeek = [alertSchedule objectForKey:[daysOfWeek objectAtIndex:weekday]];
        dayComponentForAdding.day = i;
        notificationFireDate = [gregorian dateByAddingComponents:dayComponentForAdding toDate:today options:0];
        
        if(scheduleForDayOfWeek && [scheduleForDayOfWeek count] > 0)
        {
            for(int j = 0; j < [scheduleForDayOfWeek count]; j++)
            {
                alert = [scheduleForDayOfWeek objectAtIndex:j];
                notification = [[UILocalNotification alloc]init];
                tempDate = [ScheduledAlertManager createNewDateWithTheseDateComponents:notificationFireDate andTheseTimeComponents:alert.alertTime usingCalendar:gregorian];
                notification.fireDate = tempDate;
                notification.alertBody = @"Time to review your thoughts!";
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:scheduledNotificationUserInfo];
                notification.repeatInterval = NSWeekCalendarUnit;
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }
        
        if(weekday == 6)
            weekday = 0;
        else
            weekday++;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ScheduledNotificationsEnabled];

}

+(NSDate*)createNewDateWithTheseDateComponents:(NSDate*)dateForDateComponents andTheseTimeComponents:(NSDate*)dateForTimeComponents usingCalendar:(NSCalendar*)calendar
{
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dateForDateComponents];
    NSDateComponents *timeComponents = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:dateForTimeComponents];
    NSDateComponents *newDate = [[NSDateComponents alloc]init];
    
    newDate.year = dateComponents.year;
    newDate.month = dateComponents.month;
    newDate.day = dateComponents.day;
    newDate.hour = timeComponents.hour;
    newDate.minute = timeComponents.minute;
    newDate.second = 0;
    
    
    return [calendar dateFromComponents:newDate];
}



@end
