//
//  PastThoughtsViewController.m
//  On Your Mind
//
//  Created by Daniel Bradford on 3/23/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "PastThoughtsViewController.h"
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "ThoughtCell.h"
#import "Thought.h"
#import "UserDefaults.h"
#import "ScheduleViewController.h"
#import "OnYourMindAppDelegate.h"
#import "OnYourMindBLL.h"

@interface PastThoughtsViewController () <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,ThoughtCellDelegate,ScheduleViewControllerProtocol,UINavigationBarDelegate>

@property (weak,nonatomic) IBOutlet UITableView *pastThoughtsTableView;
@property (nonatomic, strong) NSIndexPath *editingIndexPath;
@property (nonatomic,strong) UIActionSheet *actionSheet;
@property (strong,nonatomic) NSMutableArray *pastThoughtsGrouped;
@property (strong,nonatomic) UIImageView *quoteView;
@property (strong,nonatomic) OnYourMindBLL *oymBLL;
@property (weak,nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation PastThoughtsViewController

@synthesize pastThoughtsGrouped = _pastThoughtsGrouped;
@synthesize quoteView = _quoteView;
@synthesize dateFormatter = _dateFormatter;

-(NSDateFormatter*)dateFormatter
{
    if(! _dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

-(NSMutableArray*)pastThoughtsGrouped
{
    if(! _pastThoughtsGrouped)
    {
        _pastThoughtsGrouped = [[NSMutableArray alloc]init];
    }
    return _pastThoughtsGrouped;
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
    [self initEmptyMessage];
    
    OnYourMindAppDelegate *oymAppDelegate = (OnYourMindAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.oymBLL = oymAppDelegate.oymBLL;
    

    self.pastThoughtsTableView.dataSource = self;
    self.pastThoughtsTableView.delegate = self;
    [self.pastThoughtsTableView setScrollsToTop:YES];
    
    self.navBar.delegate = self;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self organizePastThoughtsByMonthYear];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[ScheduleViewController class]])
    {
        ScheduleViewController *svc = (ScheduleViewController*)segue.destinationViewController;
        svc.delegate = self;
    }
}

-(UIImageView*)quoteView
{
    if(! _quoteView)
        _quoteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Quote2.png"]];
    
    return _quoteView;
}

-(void)initEmptyMessage
{
    self.quoteView.frame = CGRectMake(0, 0, 250, 70);
    self.quoteView.translatesAutoresizingMaskIntoConstraints = YES;
    self.quoteView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    self.quoteView.center = [self.view convertPoint:self.view.center fromView:self.view.superview];
    
    self.quoteView.hidden = YES;
    [self.view addSubview:self.quoteView];
}

-(void)organizePastThoughtsByMonthYear
{
    NSArray *fetchResults = [self.oymBLL selectArchivedThoughts];
    NSDate *dateKeyValue, *currentDateKey;
    
    [self.pastThoughtsGrouped removeAllObjects];
    
    if(fetchResults)
    {
        BOOL foundMatch = NO;

        NSMutableArray *sectionContents;
        NSDateComponents *componentsForDateKeyValue;
        NSDateComponents *componentsForThoughtArchiveDate;
        for(Thought *thought in fetchResults)
        {
            foundMatch = NO;

            componentsForDateKeyValue = [[NSDateComponents alloc]init];
            componentsForThoughtArchiveDate = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:thought.archiveDate ];
            
            componentsForDateKeyValue.day = 1;
            componentsForDateKeyValue.month = componentsForThoughtArchiveDate.month;
            componentsForDateKeyValue.year = componentsForThoughtArchiveDate.year;
            
            dateKeyValue = [[NSCalendar currentCalendar] dateFromComponents:componentsForDateKeyValue];
            
            
            if([self.pastThoughtsGrouped count] == 0)
            {
                sectionContents = [[NSMutableArray alloc] initWithObjects:thought, nil];
                [self.pastThoughtsGrouped addObject:sectionContents];
                currentDateKey = [[NSCalendar currentCalendar] dateFromComponents:componentsForDateKeyValue];
            }
            else{
                if(dateKeyValue == currentDateKey)
                {
                    [sectionContents addObject:thought];
                }
                else{
                    sectionContents = [[NSMutableArray alloc] initWithObjects:thought, nil];
                    [self.pastThoughtsGrouped addObject:sectionContents];
                    currentDateKey = [[NSCalendar currentCalendar] dateFromComponents:componentsForDateKeyValue];

                }
            }
        }
        
        [self.pastThoughtsTableView reloadData];
    }
}


// Past Thought Options
- (IBAction)optionsPressed:(UIBarButtonItem *)sender {
    
    if(! _actionSheet)
    {
        NSString *toggleText;
        
        if([self willArchiveDeletedThoughts])
            toggleText = @"Stop Archiving Thoughts";
        else
            toggleText = @"Start Archiving Thoughts";
        
        self.actionSheet = [[UIActionSheet alloc]initWithTitle:@"Configure options:" delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:@"Delete All Past Thoughts" otherButtonTitles:toggleText, @"Show Welcome Message", @"Configure Schedule", nil];
        [self.actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.destructiveButtonIndex)
    {
        UIAlertView *confirmation = [[UIAlertView alloc]initWithTitle:@"Confirm Deletion" message:@"Are you sure you want to remove all past thoughts? This is not recoverable." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        
        [confirmation show];
    }
    else if(buttonIndex == 1)
    {
        [[NSUserDefaults standardUserDefaults] setBool:(! [self willArchiveDeletedThoughts]) forKey:ArchiveOnDelete];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
    else if(buttonIndex == 2)
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:HasUserSeenIntroduction];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.tabBarController setSelectedIndex:0];
    }
    else if( buttonIndex == 3)
    {
        [self performSegueWithIdentifier:@"Schedule" sender:self];
    }
    
    self.actionSheet = nil;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != alertView.cancelButtonIndex)
    {
        for(int i = 0; i < [self.pastThoughtsGrouped count]; i++)
        {
            NSMutableArray *contents = (NSMutableArray*)[self.pastThoughtsGrouped objectAtIndex:i];
            for (int j = 0; j < [contents count]; j++) {
                Thought *thought = (Thought*)[contents objectAtIndex:j];
                [self.oymBLL deleteThought:thought];
            }
        }
        [self.pastThoughtsGrouped removeAllObjects];
        
        [self.pastThoughtsTableView reloadData];
    }
}

// User Settings

-(BOOL)willArchiveDeletedThoughts
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:ArchiveOnDelete];
}

// TableView Delegate & Data Source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ThoughtCell";
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    ThoughtCell *tcell = (ThoughtCell*)cell;
    
    if(cell.backgroundView == nil)
    {
        CALayer *textViewLayer = [tcell.textView layer];
        [textViewLayer setCornerRadius:14.0];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graybubble6.png"]];
        tcell.delegate = self;
    }
    
    NSArray *sectionValues = [self.pastThoughtsGrouped objectAtIndex:indexPath.section];
    
    Thought *thought = [sectionValues objectAtIndex:indexPath.row];
    tcell.textView.text = thought.thought;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSMutableArray *sectionValues = [self.pastThoughtsGrouped objectAtIndex:indexPath.section];
        
        Thought *thoughtToDelete = [sectionValues objectAtIndex:indexPath.row];
        
        [self.oymBLL deleteThought:thoughtToDelete];
        
        [sectionValues removeObjectAtIndex:indexPath.row];
        
        if([sectionValues count] == 0)
        {
            [self.pastThoughtsTableView beginUpdates];
            [self.pastThoughtsGrouped removeObjectAtIndex:indexPath.section];
            [self.pastThoughtsTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            [self.pastThoughtsTableView endUpdates];
        }
        else{
            [self.pastThoughtsTableView cellForRowAtIndexPath:indexPath].backgroundView = nil;
            [self.pastThoughtsTableView beginUpdates];
            [self.pastThoughtsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.pastThoughtsTableView endUpdates];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger count = [self.pastThoughtsGrouped count]; //[self.pastThoughtsGrouped.allKeys count];
    self.quoteView.hidden = (count > 0);
    return count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *contents = (NSMutableArray*)[self.pastThoughtsGrouped objectAtIndex:section];
    return [contents count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSMutableArray *contents = [self.pastThoughtsGrouped objectAtIndex:section];
    Thought *theThought = (Thought*)[contents objectAtIndex:0];
    
    NSDate *keyForSection = theThought.archiveDate; //[[self.pastThoughtsGrouped allKeys] objectAtIndex:section];
    NSString *year, *month;
    [self.dateFormatter setDateFormat:@"yyyy"];
    year = [self.dateFormatter stringFromDate:keyForSection];
    [self.dateFormatter setDateFormat:@"MMMM"];
    month = [self.dateFormatter stringFromDate:keyForSection];
    return [NSString stringWithFormat:@"%@ %@", month,year];
}

// ThoughtCellDelegate
-(void)showActivitesForCell:(UITableViewCell *)cell
{
    ThoughtCell *chosenCell = (ThoughtCell*)cell;
    NSArray *activityItems = [NSArray arrayWithObject:chosenCell.textView.text];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    avc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:avc animated:YES completion:nil];
}

-(void)cellSelected:(UITableViewCell *)cell
{
    return;
}

// ScheduleViewControllerDelegate
-(void)finishedSchedule
{
    [self dismissViewControllerAnimated:true completion:nil];
}

// UINavigationBarDelegate
-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}


@end
