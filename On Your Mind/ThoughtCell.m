//
//  ThoughtCell.m
//  On Your Mind
//
//  Created by Daniel Bradford on 3/22/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "ThoughtCell.h"

@interface ThoughtCell()


@end

@implementation ThoughtCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.textView setScrollsToTop:NO];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)]];
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
}

-(void)tap:(UIGestureRecognizer*)gesture
{
    if(gesture.state == UIGestureRecognizerStateEnded)
        [self.delegate cellSelected:self];
}

-(void)longPress:(UIGestureRecognizer*)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
        [self.delegate showActivitesForCell:self];
}


@end
