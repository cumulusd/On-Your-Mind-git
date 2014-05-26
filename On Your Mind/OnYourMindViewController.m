//
//  OnYourMindViewController.m
//  On Your Mind
//
//  Created by Daniel Bradford on 3/22/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "OnYourMindViewController.h"
#import "ThoughtCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ThoughtViewController.h"
#import "UserDefaults.h"
#import "Thought+Create.h"
#import "PastThoughtsViewController.h"
#import "OnYourMindAppDelegate.h"
#import "OnYourMindBLL.h"
#import "ScheduledAlertManager.h"
#import "WelcomeViewController.h"

@interface OnYourMindViewController () <UITableViewDataSource,UITableViewDelegate,ThoughtViewControllerDelegate,ThoughtCellDelegate,UINavigationBarDelegate,WelcomeViewControllerDelegate>

@property (weak,nonatomic) IBOutlet UITableView *onYourMindTableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (strong,nonatomic) NSMutableArray *onYourMindArray;
@property (nonatomic, strong) NSIndexPath *editingIndexPath;

@property (strong,nonatomic) UIImageView *quoteView;

@property (nonatomic) BOOL flag_tableView_numberOfRowsInSectionHasBeenCalled;

@property (strong,nonatomic) OnYourMindBLL *oymBLL;

@end

@implementation OnYourMindViewController


@synthesize quoteView = _quoteView;


BOOL viewWillAppearHasBeenCalled = NO;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    OnYourMindAppDelegate *oymAppDelegate = (OnYourMindAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.oymBLL = oymAppDelegate.oymBLL;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseReady) name:DatabaseReady object:nil];
    
    [self.oymBLL openDatabase];
    
    self.flag_tableView_numberOfRowsInSectionHasBeenCalled = NO;
    self.onYourMindTableView.delegate = self;
    self.onYourMindTableView.dataSource = self;
    
    self.navBar.delegate = self;
    
    [self.onYourMindTableView setScrollsToTop:YES];
    
    [self initEmptyMessage];
}

-(UIImageView*)quoteView
{
    if(! _quoteView)
        _quoteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Quote.png"]];
    
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadTableViewIfRequired];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(! [self hasSeenIntroduction])
    {
        [self performSegueWithIdentifier:@"Welcome" sender:self];
    }
}

-(void)reloadTableViewIfRequired
{
    if(viewWillAppearHasBeenCalled)
        [self.onYourMindTableView reloadData];
    else
        viewWillAppearHasBeenCalled = YES;
}

-(void)appDidEnterForeground:(NSNotification*)notification
{
    [self reloadTableViewIfRequired];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[ThoughtViewController class]])
    {
        ThoughtViewController *tvc = (ThoughtViewController*)segue.destinationViewController;
        tvc.delegate = self;
        
        if([segue.identifier isEqualToString:@"Edit Thought"])
        {
            self.editingIndexPath = [self.onYourMindTableView indexPathForCell:sender];
            Thought *thoughtBeingEdited = [self.onYourMindArray objectAtIndex:self.editingIndexPath.row];
            tvc.editingThought = thoughtBeingEdited.thought;
            if(thoughtBeingEdited.alertDate)
                tvc.reminderDate = thoughtBeingEdited.alertDate;
        }
        else
            self.editingIndexPath = nil;
    }
    else if([segue.destinationViewController isKindOfClass:[WelcomeViewController class]])
    {
        WelcomeViewController *wvc = (WelcomeViewController*)segue.destinationViewController;
        wvc.delegate = self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// oymBLL

-(void)databaseReady
{
    self.onYourMindArray = [self.oymBLL selectActiveThoughts];
    [self.onYourMindTableView reloadData];
}

// NSUserDefaults

-(BOOL)willArchiveDeletedThoughts
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:ArchiveOnDelete];
}

-(BOOL)hasSeenIntroduction
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:HasUserSeenIntroduction];
}

// Table View Delegates for self.onYourMindTableView

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ThoughtCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    ThoughtCell *tcell = (ThoughtCell*)cell;
    
    if(cell.backgroundView == nil)
    {
        CALayer *textViewLayer = [tcell.textView layer];
        [textViewLayer setCornerRadius:14.0];
        tcell.delegate = self;
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"orangebubble6.png"]];
    }
    
    Thought *thoughtForRowAtIndexPath = [self.onYourMindArray objectAtIndex:indexPath.row];
    tcell.textView.text = thoughtForRowAtIndexPath.thought;
   
    tcell.imgExclamation.hidden = YES;
    tcell.imgExclamationRed.hidden = YES;
    
    if(thoughtForRowAtIndexPath.alertDate)
    {
        if([thoughtForRowAtIndexPath.alertDate compare:[NSDate date]] == NSOrderedDescending)
        {
            tcell.imgExclamation.hidden = NO;
        }
        else{
            tcell.imgExclamationRed.hidden = NO;
        }
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        Thought *thought = [self.onYourMindArray objectAtIndex:indexPath.row];

        [self.oymBLL cancelLocalNotification:[thought.thoughtID integerValue]];
        
        if([self willArchiveDeletedThoughts])
        {
            thought.isArchived = [NSNumber numberWithBool:YES];
            thought.archiveDate = [NSDate date];
        }
        else
        {
            [self.oymBLL deleteThought:thought];
        }
        
        [self.onYourMindArray removeObjectAtIndex:indexPath.row];
        
        [tableView beginUpdates];
        
        [self.onYourMindTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];

    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([self willArchiveDeletedThoughts])
    {
        return @"Archive";
    }
    else{
        return @"Delete";
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = [self.onYourMindArray count];
    
    if(self.flag_tableView_numberOfRowsInSectionHasBeenCalled == NO)
        self.flag_tableView_numberOfRowsInSectionHasBeenCalled = YES;
    else
    {
        self.quoteView.hidden = (count > 0);
        
        if(count == 0)
        {
            [ScheduledAlertManager cancelAllScheduleBasedLocalNotifications];
        }
        else{
            [ScheduledAlertManager createLocalNotificationsFromDatabase];
        }
    }
    
    [self.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%lu",(unsigned long)count]];
    
    return count;
}

// ThoughtCellDelegate

-(void)cellSelected:(UITableViewCell *)cell
{
    if(![self presentedViewController])
        [self performSegueWithIdentifier:@"Edit Thought" sender:cell];
}

-(void)showActivitesForCell:(UITableViewCell *)cell
{
    ThoughtCell *chosenCell = (ThoughtCell*)cell;
    NSArray *activityItems = [NSArray arrayWithObject:chosenCell.textView.text];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    avc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:avc animated:YES completion:nil];
}

// ThoughtViewControllerDelegate

-(void)thoughtViewControllerCancelled
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)thoughtViewController:(ThoughtViewController*)sender hasThought:(NSString*)thought withAlertDate:(NSDate*)alertDate
{
    
        if(self.editingIndexPath)
        {
            Thought *editingThought = [self.onYourMindArray objectAtIndex:self.editingIndexPath.row];
            [self.oymBLL updateThought:editingThought withThought:thought andNotificationDate:alertDate];
        }
        else
        {
            [self.onYourMindArray addObject:[self.oymBLL createNewThought:thought andNotificationDate:alertDate]];
        }
        
        self.editingIndexPath = nil;
    
        [self.onYourMindTableView reloadData];
        
        [self thoughtViewControllerCancelled];
}

// UINavigationBarDelegate
-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

// WelcomeViewControllerDelegate

-(void)finishedWelcome
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HasUserSeenIntroduction];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
