//
//  SFSSParkedViewController.m
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/17/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import "SFSSParkedViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SFSSConfirmAddressViewController.h"
#import "SFSSEnterAddressViewController.h"

@interface SFSSParkedViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *parkedButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *searchingLabel;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *userLocation;

@property (nonatomic) BOOL imParkedPressed; // used to tell when to segue immediately upon user location changes or errors
@property (nonatomic) BOOL didSegue; // used to prevent duplicate segues due to multiple asynchronous geocoding calls

@end

@implementation SFSSParkedViewController

#pragma mark - Instantiation

-(CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    return _locationManager;
}

#pragma mark - Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add motion effects
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(MOTION_EFFECT_MIN);
    horizontalMotionEffect.maximumRelativeValue = @(MOTION_EFFECT_MAX);
    
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(MOTION_EFFECT_MIN);
    verticalMotionEffect.maximumRelativeValue = @(MOTION_EFFECT_MAX);
    
    [self.instructionsLabel addMotionEffect:horizontalMotionEffect];
    [self.instructionsLabel addMotionEffect:verticalMotionEffect];
    [self.parkedButton addMotionEffect:horizontalMotionEffect];
    [self.parkedButton addMotionEffect:verticalMotionEffect];
    [self.activityIndicator addMotionEffect:horizontalMotionEffect];
    [self.activityIndicator addMotionEffect:verticalMotionEffect];
    [self.searchingLabel addMotionEffect:horizontalMotionEffect];
    [self.searchingLabel addMotionEffect:verticalMotionEffect];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Hide searchingLabel
    self.searchingLabel.text = @"";
    
    //Start monitoring for significant location changes immediately
    if ([CLLocationManager locationServicesEnabled]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
            NSLog(@"viewDidAppear: startMonitoringSignificantLocationChanges");
            [self.locationManager startMonitoringSignificantLocationChanges];
        }
    }
    
    // Reset parked button flag
    self.imParkedPressed = NO;
    
    // Reset did segue flag
    self.didSegue = NO;
}

#pragma mark - CLLocationManager Delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // Set user's location and reduce notifications to significant changes
    NSLog(@"didUpdateLocations: Setting user's location to %@", [locations lastObject]);
    self.userLocation = [locations lastObject];
    
    // If user has pressed parked, geocode and segue
    if (self.imParkedPressed && !self.didSegue) {
        [self geocodeUserLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // If denied, turn off location services
    NSLog(@"%@", error);
    if (error.code == kCLErrorDenied) {
        
        NSLog(@"didFailWithError: stopUpdatingLocation");
        [manager stopUpdatingLocation];
        
        NSLog(@"didFailWithError: stopMonitoringSignificantLocationChanges");
        [manager stopMonitoringSignificantLocationChanges];
    }
    
    // If user has pressed parked, geocode and segue
    if (self.imParkedPressed && !self.didSegue) {
        [self geocodeUserLocation];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Set segue flag
    self.didSegue = YES;

    // Stop updating location and monitoring significant location changes
    NSLog(@"prepareForSegue: stopUpdatingLocation");
    [self.locationManager stopUpdatingLocation];
    NSLog(@"prepareForSegue: stopMonitoringSignificantLocationChanges");
    [self.locationManager stopMonitoringSignificantLocationChanges];
    
    // Prepare confirmation view controller
    if ([segue.identifier isEqualToString:@"Confirm Location"]) {
        SFSSConfirmAddressViewController *cavc = segue.destinationViewController;
        NSArray *address = sender;
        cavc.number = address[0];
        cavc.street = address[1];
    }
    
    // Stop activity indicator
    [self.activityIndicator stopAnimating];
}

#pragma mark - Geocoding

- (void)geocodeUserLocation
{
    // Stop updating location and monitoring significant location changes
    NSLog(@"geocodeUserLocation: stopUpdatingLocation");
    [self.locationManager stopUpdatingLocation];
    NSLog(@"geocodeUserLocation: stopMonitoringSignificantLocationChanges");
    [self.locationManager stopMonitoringSignificantLocationChanges];

    // Don't do any additional processing if we have already segued
    if (!self.didSegue) {
    
        // Check for userLocation
        if (self.userLocation) {
            
            self.searchingLabel.text = @"Determining your address...";
            
            // If found, check for address
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:self.userLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                if (!error) {
                    
                    // Check for address
                    NSString *number = nil;
                    NSString *street = nil;
                    for (CLPlacemark *placemark in placemarks) {
                        
                        // Get street from addressDictionary
                        if (placemark.addressDictionary) {
                            if (placemark.addressDictionary[@"subThoroughfare"]) number = placemark.addressDictionary[@"subThoroughfare"];
                            if (placemark.addressDictionary[@"thoroughfare"]) street = placemark.addressDictionary[@"thoroughfare"];
                        }
                        
                        // Get street from placemark
                        if (placemark.subThoroughfare) number = placemark.subThoroughfare;
                        if (placemark.thoroughfare) street = placemark.thoroughfare;
                    }
                    
                    // If we have a number and address and have not already segued, segue to confirmation
                    if (number && street && !self.didSegue) {
                        [self performSegueWithIdentifier:@"Confirm Location" sender:@[number, street]];
                    } else if (!self.didSegue) [self performSegueWithIdentifier:@"Enter Location" sender:nil];
                } else {
                    
                    // If any errors, segue to address entry
                    NSLog(@"%@", error);
                    if (!self.didSegue) [self performSegueWithIdentifier:@"Enter Location" sender:nil];
                }
            }];
        } else {
            
            // If not found, segue to address entry
            if (!self.didSegue) [self performSegueWithIdentifier:@"Enter Location" sender:nil];
        }
    }
}

#pragma mark - IB Actions

- (IBAction)imParkedButtonPressed:(UIButton *)sender {
    
    self.imParkedPressed = YES;
    
    // Start spinner
    [self.activityIndicator startAnimating];
    
    if (self.userLocation) {
        
        // If we have a location already, geocode and segue
        [self geocodeUserLocation];
        
    } else {
        
        // Check for authorization or request it
        if ([CLLocationManager locationServicesEnabled]) {
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ||
                [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
                
                // Try (harder) to get user's location
                [self.locationManager startUpdatingLocation];
                self.searchingLabel.text = @"Searching for your location...";
                
                // Wait at most 10 seconds then try to geocode and segue
                [self performSelector:@selector(geocodeUserLocation) withObject:nil afterDelay:10];
            }
        } else {
            
            // If no location services, segue to address entry
            if (!self.didSegue) [self performSegueWithIdentifier:@"Enter Location" sender:nil];
        }
    }
}
@end
