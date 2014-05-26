//
//  ScheduleViewController.m
//  On Your Mind
//
//  Created by Daniel Bradford on 8/25/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "ScheduleViewController.h"
#import "OnYourMindBLL.h"
#import "OnYourMindAppDelegate.h"
#import "AlertSchedule.h"
#import "AlertSchedule+Create.h"
#import "ScheduledAlertManager.h"
#import "AddTimeViewController.h"

@interface ScheduleViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, AddTimeViewControllerDelegate,UINavigationBarDelegate>

@property (strong,readonly,nonatomic) NSArray *daysOfWeek;
@property (weak,nonatomic) IBOutlet UITableView *scheduleTable;
@property (weak, nonatomic) IBOutlet UITableView *alertTimesForDayTable;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UIView *viewWithTableView;

@property (weak, nonatomic) IBOutlet UIView *viewAddTimesToDayOfWeek;

@property (weak,nonatomic) IBOutlet UIView *containerAddTimeToDay;

@property (weak,nonatomic) OnYourMindBLL *oymBLL;

@property (strong,nonatomic) NSMutableDictionary *alertsByDay;

@property (strong,nonatomic) NSDateFormatter *dateFormatter;

@property (strong,nonatomic) NSCalendar *calendar;

@end

@implementation ScheduleViewController

BOOL isPresentingDay;

@synthesize daysOfWeek = _daysOfWeek;
@synthesize dateFormatter = _dateFormatter;
@synthesize calendar = _calendar;

-(NSCalendar*)calendar
{
    if(! _calendar)
    {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    return _calendar;
}

-(NSDateFormatter*)dateFormatter
{
    if(! _dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return _dateFormatter;
}

-(NSArray *)daysOfWeek
{
    if(! _daysOfWeek)
    {
        _daysOfWeek = [self.dateFormatter weekdaySymbols];
    }
    return _daysOfWeek;
}

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
    self.oymBLL = oymAppDelegate.oymBLL;
    
    self.alertsByDay = [self.oymBLL selectDayOfWeekAlerts];
    
    self.scheduleTable.dataSource = self;
    self.scheduleTable.delegate = self;
    
    self.alertTimesForDayTable.dataSource = self;
    self.alertTimesForDayTable.delegate = self;

    self.navBar.delegate = self;
    
    NSArray *children = self.childViewControllers;
    AddTimeViewController *atvc = (AddTimeViewController*)[children objectAtIndex:0];
    atvc.delegate = self;
    
    isPresentingDay = NO;
    
    [ScheduledAlertManager cancelAllScheduleBasedLocalNotifications];
    
    [self configureBarButtonItems];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Bar button item actions

-(void)configureBarButtonItems
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:nil];
    doneButton.tintColor = [UIColor whiteColor];
    
    self.navItem.rightBarButtonItem = nil;
    self.navItem.leftBarButtonItem = nil;
    
    if(isPresentingDay)
    {
        UIBarButtonItem *addTimeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTimeToDay)];
        addTimeButton.tintColor = [UIColor whiteColor];
        
        doneButton.action = @selector(doneShowingDay);
        
        self.navItem.leftBarButtonItem = doneButton;
        self.navItem.rightBarButtonItem = addTimeButton;
    }
    else
    {
        doneButton.action = @selector(doneShowingSchedule);
        self.navItem.rightBarButtonItem = doneButton;
    }
    
}

-(void)doneShowingSchedule
{
    if([[self.oymBLL selectActiveThoughts] count] > 0)
        [ScheduledAlertManager createLocalNotificationsBasedOnSchedule:self.alertsByDay];
    
    [self.delegate finishedSchedule];
}

-(void)doneShowingDay
{
    isPresentingDay = NO;
    self.navItem.title = @"Schedule";
    [self configureBarButtonItems];
    [self.scheduleTable reloadData];

    [UIView transitionFromView:self.viewAddTimesToDayOfWeek toView:self.viewWithTableView duration:0.7 options:UIViewAnimationOptionTransitionCurlUp | UIViewAnimationOptionShowHideTransitionViews completion:^(BOOL finished){
        
        [self.alertTimesForDayTable reloadData];
    }];
}

-(void)addTimeToDay
{
    [self configurePresentationOfContainerViewWithDatePicker:YES];
}

-(void)configurePresentationOfContainerViewWithDatePicker:(bool)isPresenting
{
    if(isPresenting)
    {
        self.containerAddTimeToDay.hidden = NO;
        self.alertTimesForDayTable.userInteractionEnabled = NO;
        self.navItem.rightBarButtonItem.enabled = NO;
        self.navItem.leftBarButtonItem.enabled = NO;
    }
    else{
        self.containerAddTimeToDay.hidden = YES;
        self.alertTimesForDayTable.userInteractionEnabled = YES;
        self.navItem.rightBarButtonItem.enabled = YES;
        self.navItem.leftBarButtonItem.enabled = YES;

    }
}

-(NSDate*)assembleDate:(NSDate*)fromDate
{
    NSDateComponents *components = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:fromDate];
    
    [components setSecond:0];
    [components setCalendar:self.calendar];
    
    return [components date];
}


// UITableView delegate & data source

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DayCell";
    static NSString *CellIdentifierTime = @"TimeCell";
    
    AlertSchedule *singleAlertDateForDay;
    NSArray *alertTimesForDay;
    UITableViewCell *cell = nil;
    
    if(tableView == self.scheduleTable)
    {
        NSMutableString *timeString = [NSMutableString stringWithString:@""];
        alertTimesForDay = [self.alertsByDay objectForKey:[self.daysOfWeek objectAtIndex:indexPath.row]];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = [self.daysOfWeek objectAtIndex:indexPath.row];
        
        for(int i = 0; i < [alertTimesForDay count]; i++)
        {
            singleAlertDateForDay = [alertTimesForDay objectAtIndex:i];
            if(i == 0)
                [timeString appendFormat:@"%@", [self.dateFormatter stringFromDate:singleAlertDateForDay.alertTime]];
            else
                [timeString appendFormat:@", %@", [self.dateFormatter stringFromDate:singleAlertDateForDay.alertTime]];
        }
        
        if([alertTimesForDay count] > 0)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.detailTextLabel.text = timeString;
    }
    else if (tableView == self.alertTimesForDayTable)
    {
        alertTimesForDay = [self.alertsByDay objectForKey:self.navItem.title];
        singleAlertDateForDay = [alertTimesForDay objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTime];
        cell.textLabel.text = [self.dateFormatter stringFromDate:singleAlertDateForDay.alertTime];
    }
    
    return cell;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if(tableView == self.scheduleTable)
        count = [self.daysOfWeek count];
    else if(tableView == self.alertTimesForDayTable)
    {
        if(isPresentingDay)
        {
            NSArray *times = [self.alertsByDay objectForKey:self.navItem.title ];
            count = [times count];
        }
        else
            count = 0;
    }
    
    return count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    isPresentingDay = YES;
    self.navItem.title = [self.daysOfWeek objectAtIndex:indexPath.row];
    [self configureBarButtonItems];

    [self.alertTimesForDayTable reloadData];
    [UIView transitionFromView:self.viewWithTableView toView:self.viewAddTimesToDayOfWeek duration:0.7 options:UIViewAnimationOptionTransitionCurlDown | UIViewAnimationOptionShowHideTransitionViews completion:^(BOOL finished) {
    }];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        if(tableView == self.alertTimesForDayTable)
        {
            NSMutableArray *timesForDay = [self.alertsByDay objectForKey:self.navItem.title ];
            [self.oymBLL deleteAlertSchedule:[timesForDay objectAtIndex:indexPath.row]];
            [timesForDay removeObjectAtIndex:indexPath.row];
            [self.alertTimesForDayTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.alertTimesForDayTable reloadData];
        }
        else if(tableView == self.scheduleTable)
        {
            NSMutableArray *alertTimesForDay = [self.alertsByDay objectForKey:[self.daysOfWeek objectAtIndex:indexPath.row]];
            for(int i = 0; i < [alertTimesForDay count]; i++)
            {
                [self.oymBLL deleteAlertSchedule:[alertTimesForDay objectAtIndex:i]];
            }
            [alertTimesForDay removeAllObjects];
            [self.scheduleTable reloadData];
        }
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.scheduleTable)
        return @"Clear";
    else
        return @"Delete";
}

// AddTimeViewControllerDelegate
-(void)didCancelAddingTime
{
    [self configurePresentationOfContainerViewWithDatePicker:NO];
}

-(void)addTimeViewControllerDelegate:(AddTimeViewController *)vc didChooseTime:(NSDate *)chosenTime
{
    AlertSchedule *current;
    NSDate *cleanDateTime = [self assembleDate:chosenTime];
    NSMutableArray *timesForDay = [self.alertsByDay objectForKey:self.navItem.title];
    
    for(int i = 0; i < [timesForDay count]; i++)
    {
        current = (AlertSchedule*)[timesForDay objectAtIndex:i];
        if([cleanDateTime compare:current.alertTime] == NSOrderedSame)
        {
            return;
        }
    }
    
    [timesForDay addObject:[self.oymBLL createScheduledAlertForDay:self.navItem.title withTime:cleanDateTime]];
    [self.alertTimesForDayTable reloadData];
    //[self configurePresentationOfContainerViewWithDatePicker:NO];
}

// UINavigationBarDelegate
-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}


@end
