//
//  TextFieldNoCursor.m
//  On Your Mind
//
//  Created by Daniel Bradford on 7/13/13.
//  Copyright (c) 2013 Daniel Bradford. All rights reserved.
//

#import "TextFieldNoCursor.h"

@implementation TextFieldNoCursor

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(CGRect)caretRectForPosition:(UITextPosition *)position
{
    return CGRectZero;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
