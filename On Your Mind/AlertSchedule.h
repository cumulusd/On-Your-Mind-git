//
//  AlertSchedule.h
//  On Your Mind
//
//  Created by Daniel Bradford on 9/2/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AlertSchedule : NSManagedObject

@property (nonatomic, retain) NSString * dayOfWeek;
@property (nonatomic, retain) NSDate * alertTime;

@end
