//
//  WelcomeViewController.m
//  On Your Mind
//
//  Created by Daniel Bradford on 11/24/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "WelcomeViewController.h"
#import "ScheduleViewController.h"

@interface WelcomeViewController () <ScheduleViewControllerProtocol,UINavigationBarDelegate>
@property (weak,nonatomic) IBOutlet UINavigationBar *navBar;
@end

@implementation WelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navBar.delegate = self;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[ScheduleViewController class]]) {
        ScheduleViewController *svc = (ScheduleViewController*)segue.destinationViewController;
        svc.delegate = self;
    }
}

- (IBAction)createSchedule:(UIButton *)sender {
    [self performSegueWithIdentifier:@"Schedule" sender:self];
}

- (IBAction)finishUp:(UIButton *)sender {
    [self.delegate finishedWelcome];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ScheduleViewControllerProtocol
-(void)finishedSchedule
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// UINavigationBarDelegate
-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

@end
