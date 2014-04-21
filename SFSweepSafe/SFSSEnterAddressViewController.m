//
//  SFSSEnterAddressViewController.m
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/17/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import "SFSSEnterAddressViewController.h"
#import "SFSSStreetCleaningResultsViewController.h"

@interface SFSSEnterAddressViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UISearchBar *streetSearchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *streetTextField;
@property (weak, nonatomic) IBOutlet UITableView *streetTableView;

@property (nonatomic) CGRect streetSearchBarOriginalFrame;
@property (nonatomic) CGRect streetTableViewOriginalFrame;

@property (strong, nonatomic) NSArray *allStreets;
@property (strong, nonatomic) NSMutableArray *filteredStreets;
@property (nonatomic) BOOL isFiltered;

@property (nonatomic) BOOL searchBarAnimatedUp;

@end

@implementation SFSSEnterAddressViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.streetTableView.dataSource = self;
    self.streetTableView.delegate = self;
    self.streetSearchBar.delegate = self;
    
    // Set fonts
    self.numberTextField.font = [UIFont fontWithName:@"Copperplate" size:14.0];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:@"Copperplate" size:14.0]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadStreets];
    [self.streetTableView reloadData];
    
    // Start with data entry in number text field
    [self.numberTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Store original frames for animation
    self.streetSearchBarOriginalFrame = self.streetSearchBar.frame;
    NSLog(@"streetSearchBarOriginalFrame %@", NSStringFromCGRect(self.streetSearchBarOriginalFrame));
    self.streetTableViewOriginalFrame = self.streetTableView.frame;
    NSLog(@"streetTableViewOriginalFrame %@", NSStringFromCGRect(self.streetTableViewOriginalFrame));
    
    // Search bar is always down when view appears
    self.searchBarAnimatedUp = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods

- (void)loadStreets
{
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"Streets" ofType:nil];
    
    NSError *error = nil;
    NSString *input = [NSString stringWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:&error];
    
    if (!error) {
        self.allStreets = [input componentsSeparatedByString:@"\n"];
    } else {
        NSLog(@"%@", error);
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Entered Location"]) {
        SFSSStreetCleaningResultsViewController *scrvc = segue.destinationViewController;
        scrvc.number = self.numberTextField.text;
        scrvc.street = self.streetSearchBar.text;
    }
}

#pragma mark - UITableView Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // One section
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isFiltered) {
        return [self.filteredStreets count];
    } else {
        return [self.allStreets count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Street Cell" forIndexPath:indexPath];
    
    // Set fonts
    cell.textLabel.font = [UIFont fontWithName:@"Copperplate" size:20.0];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Copperplate" size:10.0];
    
    // Set color
    cell.textLabel.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    
    if (self.isFiltered) {
        cell.textLabel.text = self.filteredStreets[indexPath.row];
    } else {
        cell.textLabel.text = self.allStreets[indexPath.row];
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Populate searchbar text
    self.streetSearchBar.text = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    // Drop keyboard
    [self.streetSearchBar resignFirstResponder];
    
    // Animate down
    [UIView animateWithDuration:0.5 animations:^{
        self.streetSearchBar.frame = self.streetSearchBarOriginalFrame;
        NSLog(@"self.streetSearchBar.frame %@", NSStringFromCGRect(self.streetSearchBar.frame));
        self.streetTableView.frame = self.streetTableViewOriginalFrame;
        NSLog(@"self.streetTableView.frame %@", NSStringFromCGRect(self.streetTableView.frame));
        self.searchBarAnimatedUp = NO;
    }];
}

#pragma mark - UISearchBar Delegate

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarShouldBeginEditing");

    if (!self.searchBarAnimatedUp) { // Prevent double animation
        self.searchBarAnimatedUp = YES;
        
        // Animate up
        [UIView animateWithDuration:0.5 animations:^{
            self.streetSearchBar.frame = CGRectMake(0, 0, self.streetSearchBar.frame.size.width, self.streetSearchBar.frame.size.height);
            NSLog(@"self.streetSearchBar.frame %@", NSStringFromCGRect(self.streetSearchBar.frame));
            self.streetTableView.frame = CGRectMake(0, self.streetSearchBar.frame.size.height, self.streetTableView.frame.size.width, self.streetTableView.frame.size.height);
            NSLog(@"self.streetTableView.frame %@", NSStringFromCGRect(self.streetTableView.frame));
        }];
    }
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // If searchText is empty, use all streets
    if ([searchText isEqualToString:@""]) self.isFiltered = NO;
    else {
        self.isFiltered = YES;
        
        // Rebuild filteredStreets
        self.filteredStreets = [[NSMutableArray alloc] init];
        for (NSString *street in self.allStreets) {
            NSRange range = [street rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (range.location == 0) {
                [self.filteredStreets addObject:street];
            }
        }
    }
    
    // Reload data
    [self.streetTableView reloadData];
}

#pragma mark - IB Actions
- (IBAction)doneBarButtonPressed:(UIBarButtonItem *)sender {
    if (![self.numberTextField.text isEqualToString:@""] && (![self.streetSearchBar.text isEqualToString:@""]))
        [self performSegueWithIdentifier:@"Entered Location" sender:nil];
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing Fields" message:@"Please fill out all fields." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

@end
