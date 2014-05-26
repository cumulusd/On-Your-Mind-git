//
//  TutorialPageViewController.h
//  On Your Mind
//
//  Created by Daniel Bradford on 8/25/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TutorialPageViewController;

@protocol TutorialPageViewControllerDelegate <NSObject>

-(void)tutorialFinished;

@end

@interface TutorialPageViewController : UIPageViewController
@property (weak,nonatomic) id <TutorialPageViewControllerDelegate> tutorialDelegate;
@end
