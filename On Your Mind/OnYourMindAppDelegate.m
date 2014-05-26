//
//  OnYourMindAppDelegate.m
//  On Your Mind
//
//  Created by Daniel Bradford on 3/22/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "OnYourMindAppDelegate.h"
#import "OnYourMindBLL.h"
#import "UserDefaults.h"

@interface OnYourMindAppDelegate ()
@end

@implementation OnYourMindAppDelegate

@synthesize oymBLL = _oymBLL;
@synthesize datePicker = _datePicker;

-(UIDatePicker*)datePicker
{
    if(! _datePicker)
    {
        _datePicker = [[UIDatePicker alloc]init];
    }
    return _datePicker;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    self.oymBLL = [[OnYourMindBLL alloc]init];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:ArchiveOnDelete] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ArchiveOnDelete];
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:ThoughtIDSeed] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:ThoughtIDSeed];
    }

    if([[NSUserDefaults standardUserDefaults] objectForKey:ScheduledNotificationsEnabled] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ScheduledNotificationsEnabled];
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:HasUserSeenIntroduction] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:HasUserSeenIntroduction];
    }

    
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
