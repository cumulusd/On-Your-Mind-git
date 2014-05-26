//
//  ThoughtCell.h
//  On Your Mind
//
//  Created by Daniel Bradford on 3/22/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThoughtCell;

@protocol ThoughtCellDelegate<NSObject>

@optional
-(void)cellSelected:(UITableViewCell*)cell;

@required
-(void)showActivitesForCell:(UITableViewCell*)cell;

@end

@interface ThoughtCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak,nonatomic) id <ThoughtCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imgExclamation;
@property (weak, nonatomic) IBOutlet UIImageView *imgExclamationRed;

@end
