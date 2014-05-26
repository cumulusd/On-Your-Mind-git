//
//  WelcomeViewController.h
//  On Your Mind
//
//  Created by Daniel Bradford on 11/24/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WelcomeViewController;

@protocol WelcomeViewControllerDelegate <NSObject>

-(void)finishedWelcome;

@end

@interface WelcomeViewController : UIViewController
@property (weak, nonatomic) id <WelcomeViewControllerDelegate> delegate;
@end
