//
//  ScheduledAlertManager.h
//  On Your Mind
//
//  Created by Daniel Bradford on 9/7/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScheduledAlertManager : NSObject

+(void)cancelAllScheduleBasedLocalNotifications;
+(void)createLocalNotificationsBasedOnSchedule:(NSMutableDictionary*)alertSchedule;
+(void)createLocalNotificationsFromDatabase;

@end
