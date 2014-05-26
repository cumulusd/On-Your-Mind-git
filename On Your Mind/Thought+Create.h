//
//  Thought+Create.h
//  On Your Mind
//
//  Created by Daniel Bradford on 3/22/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "Thought.h"

@interface Thought (Create)
+(Thought *)createThought:(NSString *)thought withAlertDate:(NSDate*)alertDate andThoughtID:(NSInteger)thoughtID inManagedObjectContext:(NSManagedObjectContext *)context;
@end
