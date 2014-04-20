//
//  SFSSSetAlarmViewController.m
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/17/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import "SFSSSetAlarmViewController.h"
#import "SFSSPlacemark.h"

@interface SFSSSetAlarmViewController ()
@property (weak, nonatomic) IBOutlet UITextView *warningTextView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *alarmIntervalSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextView *alarmSummaryTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDate *closestStreetCleaningDate;

@end

#define ONE_DAY 86400

@implementation SFSSSetAlarmViewController

#pragma mark - Instantiation

-(NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterFullStyle;
        _dateFormatter.timeStyle = NSDateFormatterFullStyle;
    }
    return _dateFormatter;
}

- (NSDate *)closestStreetCleaningDate
{
    if (!_closestStreetCleaningDate) {
        // Get the current date
        NSDate *today = [NSDate date];
        
        // Get gregorian calendar
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        // Get the current year, month, day, hour
        NSDateComponents *allComponents = [gregorian components:NSEraCalendarUnit |
                                           NSYearCalendarUnit |
                                           NSMonthCalendarUnit |
                                           NSDayCalendarUnit |
                                           NSHourCalendarUnit |
                                           NSMinuteCalendarUnit |
                                           NSSecondCalendarUnit |
                                           NSWeekCalendarUnit |
                                           NSWeekdayCalendarUnit |
                                           NSWeekdayOrdinalCalendarUnit |
                                           NSQuarterCalendarUnit |
                                           NSWeekOfMonthCalendarUnit |
                                           NSWeekOfYearCalendarUnit |
                                           NSYearForWeekOfYearCalendarUnit |
                                           NSCalendarCalendarUnit |
                                           NSTimeZoneCalendarUnit fromDate:today];
        
        NSInteger currentEra = [allComponents era];
        NSInteger currentYear = [allComponents year];
        NSInteger currentMonth = [allComponents month];
        
        // Setup weekDays
        NSArray *dates = [SFSSPlacemark dates];
        
        // Prepare streetCleaningDates
        NSMutableArray *streetCleaningDates = [[NSMutableArray alloc] init];
        
        
        for (SFSSPlacemark *placemark in _placemarks) {
            // get weekDay of street cleaning
            NSInteger cleaningWeekDay = [dates indexOfObject:placemark.date] + 1;
            
            // get fromHour of street cleaning
            NSInteger cleaningHour = placemark.fromHour;
            
            // Prepare formatter for logging and reporting
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateStyle = NSDateFormatterFullStyle;
            dateFormatter.timeStyle = NSDateFormatterFullStyle;
            
            // Prepare date components
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setEra:currentEra];
            [components setYear:currentYear];
            [components setWeekday:cleaningWeekDay];
            [components setHour:cleaningHour];
            
            if (placemark.week1ofMonth) {
                // add street cleaning date
                [components setMonth:currentMonth];
                [components setWeekdayOrdinal:1]; // 1st week of month
                [streetCleaningDates addObject:[gregorian dateFromComponents:components]];
                
                // add street cleaning date for next month
                [components setMonth:(currentMonth + 1)];
                [streetCleaningDates addObject:[gregorian dateFromComponents:components]];
            }
            
            if (placemark.week2ofMonth) {
                // add street cleaning date for this month
                [components setMonth:currentMonth];
                [components setWeekdayOrdinal:2]; // 2nd week of month
                [streetCleaningDates addObject:[gregorian dateFromComponents:components]];
                
                // add street cleaning date for next month
                [components setMonth:(currentMonth + 1)];
                [streetCleaningDates addObject:[gregorian dateFromComponents:components]];
            }
            
            if (placemark.week3ofMonth) {
                // add street cleaning date
                [components setMonth:currentMonth];
                [components setWeekdayOrdinal:3]; // 3rd week of month
                [streetCleaningDates addObject:[gregorian dateFromComponents:components]];
                
                // add street cleaning date for next month
                [components setMonth:(currentMonth + 1)];
                [streetCleaningDates addObject:[gregorian dateFromComponents:components]];
            }
            
            if (placemark.week4ofMonth) {
                // add street cleaning date
                [components setMonth:currentMonth];
                [components setWeekdayOrdinal:4]; // 4th week of month
                [streetCleaningDates addObject:[gregorian dateFromComponents:components]];
                
                // add street cleaning date for next month
                [components setMonth:(currentMonth + 1)];
                [streetCleaningDates addObject:[gregorian dateFromComponents:components]];
            }
            
            if (placemark.week5ofMonth) {
                // add street cleaning date
                [components setMonth:currentMonth];
                [components setWeekdayOrdinal:5]; // 5th week of month
                [streetCleaningDates addObject:[gregorian dateFromComponents:components]];
                
                // add street cleaning date for next month
                [components setMonth:(currentMonth + 1)];
                [streetCleaningDates addObject:[gregorian dateFromComponents:components]];
            }
        }
        // find closest streetCleaningDate
        NSTimeInterval timeIntervalUntilClosestStreetCleaning = MAXFLOAT;
        for (NSDate *streetCleaningDate in streetCleaningDates) {
            //        NSLog(@"Comparing %@ to %@", [dateFormatter stringFromDate:streetCleaningDate], [dateFormatter stringFromDate:today]);
            if ([streetCleaningDate compare:today] == NSOrderedDescending) {
                NSTimeInterval difference = [streetCleaningDate timeIntervalSinceDate:today];
                //            NSLog(@"%f seconds difference", difference);
                if (difference < timeIntervalUntilClosestStreetCleaning) {
                    timeIntervalUntilClosestStreetCleaning = difference;
                    _closestStreetCleaningDate = streetCleaningDate;
                }
            }
        }
    }
    return _closestStreetCleaningDate;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setup warning text
    self.warningTextView.text = [NSString stringWithFormat:@"You must move your car before\n\n%@.", [self.dateFormatter stringFromDate:self.closestStreetCleaningDate]];
    
    // Clear summary text
    self.alarmSummaryTextView.text = @"";
    
    // Disable done button
    self.doneBarButton.enabled = NO;
}

- (IBAction)setAlarmButtonPressed:(UIButton *)sender {
    
    // Prepare alarm date
    NSDate *alarmDate = nil;
    switch (self.alarmIntervalSegmentedControl.selectedSegmentIndex) {
        case 0: {
            alarmDate = [NSDate dateWithTimeInterval:-ONE_DAY sinceDate:self.closestStreetCleaningDate];
            break;
        }
        case 1: {
            alarmDate = [NSDate dateWithTimeInterval:-ONE_DAY/2 sinceDate:self.closestStreetCleaningDate];
            break;
        }
        case 2: {
            alarmDate = [NSDate dateWithTimeInterval:-ONE_DAY/24 sinceDate:self.closestStreetCleaningDate];
            break;
        }
        case 3: {
            alarmDate = [NSDate dateWithTimeInterval:-ONE_DAY/48 sinceDate:self.closestStreetCleaningDate];
            break;
        }
        default: {
            alarmDate = [NSDate dateWithTimeInterval:-ONE_DAY sinceDate:self.closestStreetCleaningDate];
            break;
        }
    }
    
    // Set alarm for closetsStreetCleaningDate
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    
    // Update alarm summary view
    NSString *newAlarmText = [NSString stringWithFormat:@"Alarm set for\n%@\n\n", [self.dateFormatter stringFromDate:alarmDate]];
    self.alarmSummaryTextView.text = [newAlarmText stringByAppendingString:self.alarmSummaryTextView.text];
    
    [self.alarmSummaryTextView scrollRangeToVisible:[self.alarmSummaryTextView.text rangeOfString:newAlarmText]];
    
    // Configure alarm
    localNotif.fireDate = alarmDate;
    localNotif.alertAction = [NSString stringWithFormat:@"Street cleaning in %@.", [self.alarmIntervalSegmentedControl titleForSegmentAtIndex:self.alarmIntervalSegmentedControl.selectedSegmentIndex]];
    localNotif.alertBody = [NSString stringWithFormat:@"Your car is parked at %@ %@.", self.number, self.street];
    localNotif.alertLaunchImage = @"SFStreetSweeping152.png";
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
    self.doneBarButton.enabled = YES;
}

- (IBAction)doneBarButtonPressed:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
