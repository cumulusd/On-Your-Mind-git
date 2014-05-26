//
//  DisplayViewController.m
//  On Your Mind
//
//  Created by Daniel Bradford on 6/13/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "DisplayViewController.h"

@interface DisplayViewController ()

@end

@implementation DisplayViewController

@synthesize imageNameToShow;

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
    
    if([self.imageNameToShow length])
    {
        self.walkthroughImage.image = [UIImage imageNamed:self.imageNameToShow];
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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


- (IBAction)readyPressed:(UIButton *)sender {
    [self.delegate userFinished];
}


@end
