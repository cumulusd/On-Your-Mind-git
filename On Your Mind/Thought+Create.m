//
//  Thought+Create.m
//  On Your Mind
//
//  Created by Daniel Bradford on 3/22/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "Thought+Create.h"

@implementation Thought (Create)

+(Thought *)createThought:(NSString *)thought withAlertDate:(NSDate*)alertDate andThoughtID:(NSInteger)thoughtID inManagedObjectContext:(NSManagedObjectContext *)context
{
    Thought *newThought;
    newThought = [NSEntityDescription insertNewObjectForEntityForName:@"Thought" inManagedObjectContext:context];
    newThought.thought = thought;
    newThought.entryDate = [NSDate date];
    newThought.isArchived = [NSNumber numberWithBool:NO];
    newThought.alertDate = alertDate;
    newThought.thoughtID = [NSNumber numberWithInteger:thoughtID];
    
    return newThought;
}



@end
