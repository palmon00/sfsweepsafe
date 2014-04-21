//
//  SFSSConfirmAddressViewController.m
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/17/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import "SFSSConfirmAddressViewController.h"
#import "SFSSStreetCleaningResultsViewController.h"

@interface SFSSConfirmAddressViewController ()
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *streetLabel;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;

@end

@implementation SFSSConfirmAddressViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.numberLabel.text = self.number;
    self.streetLabel.text = self.street;
    
    // Add motion effects
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(MOTION_EFFECT_MIN);
    horizontalMotionEffect.maximumRelativeValue = @(MOTION_EFFECT_MAX);
    
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(MOTION_EFFECT_MIN);
    verticalMotionEffect.maximumRelativeValue = @(MOTION_EFFECT_MAX);
    
    [self.instructionsLabel addMotionEffect:horizontalMotionEffect];
    [self.instructionsLabel addMotionEffect:verticalMotionEffect];
    [self.numberLabel addMotionEffect:horizontalMotionEffect];
    [self.numberLabel addMotionEffect:verticalMotionEffect];
    [self.streetLabel addMotionEffect:horizontalMotionEffect];
    [self.streetLabel addMotionEffect:verticalMotionEffect];
    [self.yesButton addMotionEffect:horizontalMotionEffect];
    [self.yesButton addMotionEffect:verticalMotionEffect];
    [self.noButton addMotionEffect:horizontalMotionEffect];
    [self.noButton addMotionEffect:verticalMotionEffect];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Confirmed Location"]) {
        SFSSStreetCleaningResultsViewController *scrtvc = segue.destinationViewController;
        scrtvc.number = self.number;
        scrtvc.street = self.street;
    }
}

#pragma mark - IB Actions

- (IBAction)yesButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"Confirmed Location" sender:nil];
}

- (IBAction)noButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"Wrong Location" sender:nil];
}

@end
