//
//  Thought.h
//  On Your Mind
//
//  Created by Daniel Bradford on 9/2/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Thought : NSManagedObject

@property (nonatomic, retain) NSDate * alertDate;
@property (nonatomic, retain) NSDate * archiveDate;
@property (nonatomic, retain) NSDate * entryDate;
@property (nonatomic, retain) NSNumber * isArchived;
@property (nonatomic, retain) NSString * thought;
@property (nonatomic, retain) NSNumber * thoughtID;

@end
