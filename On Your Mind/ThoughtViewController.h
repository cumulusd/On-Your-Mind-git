//
//  ThoughtViewController.h
//  On Your Mind
//
//  Created by Daniel Bradford on 3/23/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThoughtViewController;

@protocol ThoughtViewControllerDelegate <NSObject>

-(void)thoughtViewControllerCancelled;
-(void)thoughtViewController:(ThoughtViewController*)sender hasThought:(NSString*)thought withAlertDate:(NSDate*)alertDate;

@end

@interface ThoughtViewController : UIViewController

@property (weak,nonatomic) id <ThoughtViewControllerDelegate> delegate;
@property (copy,nonatomic) NSString* editingThought;
@property (copy,nonatomic) NSDate* reminderDate;

@end
