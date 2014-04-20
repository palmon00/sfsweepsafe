//
//  SFSSSetAlarmViewController.m
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/17/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import "SFSSSetAlarmViewController.h"
#import "SFSSPlacemark.h"
#import <EventKit/EventKit.h>
#import "SFSSAppDelegate.h"

@interface SFSSSetAlarmViewController ()
@property (weak, nonatomic) IBOutlet UITextView *warningTextView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *alarmIntervalSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextView *alarmSummaryTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDate *closestStreetCleaningDate;

@property (strong, nonatomic) NSCalendar *gregorian;

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
        
        // Get the current year, month, day, hour
        NSDateComponents *allComponents = [self.gregorian components:NSEraCalendarUnit |
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
                [streetCleaningDates addObject:[self.gregorian dateFromComponents:components]];
                
                // add street cleaning date for next month
                [components setMonth:(currentMonth + 1)];
                [streetCleaningDates addObject:[self.gregorian dateFromComponents:components]];
            }
            
            if (placemark.week2ofMonth) {
                // add street cleaning date for this month
                [components setMonth:currentMonth];
                [components setWeekdayOrdinal:2]; // 2nd week of month
                [streetCleaningDates addObject:[self.gregorian dateFromComponents:components]];
                
                // add street cleaning date for next month
                [components setMonth:(currentMonth + 1)];
                [streetCleaningDates addObject:[self.gregorian dateFromComponents:components]];
            }
            
            if (placemark.week3ofMonth) {
                // add street cleaning date
                [components setMonth:currentMonth];
                [components setWeekdayOrdinal:3]; // 3rd week of month
                [streetCleaningDates addObject:[self.gregorian dateFromComponents:components]];
                
                // add street cleaning date for next month
                [components setMonth:(currentMonth + 1)];
                [streetCleaningDates addObject:[self.gregorian dateFromComponents:components]];
            }
            
            if (placemark.week4ofMonth) {
                // add street cleaning date
                [components setMonth:currentMonth];
                [components setWeekdayOrdinal:4]; // 4th week of month
                [streetCleaningDates addObject:[self.gregorian dateFromComponents:components]];
                
                // add street cleaning date for next month
                [components setMonth:(currentMonth + 1)];
                [streetCleaningDates addObject:[self.gregorian dateFromComponents:components]];
            }
            
            if (placemark.week5ofMonth) {
                // add street cleaning date
                [components setMonth:currentMonth];
                [components setWeekdayOrdinal:5]; // 5th week of month
                [streetCleaningDates addObject:[self.gregorian dateFromComponents:components]];
                
                // add street cleaning date for next month
                [components setMonth:(currentMonth + 1)];
                [streetCleaningDates addObject:[self.gregorian dateFromComponents:components]];
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

-(NSCalendar *)gregorian
{
    if (!_gregorian) _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return _gregorian;
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
    
    // Set a calendar event or local notif
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate isKindOfClass:[SFSSAppDelegate class]]) {
        EKEventStore *eventStore = [delegate eventStore];
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (!error) {
                if (granted) {
                    if ([self scheduleEventForDate:alarmDate withEventStore:eventStore]) return;
                } else {
                    // Permission not granted
                    NSLog(@"requestAccessToEntityType permission not granted");
                }
            } else {
                // Error occurred requesting access
                NSLog(@"%@", error);
            }
            // Schedule a local notif if event fails
            [self scheduleLocalNotifForDate:alarmDate];
        }];
    } else {
        // Schedule a local notif if app delegate is not SFSSAppDelegate
        [self scheduleLocalNotifForDate:alarmDate];
    }
}

#pragma mark - Local Notif

- (BOOL)scheduleEventForDate:(NSDate *)alarmDate withEventStore:(EKEventStore *)eventStore
{
    // Set an event (1/2 hr in duration)
    NSDate *alarmEndDate = [NSDate dateWithTimeInterval:ONE_DAY/48 sinceDate:alarmDate];
    
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.calendar = [eventStore defaultCalendarForNewEvents];
    event.startDate = alarmDate;
    event.endDate = alarmEndDate;
    event.availability = EKEventAvailabilityBusy;
    event.title = @"Move my car";
    event.location = [NSString stringWithFormat:@"%@ %@", self.number, self.street];
    event.notes = [NSString stringWithFormat:@"SF Sweep Safe\nReminder to move your car at %@ %@\n\nStreet cleaning will take place at %@", self.number, self.street, [self.dateFormatter stringFromDate:self.closestStreetCleaningDate]];
    
    // Add an alarm
    EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:alarmDate];
    [event addAlarm:alarm];
    
    // Save event
    NSError *error = nil;
    BOOL success = [eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
    if (!error) {
        if (success) {
            // Update alarm summary view
            NSString *newAlarmText = [NSString stringWithFormat:@"Reminder set for\n%@\n\n", [self.dateFormatter stringFromDate:alarmDate]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.alarmSummaryTextView.text = [newAlarmText stringByAppendingString:self.alarmSummaryTextView.text];
                self.doneBarButton.enabled = YES;
            });
            return YES;
        } else {
            // Not successful
            NSLog(@"saveEvent not successful");
        }
    } else {
        // Error occurred saving
        NSLog(@"%@", error);
    }
    return NO;
}

- (void)scheduleLocalNotifForDate:(NSDate *)alarmDate
{
    // Error saving, permission not granted or error requesting access; set a local notif
    // Set a local notification for closetsStreetCleaningDate
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    
    // Configure alarm
    localNotif.fireDate = alarmDate;
    localNotif.alertAction = [NSString stringWithFormat:@"Street cleaning in %@.", [self.alarmIntervalSegmentedControl titleForSegmentAtIndex:self.alarmIntervalSegmentedControl.selectedSegmentIndex]];
    localNotif.alertBody = [NSString stringWithFormat:@"Your car is parked at %@ %@.", self.number, self.street];
    localNotif.alertLaunchImage = @"SFStreetSweeping152.png";
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
    // Update alarm summary view
    NSString *newAlarmText = [NSString stringWithFormat:@"Reminder set for\n%@\n\n", [self.dateFormatter stringFromDate:alarmDate]];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.alarmSummaryTextView.text = [newAlarmText stringByAppendingString:self.alarmSummaryTextView.text];
        self.doneBarButton.enabled = YES;
    });
}

- (IBAction)doneBarButtonPressed:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
