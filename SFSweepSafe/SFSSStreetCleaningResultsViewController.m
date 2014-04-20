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
#import "SFSSSetAlarmViewController.h"

@interface SFSSStreetCleaningResultsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *matchingPlacemarks;
@property (strong, nonatomic) NSMutableArray *selectedPlacemarks; // of SFSSPlacemark
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;

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
    if (!_matchingPlacemarks && _street && _number) {
        // Retrieve placemarks that begin with the 1st character of the street name
        // and find matches using the street name and address number
        _matchingPlacemarks = [[[SFSSPlacemarkCollection alloc] initWithFile:[NSString stringWithFormat:@"%@", [[_street uppercaseString]substringToIndex:1]]] placemarksFilteredByStreet:[_street uppercaseString] andNumber:_number];
    }
    return _matchingPlacemarks;
}

#pragma mark - Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.allowsMultipleSelection = YES;
    self.didSelectAll = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self updateDoneBarButtonState];
}

#pragma mark - Helper Methods

-(void)updateDoneBarButtonState
{
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
    // Extra row for entering own values
    return [self.matchingPlacemarks count] + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Street Cleaning Cell" forIndexPath:indexPath];
    
    // Set fonts
    cell.textLabel.font = [UIFont fontWithName:@"Copperplate" size:20.0];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Copperplate" size:10.0];
    
    // Set color
    cell.textLabel.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    
    // Configure the cell...
    if (indexPath.row == 0) {
        cell.textLabel.text = self.didSelectAll ? @"Deselect all" : @"Select all";
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (indexPath.row == [self.matchingPlacemarks count] + 1) {
        cell.textLabel.text = @"Enter my own values";
        cell.detailTextLabel.text = nil;
    } else {
        SFSSPlacemark *placemark = self.matchingPlacemarks[indexPath.row - 1];
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
                [self.selectedPlacemarks addObject:self.matchingPlacemarks[i - 1]];
            }
        }
        [tableView cellForRowAtIndexPath:indexPath].textLabel.text = @"Deselect all";
        self.didSelectAll = YES;
    } else if ([cellText isEqualToString:@"Enter my own values"]) {
        // Deselect it in case user returns
        [self.tableView cellForRowAtIndexPath:indexPath].selected = NO;
        [self performSegueWithIdentifier:@"Enter Street Cleaning" sender:nil];
    } else {
        [self.selectedPlacemarks addObject:self.matchingPlacemarks[indexPath.row - 1]];
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
                [self.selectedPlacemarks removeObject:self.matchingPlacemarks[i - 1]];
            }
        }
        [tableView cellForRowAtIndexPath:indexPath].textLabel.text = @"Select all";
        self.didSelectAll = NO;
    } else if ([cellText isEqualToString:@"Enter my own values"]) {
        // Should never happen
    } else {
        [self.selectedPlacemarks removeObject:self.matchingPlacemarks[indexPath.row - 1]];
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
        SFSSSetAlarmViewController *savc = segue.destinationViewController;
        savc.placemarks = self.selectedPlacemarks;
        savc.number= self.number;
        savc.street = self.street;
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
