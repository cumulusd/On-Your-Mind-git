//
//  OnYourMindBLL.m
//  On Your Mind
//
//  Created by Daniel Bradford on 8/27/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "OnYourMindBLL.h"
#import "Thought.h"
#import "Thought+Create.h"
#import "UserDefaults.h"
#import "AlertSchedule.h"
#import "AlertSchedule+Create.h"

@interface OnYourMindBLL ()

@property (strong,nonatomic) UIManagedDocument *onYourMindDatabase; // Model is core data database of 'Thought'
@property (strong,nonatomic) NSPersistentStoreCoordinator *storeCoordinator;

@end

@implementation OnYourMindBLL

@synthesize onYourMindDatabase = _onYourMindDatabase;

-(id)init
{
    if(self = [super init])
    {
        
    }
    return self;
}

-(void)openDatabase
{
    if(!self.onYourMindDatabase)
    {
        self.onYourMindDatabase = [[UIManagedDocument alloc]initWithFileURL:[self physicalDataLocation]];
    }
    
}

-(void)deleteThought:(Thought*)thought
{
    [self.onYourMindDatabase.managedObjectContext deleteObject:thought];
    [self.onYourMindDatabase.managedObjectContext save:nil];
}

-(NSMutableArray*)selectActiveThoughts
{
    return [self selectThoughts:YES];
}

-(NSMutableArray*)selectArchivedThoughts
{
    return [self selectThoughts:NO];
}

-(NSDictionary*)selectDayOfWeekAlerts
{
    NSMutableDictionary *alerts = [[NSMutableDictionary alloc]init];
    NSArray *daysOfWeek = [[[NSDateFormatter alloc] init] weekdaySymbols];
    NSArray *unorganizedAlerts = [self selectAllDayOfWeekAlerts];
    NSArray *filteredAlerts;
    NSPredicate *daySearch;
    NSSortDescriptor *sorting = [[NSSortDescriptor alloc] initWithKey:@"alertTime" ascending:YES];
    
    for(int i = 0; i < [daysOfWeek count]; i++)
    {
        if([alerts objectForKey:[daysOfWeek objectAtIndex:i]] == nil)
        {
            [alerts setObject:[[NSMutableArray alloc]init] forKey:[daysOfWeek objectAtIndex:i]];
        }
        daySearch = [NSPredicate predicateWithFormat:@"dayOfWeek = %@", [daysOfWeek objectAtIndex:i]];
        filteredAlerts = [unorganizedAlerts filteredArrayUsingPredicate:daySearch];
        filteredAlerts = [filteredAlerts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorting]];
        
        for(int j = 0; j < [filteredAlerts count]; j++)
        {
            [((NSMutableArray*) [alerts objectForKey:[daysOfWeek objectAtIndex:i]]) addObject:[filteredAlerts objectAtIndex:j]];
        }
    }
    
    return alerts;
}

-(void)updateThought:(Thought*)thought withThought:(NSString*)thoughtText andNotificationDate:(NSDate*)alertDate
{
    thought.thought = thoughtText;
    thought.alertDate = alertDate;
    
    [self cancelLocalNotification:[thought.thoughtID integerValue]];
    if(alertDate)
    {
        [self scheduleLocalNotification:thoughtText withFiredate:alertDate andThoughtID:[thought.thoughtID integerValue]];
    }
}

-(Thought*)createNewThought:(NSString*)thoughtText andNotificationDate:(NSDate*)alertDate
{
    NSInteger nextThoughtID = [self nextThoughtID];
    
    if(alertDate)
    {
        [self scheduleLocalNotification:thoughtText withFiredate:alertDate andThoughtID:nextThoughtID];
    }
    
    return [Thought createThought:thoughtText withAlertDate:alertDate andThoughtID:nextThoughtID inManagedObjectContext:self.onYourMindDatabase.managedObjectContext];
}

-(void)cancelLocalNotification:(NSInteger)thoughtID
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *currentNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        UILocalNotification *notification = nil;
        NSDictionary *userInfo = nil;
        NSNumber *notificationThoughtID = nil;
        
        for(int i = 0; i < [currentNotifications count]; i++)
        {
            notification = (UILocalNotification*) [currentNotifications objectAtIndex:i];
            userInfo = notification.userInfo;
            notificationThoughtID = (NSNumber*)[userInfo objectForKey:NotificationUserInfoKey];
            if([notificationThoughtID integerValue] == thoughtID)
            {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                return;
            }
        }
    });
}

-(AlertSchedule*)createScheduledAlertForDay:(NSString*)dayOfWeek withTime:(NSDate*)alertdate
{
    return [AlertSchedule saveAlertScheduleForDayOfWeek:dayOfWeek withAlertTime:alertdate inManagedObjectContext:self.onYourMindDatabase.managedObjectContext];
}

-(void)deleteAlertSchedule:(AlertSchedule*)alertSchedule
{
    [self.onYourMindDatabase.managedObjectContext deleteObject:alertSchedule];
}

// ---------------------------------------------------------------------------------

-(NSURL*)physicalDataLocation
{
    NSURL* url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:OnYourMindDatabaseName];
    return url;
}

-(void)scheduleLocalNotification:(NSString*)alertBody withFiredate:(NSDate*)fireDate andThoughtID:(NSInteger)thoughtID
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = alertBody;
    notification.fireDate = fireDate;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:thoughtID] forKey:NotificationUserInfoKey];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

-(void)setOnYourMindDatabase:(UIManagedDocument *)onYourMindDatabase
{
    if(_onYourMindDatabase != onYourMindDatabase)
    {
        _onYourMindDatabase = onYourMindDatabase;
        
        _onYourMindDatabase.persistentStoreOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:[self.onYourMindDatabase.fileURL path]])
        {
            [self.onYourMindDatabase saveToURL:self.onYourMindDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
                if(success)
                {
                    [self databaseReady];
                }
            }];
        }
        else if(self.onYourMindDatabase.documentState == UIDocumentStateClosed)
        {
            [self.onYourMindDatabase openWithCompletionHandler:^(BOOL success){
                if(success)[self databaseReady];
            }];
        }
        else if(self.onYourMindDatabase.documentState == UIDocumentStateNormal)
        {
            [self databaseReady];
        }
    }
}

-(void)databaseReady
{

    [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseReady object:nil];
}

-(NSDate*)createDateWithYear:(int)year andMonth:(int)month
{
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate: date];
    
    components.year = year;
    components.month = month;
    components.day = 1;
    
    NSDate *newDate = [gregorian dateFromComponents: components];
    
    return newDate;
}

-(NSMutableArray*)selectThoughts:(BOOL)active
{
    NSMutableArray *results;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Thought"];
    
    if(active)
    {
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"entryDate" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"isArchived == 0"];
    }
    else
    {
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"archiveDate" ascending:NO]];
        request.predicate = [NSPredicate predicateWithFormat:@"isArchived == 1"];
    }
    
    results = [NSMutableArray arrayWithArray:[self.onYourMindDatabase.managedObjectContext executeFetchRequest:request error:nil]];
    
    return results;
}

-(NSArray*)selectAllDayOfWeekAlerts
{
    NSArray *results;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AlertSchedule"];
        
    results = [NSMutableArray arrayWithArray:[self.onYourMindDatabase.managedObjectContext executeFetchRequest:request error:nil]];
    
    return results;
}

-(NSInteger)nextThoughtID
{
    NSInteger thoughtID = 0;
    
    thoughtID = [[NSUserDefaults standardUserDefaults] integerForKey:ThoughtIDSeed];
    [[NSUserDefaults standardUserDefaults] setInteger:thoughtID + 1 forKey:ThoughtIDSeed];
    
    return thoughtID;
}


@end
