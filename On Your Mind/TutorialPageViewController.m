//
//  TutorialPageViewController.m
//  On Your Mind
//
//  Created by Daniel Bradford on 8/25/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "TutorialPageViewController.h"
#import "DisplayViewController.h"

@interface TutorialPageViewController () <UIPageViewControllerDataSource,UIPageViewControllerDelegate,DisplayViewControllerDelegate>
@property (strong,nonatomic) NSArray *tutorialViewControllers;


@end

@implementation TutorialPageViewController

#define NumberOfDisplayItems 3

NSInteger currentIndex;

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

    DisplayViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialVC2"];
    dvc.delegate = self;
    
    currentIndex = 0;
    
    self.tutorialViewControllers = [NSArray arrayWithObjects:[self.storyboard instantiateViewControllerWithIdentifier:@"TutorialVC1"], [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialVC1"], dvc, nil];
    
    [self forViewControllerView:[self.tutorialViewControllers objectAtIndex:0] setColor:[UIColor orangeColor]];
    [self forViewControllerView:[self.tutorialViewControllers objectAtIndex:1] setColor:[UIColor yellowColor]];

    
    self.delegate = self;
    self.dataSource = self;
    
    [self setViewControllers:[NSArray arrayWithObject:[self.tutorialViewControllers objectAtIndex:0 ]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

-(void)forViewControllerView:(UIViewController*)vc setColor:(UIColor*)color
{
    vc.view.backgroundColor = color;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// UIPageViewControllerDataSource delegate

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return NumberOfDisplayItems;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self.tutorialViewControllers indexOfObject:viewController];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self.tutorialViewControllers objectAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self.tutorialViewControllers indexOfObject:viewController];
    
    
    index++;
    
    if (index == NumberOfDisplayItems) {
        return nil;
    }
    
    return [self.tutorialViewControllers objectAtIndex:index];

}


-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return currentIndex;
}

// UIPageViewControllerDelegate

// DisplayViewControllerDelegate

-(void)userFinished
{
    [self.tutorialDelegate tutorialFinished];
}

@end
