//
//  AddTimeViewController.h
//  On Your Mind
//
//  Created by Daniel Bradford on 9/27/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddTimeViewController;

@protocol AddTimeViewControllerDelegate <NSObject>

-(void)didCancelAddingTime;
-(void)addTimeViewControllerDelegate:(AddTimeViewController*)vc didChooseTime:(NSDate*)chosenTime;

@end

@interface AddTimeViewController : UIViewController
@property (weak,nonatomic) id <AddTimeViewControllerDelegate> delegate;
@end
