//
//  ScheduleViewController.h
//  On Your Mind
//
//  Created by Daniel Bradford on 8/25/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScheduleViewController;

@protocol ScheduleViewControllerProtocol <NSObject>

-(void)finishedSchedule;

@end

@interface ScheduleViewController : UIViewController

@property (weak,nonatomic) id <ScheduleViewControllerProtocol> delegate;

@end
