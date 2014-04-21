//
//  SFSSStreetCleaningResultsViewController.m
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/17/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import "SFSSStreetCleaningResultsViewController.h"
#import "SFSSPlacemarkCollection.h"
#import "SFSSPlacemark.h"
#import "SFSSEnterStreetCleaningViewController.h"
#import "SFSSSetReminderViewController.h"

@interface SFSSStreetCleaningResultsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *matchingPlacemarks;
@property (strong, nonatomic) NSMutableArray *selectedPlacemarks; // of SFSSPlacemark
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;

@property (nonatomic) BOOL multipleMatches;
@property (nonatomic) BOOL didSelectAll;

@end

@implementation SFSSStreetCleaningResultsViewController

#pragma mark - Instantiation

-(NSMutableArray *)selectedPlacemarks
{
    if (!_selectedPlacemarks) _selectedPlacemarks = [[NSMutableArray alloc] init];
    return _selectedPlacemarks;
}

-(NSArray *)matchingPlacemarks
{
    if (!_matchingPlacemarks) {
        if (_street && _number) {
        // Retrieve placemarks that begin with the 1st character of the street name
        // and find matches using the street name and address number
        _matchingPlacemarks = [[[SFSSPlacemarkCollection alloc] initWithFile:[NSString stringWithFormat:@"%@", [[_street uppercaseString]substringToIndex:1]]] placemarksFilteredByStreet:[_street uppercaseString] andNumber:_number];
        } else _matchingPlacemarks = [[NSArray alloc] init];
    }
    return _matchingPlacemarks;
}

-(BOOL)multipleMatches
{
    return [self.matchingPlacemarks count] > 1;
}

#pragma mark - Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.allowsMultipleSelection = YES;
    self.didSelectAll = NO;
    
    if (![self.matchingPlacemarks count]) self.instructionsLabel.text = @"No matching street cleaning times";
}

-(void)viewDidAppear:(BOOL)animated
{
    // If only one match, reset selectedPlacemarks
    if (!self.multipleMatches) self.selectedPlacemarks = nil;
    
    // Update doneBarButton
    [self updateDoneBarButtonState];
}

#pragma mark - Helper Methods

-(void)updateDoneBarButtonState
{
    // Done button will be hidden if one match, visible otherwise
    if (!self.multipleMatches) self.doneBarButton.title = @"";
    else self.doneBarButton.title = @"Done";
    
    // Done button will be disabled if no placemarks have been selected
    self.doneBarButton.enabled = ([self.selectedPlacemarks count] > 0);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // One section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Add a row for enter own values and if multiple matches, a row for select all
    return [self.matchingPlacemarks count] + 1 + self.multipleMatches;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Street Cleaning Cell" forIndexPath:indexPath];
    
    // Set fonts
    cell.textLabel.font = [UIFont fontWithName:@"Copperplate" size:20.0];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Copperplate" size:10.0];
    
    // Set color
    cell.textLabel.textColor = [UIColor TINT_COLOR]; //colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    cell.detailTextLabel.textColor = [UIColor TINT_COLOR]; // colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    
    // Configure the cell...
    if (indexPath.row == 0 && self.multipleMatches) {
        cell.textLabel.text = self.didSelectAll ? @"Deselect all" : @"Select all";
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (indexPath.row == [self tableView:tableView numberOfRowsInSection:0] - 1) {
        cell.textLabel.text = @"Enter my own values";
        cell.detailTextLabel.text = nil;
    } else {
        SFSSPlacemark *placemark = self.matchingPlacemarks[indexPath.row - self.multipleMatches];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ to %@", placemark.fromHourAMPM, placemark.toHourAMPM];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", placemark.weeksOfMonthType, placemark.date];
    }
    return cell;
}

#pragma mark - UITableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    if ([cellText isEqualToString:@"Select all"]) {
        for (int i = 1; i < [self.matchingPlacemarks count] + 1; i++) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (cell.selected == NO) {
                cell.selected = YES;
                [self.selectedPlacemarks addObject:self.matchingPlacemarks[i - self.multipleMatches]];
            }
        }
        [tableView cellForRowAtIndexPath:indexPath].textLabel.text = @"Deselect all";
        self.didSelectAll = YES;
    } else if ([cellText isEqualToString:@"Enter my own values"]) {
        // Deselect it in case user returns to this screen
        [self.tableView cellForRowAtIndexPath:indexPath].selected = NO;
        [self performSegueWithIdentifier:@"Enter Street Cleaning" sender:nil];
    } else {
        // if only one match, deselect cell, add placemark and segue
        if (!self.multipleMatches) {
            [self.tableView cellForRowAtIndexPath:indexPath].selected = NO;
            [self.selectedPlacemarks addObject:self.matchingPlacemarks[indexPath.row - self.multipleMatches]];
            [self performSegueWithIdentifier:@"Selected Street Cleaning" sender:nil];
        } else {
            // multiple matches so select cell
            [self.selectedPlacemarks addObject:self.matchingPlacemarks[indexPath.row - self.multipleMatches]];
        }
    }
    [self updateDoneBarButtonState];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    if ([cellText isEqualToString:@"Deselect all"]) {
        for (int i = 1; i < [self.matchingPlacemarks count] + 1; i++) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (cell.selected == YES) {
                cell.selected = NO;
                [self.selectedPlacemarks removeObject:self.matchingPlacemarks[i - self.multipleMatches]];
            }
        }
        [tableView cellForRowAtIndexPath:indexPath].textLabel.text = @"Select all";
        self.didSelectAll = NO;
    } else if ([cellText isEqualToString:@"Enter my own values"]) {
        // Should never happen
    } else {
        [self.selectedPlacemarks removeObject:self.matchingPlacemarks[indexPath.row - self.multipleMatches]];
    }
    [self updateDoneBarButtonState];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Selected Street Cleaning"]) {
        SFSSSetReminderViewController *savc = segue.destinationViewController;
        savc.placemarks = self.selectedPlacemarks;
        savc.number = self.number;
        savc.street = self.street;
    } else if ([segue.identifier isEqualToString:@"Enter Street Cleaning"]) {
        SFSSEnterStreetCleaningViewController *escvc = segue.destinationViewController;
        escvc.number = self.number;
        escvc.street = self.street;
    }
}
- (IBAction)doneBarButtonPressed:(UIBarButtonItem *)sender {
    if ([self.selectedPlacemarks count]) {
        [self performSegueWithIdentifier:@"Selected Street Cleaning" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"Enter Street Cleaning" sender:nil];
    }
}

@end
