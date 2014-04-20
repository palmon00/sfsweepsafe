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

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *streetLabel;

@end

@implementation SFSSConfirmAddressViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.numberLabel.text = self.number;
    self.streetLabel.text = self.street;
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
