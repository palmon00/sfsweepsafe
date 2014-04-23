//
//  RoundedAndMaskedToBoundsSegmentedControl.m
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/23/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import "RoundedAndMaskedToBoundsSegmentedControl.h"

@implementation RoundedAndMaskedToBoundsSegmentedControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        [self setup];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
        [self setup];
    }
    return self;
}

- (void)setup
{
    // Clip rounded rect
    self.layer.cornerRadius = ROUNDED_AND_MASKED_TO_BOUNDS_SEGMENTED_CONTROL_CORNER_RADIUS;
    self.layer.masksToBounds = YES;
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
