//
//  OnYourMindAppDelegate.h
//  On Your Mind
//
//  Created by Daniel Bradford on 3/22/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnYourMindBLL.h"

@interface OnYourMindAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong,nonatomic) OnYourMindBLL *oymBLL;

@property (readonly,strong,nonatomic) UIDatePicker *datePicker;

@end
