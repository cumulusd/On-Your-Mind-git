//
//  DisplayViewController.h
//  On Your Mind
//
//  Created by Daniel Bradford on 6/13/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DisplayViewController;

@protocol DisplayViewControllerDelegate <NSObject>

-(void)userFinished;

@end

@interface DisplayViewController : UIViewController
@property (weak,nonatomic) IBOutlet UIImageView *walkthroughImage;
@property (weak,nonatomic) id <DisplayViewControllerDelegate> delegate;
@property (strong,nonatomic) NSString *imageNameToShow;
@end
