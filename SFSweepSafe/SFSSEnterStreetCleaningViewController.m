//
//  SFSSEnterStreetCleaningViewController.m
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/17/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import "SFSSEnterStreetCleaningViewController.h"
#import "SFSSPlacemark.h"
#import "SFSSSetReminderViewController.h"
#import "RoundedAndMaskedToBoundsSegmentedControl.h"

@interface SFSSEnterStreetCleaningViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *fromHourTextField;
@property (weak, nonatomic) IBOutlet UITextField *toHourTextField;
@property (weak, nonatomic) IBOutlet RoundedAndMaskedToBoundsSegmentedControl *fromHourAMPM;
@property (weak, nonatomic) IBOutlet RoundedAndMaskedToBoundsSegmentedControl *toHourAMPM;
@property (weak, nonatomic) IBOutlet RoundedAndMaskedToBoundsSegmentedControl *weeksOfMonth;
@property (weak, nonatomic) IBOutlet RoundedAndMaskedToBoundsSegmentedControl *weekday;

@property (nonatomic) BOOL didEditToHour;

@end

@implementation SFSSEnterStreetCleaningViewController

-(void)viewDidLoad
{
    // Set delegates and action targets
    self.fromHourTextField.delegate = self;
    self.toHourTextField.delegate = self;
    [self.fromHourAMPM addTarget:self action:@selector(didChangeSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    [self.toHourAMPM addTarget:self action:@selector(didChangeSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    [self.weeksOfMonth addTarget:self action:@selector(didChangeSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    [self.weekday addTarget:self action:@selector(didChangeSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    
    // Set default values for all segmentedControls
    self.fromHourAMPM.selectedSegmentIndex = 0;
    self.toHourAMPM.selectedSegmentIndex = 0;
    self.weeksOfMonth.selectedSegmentIndex = 0;
    self.weekday.selectedSegmentIndex = 0;
    
    // Enter fromHour first
    [self.fromHourTextField becomeFirstResponder];
    
    // Set fonts
    self.fromHourTextField.font = [UIFont fontWithName:@"Copperplate" size:14.0];
    self.toHourTextField.font = [UIFont fontWithName:@"Copperplate" size:14.0];
    
    // Add motion effects
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(MOTION_EFFECT_MIN);
    horizontalMotionEffect.maximumRelativeValue = @(MOTION_EFFECT_MAX);
    
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(MOTION_EFFECT_MIN);
    verticalMotionEffect.maximumRelativeValue = @(MOTION_EFFECT_MAX);
    
    [self.fromHourTextField addMotionEffect:horizontalMotionEffect];
    [self.fromHourTextField addMotionEffect:verticalMotionEffect];
    [self.toHourTextField addMotionEffect:horizontalMotionEffect];
    [self.toHourTextField addMotionEffect:verticalMotionEffect];
    [self.fromHourAMPM addMotionEffect:horizontalMotionEffect];
    [self.fromHourAMPM addMotionEffect:verticalMotionEffect];
    [self.toHourAMPM addMotionEffect:horizontalMotionEffect];
    [self.toHourAMPM addMotionEffect:verticalMotionEffect];
    [self.weeksOfMonth addMotionEffect:horizontalMotionEffect];
    [self.weeksOfMonth addMotionEffect:verticalMotionEffect];
    [self.weekday addMotionEffect:horizontalMotionEffect];
    [self.weekday addMotionEffect:verticalMotionEffect];
}

#pragma mark - Helper Methods

-(void)updateToHourBasedOnFromHourString:(NSString *)fromHourString
{
    NSInteger fromHour = [fromHourString integerValue];
    
    if (fromHour <= 10) {
        // toHour is 2 hours later and in same AMPM
        self.toHourTextField.text = [NSString stringWithFormat:@"%d", (int)fromHour + 2];
    } else {
        // toHour is 10 hours behind for 11 and 12
        self.toHourTextField.text = [NSString stringWithFormat:@"%d", (int)fromHour - 10];
    }
    
    // toHour is inverse of fromHour for 10 and 11
    if (fromHour == 10 || fromHour == 11) self.toHourAMPM.selectedSegmentIndex = !self.fromHourAMPM.selectedSegmentIndex;
    // and same for rest of hours
    else self.toHourAMPM.selectedSegmentIndex = self.fromHourAMPM.selectedSegmentIndex;

}

#pragma mark - UIControl

-(void)didChangeSegmentedControl:(UIControl *)sender
{
//    NSLog(@"Segmented Control %@ touched", sender);
    // For fromHourAMPM, if toHour has not been edited also update toHour and toHourAMPM
    if (!self.didEditToHour && [(UISegmentedControl *)sender isEqual:self.fromHourAMPM]) {
        [self updateToHourBasedOnFromHourString:self.fromHourTextField.text];
    }
    
    if ([(UISegmentedControl *)sender isEqual:self.toHourAMPM]) {
        self.didEditToHour = YES;
    }
    
    // Whenever user selects a segmented control, resignFirstResponders on textFields.
    if ([self.fromHourTextField canResignFirstResponder]) [self.fromHourTextField resignFirstResponder];
    if ([self.toHourTextField canResignFirstResponder]) [self.toHourTextField resignFirstResponder];
}

#pragma mark - UITextField Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([newString length]) {
        NSInteger newTime = [newString integerValue];
        
        // Only accept 1-12 for either field
        if (1 <= newTime && newTime <= 12) {
            
            // For fromHour, if toHour has not been edited also update toHour and toHourAMPM
            // based on new fromHour value
            if (!self.didEditToHour && [textField isEqual:self.fromHourTextField]) {
                [self updateToHourBasedOnFromHourString:newString];
            }
            
            // Flag edits in toHour
            if ([textField isEqual:self.toHourTextField]) self.didEditToHour = YES;
            
            // All hours 1-12 are valid
            return YES;
        } else return NO; // hours outside 1-12 are invalid
    }
    
    // empty strings are also valid
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Entered Street Cleaning"]) {
        
        // Generate Placemark
        NSArray *dates = [SFSSPlacemark dates];
        
        NSString *date = dates[self.weekday.selectedSegmentIndex];
        NSLog(@"Date is %@", date);
        
        // Convert times into integers
        NSInteger fromHour = [self.fromHourTextField.text integerValue];
        NSInteger toHour = [self.toHourTextField.text integerValue];

        // If times are 12, set them to 0 for easier calculations
        // 12 pm = 0 pm, 12am = 0am
        if (fromHour == 12) fromHour = 0;
        if (toHour == 12) toHour = 0;
        
        // Convert fromHour and toHour to 24 hour time
        fromHour = self.fromHourAMPM.selectedSegmentIndex ? fromHour + 12 : fromHour;
        toHour = self.toHourAMPM.selectedSegmentIndex ? toHour + 12 : toHour;
        
        NSString *weeksOfMonth = nil;
        switch (self.weeksOfMonth.selectedSegmentIndex) {
            case 0:
                weeksOfMonth = SFSSWEEKSTYPEEVERY;
                break;
            case 1:
                weeksOfMonth = SFSSWEEKSTYPE1ST3RD;
                break;
            case 2:
                weeksOfMonth = SFSSWEEKSTYPE2ND4TH;
                break;
            case 3:
                weeksOfMonth = SFSSWEEKSTYPE1ST;
                break;
            case 4:
                weeksOfMonth = SFSSWEEKSTYPE1ST3RD5TH;
                break;
            default:
                weeksOfMonth = SFSSWEEKSTYPEUNKNOWN;
                break;
        }
        
        SFSSPlacemark *placemark = [[SFSSPlacemark alloc] initWithNumber:self.number street:self.street date:date fromHour:fromHour toHour:toHour weeksOfMonthType:weeksOfMonth];
        
        SFSSSetReminderViewController *savc = segue.destinationViewController;
        savc.placemarks = @[placemark];
        savc.number = self.number;
        savc.street = self.street;
    }
}

- (IBAction)doneBarButtonPressed:(UIBarButtonItem *)sender {
    if ([self.fromHourTextField.text integerValue] &&
        [self.toHourTextField.text integerValue]) {
        [self performSegueWithIdentifier:@"Entered Street Cleaning" sender:sender];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing Fields" message:@"Please fill out all fields." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}


@end
