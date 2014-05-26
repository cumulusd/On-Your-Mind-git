//
//  AddTimeViewController.m
//  On Your Mind
//
//  Created by Daniel Bradford on 9/27/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "AddTimeViewController.h"

@interface AddTimeViewController ()
@property (weak,nonatomic) IBOutlet UIDatePicker *datePicker;
@end

@implementation AddTimeViewController

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
    
    self.datePicker.minuteInterval = 5;
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    self.datePicker.date = [NSDate date];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didCancel:(UIBarButtonItem *)sender
{
    [self.delegate didCancelAddingTime];
}

- (IBAction)didAddTime:(UIBarButtonItem *)sender
{
    [self.delegate addTimeViewControllerDelegate:self didChooseTime:self.datePicker.date];
}


@end
