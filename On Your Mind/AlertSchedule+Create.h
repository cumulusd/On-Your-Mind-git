//
//  AlertSchedule+Create.h
//  On Your Mind
//
//  Created by Daniel Bradford on 9/2/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "AlertSchedule.h"

@interface AlertSchedule (Create)
+(AlertSchedule*)saveAlertScheduleForDayOfWeek:(NSString*)dayOfWeek withAlertTime:(NSDate*)alertTime inManagedObjectContext:(NSManagedObjectContext*)context;
@end
