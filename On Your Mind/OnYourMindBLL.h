//
//  OnYourMindBLL.h
//  On Your Mind
//
//  Created by Daniel Bradford on 8/27/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Thought.h"
#import "AlertSchedule+Create.h"

@interface OnYourMindBLL : NSObject
-(id)init;
-(void)openDatabase;

-(NSMutableArray*)selectActiveThoughts;
-(NSMutableArray*)selectArchivedThoughts;
-(NSMutableDictionary*)selectDayOfWeekAlerts;

-(void)deleteThought:(Thought*)thought;
-(void)cancelLocalNotification:(NSInteger)thoughtID;
-(void)updateThought:(Thought*)thought withThought:(NSString*)thoughtText andNotificationDate:(NSDate*)alertDate;
-(Thought*)createNewThought:(NSString*)thoughtText andNotificationDate:(NSDate*)alertDate;

-(AlertSchedule*)createScheduledAlertForDay:(NSString*)dayOfWeek withTime:(NSDate*)alertdate;
-(void)deleteAlertSchedule:(AlertSchedule*)alertSchedule;

@end
