//
//  ThoughtViewController.m
//  On Your Mind
//
//  Created by Daniel Bradford on 3/23/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "ThoughtViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "OnYourMindAppDelegate.h"

@interface ThoughtViewController () <UITextViewDelegate,UIActionSheetDelegate,UITextFieldDelegate,UINavigationBarDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong,nonatomic) NSDate* currentDateForDatePicker;
@property (weak, nonatomic) IBOutlet UITextField *txtRecallThought;
@property (weak, nonatomic) UIDatePicker *datePicker;
@property (readonly, strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak,nonatomic) IBOutlet UINavigationBar *navBar;
@end

@implementation ThoughtViewController

@synthesize dateFormatter = _dateFormatter;

-(NSDateFormatter*)dateFormatter
{
    if(! _dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc]init];
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return _dateFormatter;
}

BOOL hasReminderDate = NO;

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
    
    OnYourMindAppDelegate *oymAppDelegate = (OnYourMindAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.datePicker = oymAppDelegate.datePicker;
    [self.datePicker setFrame:CGRectMake(0,236.0,self.view.frame.size.width, 216.0)];
    self.datePicker.hidden = YES;
    [self.datePicker addTarget:self action:@selector(didChangeSelectedDate:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.datePicker];
    
    self.textView.text = self.editingThought;
    self.textView.delegate = self;
    
    self.txtRecallThought.delegate = self;
    
    self.navBar.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.textView becomeFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.txtRecallThought.inputView = self.datePicker;
    if(self.reminderDate)
    {
        hasReminderDate = YES;
        self.datePicker.date = self.reminderDate;
        [self didChangeSelectedDate:self];
    }
    else
    {
        hasReminderDate = NO;
        self.txtRecallThought.text = @"Tap to set";
    }
    
    self.datePicker.minimumDate = [[NSDate date] dateByAddingTimeInterval:60.0];
    
    self.currentDateForDatePicker = [NSDate date];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.datePicker removeTarget:self action:@selector(didChangeSelectedDate:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [self.delegate thoughtViewControllerCancelled];
}

- (IBAction)donePressed:(UIBarButtonItem *)sender {
    if([self.textView.text length])
    {
        NSDate *reminderDate;
        
        if(hasReminderDate)
            reminderDate = [self assembleDate:self.datePicker.date];
        
        [self.delegate thoughtViewController:self hasThought:[self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                               withAlertDate:reminderDate];
    }
    else{
        [self cancelPressed:nil];
    }

}

- (IBAction)copyThoughtToClipboard:(UIButton *)sender {
    
    if([self.textView.text length])
    {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:self.textView.text];
    }
}


-(NSDate*)assembleDate:(NSDate*)fromDate
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:fromDate];
    
    [components setSecond:0];
    [components setCalendar:[NSCalendar currentCalendar]];
    
    return [components date];
}


- (IBAction)clearReminder:(UIButton *)sender {
    
    hasReminderDate = NO;
    self.txtRecallThought.text = @"";
}

// Date Picker

-(void)didChangeSelectedDate:(id)sender
{
    self.txtRecallThought.text = [NSString stringWithFormat:@"%@", [self.dateFormatter stringFromDate:self.datePicker.date]];
    hasReminderDate = YES;
}

// UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self didChangeSelectedDate:self];
    self.datePicker.hidden = NO;
}

// UINavigationBarDelegate
-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}


@end
