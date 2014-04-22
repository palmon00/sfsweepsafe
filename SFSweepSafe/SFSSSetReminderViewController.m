//
//  SFSSSetViewController.m
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/17/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import "SFSSSetReminderViewController.h"
#import "SFSSPlacemark.h"
#import <EventKit/EventKit.h>
#import "SFSSAppDelegate.h"

@interface SFSSSetReminderViewController ()
@property (weak, nonatomic) IBOutlet UITextView *warningTextView;
@property (weak, nonatomic) IBOutlet UILabel *setReminderLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *reminderIntervalSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *beforeThenLabel;
@property (weak, nonatomic) IBOutlet UIButton *setReminderButton;
@property (weak, nonatomic) IBOutlet UITextView *reminderSummaryTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDate *closestStreetCleaningDate;

@property (strong, nonatomic) NSCalendar *gregorian;

@end

#define ONE_DAY 86400

@implementation SFSSSetReminderViewController

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
            NSLog(@"cleaningWeekDay is %d", (int)cleaningWeekDay);
            
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

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setup warning text
    self.warningTextView.text = [NSString stringWithFormat:@"You must move your car before\n\n%@.", [self.dateFormatter stringFromDate:self.closestStreetCleaningDate]];
    
    // Clear summary text
    self.reminderSummaryTextView.text = @"";
    
    // Disable done button
    self.doneBarButton.enabled = NO;
    
    // Add motion effects
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(MOTION_EFFECT_MIN);
    horizontalMotionEffect.maximumRelativeValue = @(MOTION_EFFECT_MAX);
    
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(MOTION_EFFECT_MIN);
    verticalMotionEffect.maximumRelativeValue = @(MOTION_EFFECT_MAX);
    
    [self.warningTextView addMotionEffect:horizontalMotionEffect];
    [self.warningTextView addMotionEffect:verticalMotionEffect];
    [self.setReminderLabel addMotionEffect:horizontalMotionEffect];
    [self.setReminderLabel addMotionEffect:verticalMotionEffect];
    [self.reminderIntervalSegmentedControl addMotionEffect:horizontalMotionEffect];
    [self.reminderIntervalSegmentedControl addMotionEffect:verticalMotionEffect];
    [self.beforeThenLabel addMotionEffect:horizontalMotionEffect];
    [self.beforeThenLabel addMotionEffect:verticalMotionEffect];
    [self.setReminderButton addMotionEffect:horizontalMotionEffect];
    [self.setReminderButton addMotionEffect:verticalMotionEffect];
    [self.reminderSummaryTextView addMotionEffect:horizontalMotionEffect];
    [self.reminderSummaryTextView addMotionEffect:verticalMotionEffect];
}

#pragma mark - Reminder and Local Notif

- (BOOL)scheduleEventForDate:(NSDate *)reminderDate withEventStore:(EKEventStore *)eventStore
{
    // Set an event (1/2 hr in duration)
    NSDate *reminderEndDate = [NSDate dateWithTimeInterval:ONE_DAY/48 sinceDate:reminderDate];
    
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.calendar = [eventStore defaultCalendarForNewEvents];
    event.startDate = reminderDate;
    event.endDate = reminderEndDate;
    event.availability = EKEventAvailabilityBusy;
    event.title = @"Move my car";
    event.location = [NSString stringWithFormat:@"%@ %@ San Francisco, California", self.number, self.street];
    event.notes = [NSString stringWithFormat:@"SF Sweep Safe\nReminder to move your car at %@ %@ San Francisco, California\n\nStreet cleaning will take place at %@", self.number, self.street, [self.dateFormatter stringFromDate:self.closestStreetCleaningDate]];
    
    // Add an alarm
    EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:reminderDate];
    [event addAlarm:alarm];
    
    // Save event
    NSError *error = nil;
    BOOL success = [eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
    if (!error) {
        if (success) {
            // Update reminder summary view
            NSString *newreminderText = [NSString stringWithFormat:@"Reminder set for\n%@\n\n", [self.dateFormatter stringFromDate:reminderDate]];
            dispatch_async(dispatch_get_main_queue(), ^{
            self.reminderSummaryTextView.text = [self.reminderSummaryTextView.text stringByAppendingString:newreminderText];
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

- (void)scheduleLocalNotifForDate:(NSDate *)reminderDate
{
    // Error saving, permission not granted or error requesting access; set a local notif
    // Set a local notification for closetsStreetCleaningDate
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    
    // Configure reminder
    localNotif.fireDate = reminderDate;
    localNotif.alertAction = [NSString stringWithFormat:@"Street cleaning in %@.", [self.reminderIntervalSegmentedControl titleForSegmentAtIndex:self.reminderIntervalSegmentedControl.selectedSegmentIndex]];
    localNotif.alertBody = [NSString stringWithFormat:@"Your car is parked at %@ %@.", self.number, self.street];
    localNotif.alertLaunchImage = @"SFStreetSweeping152.png";
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
    // Update reminder summary view
    NSString *newreminderText = [NSString stringWithFormat:@"Reminder set for\n%@\n\n", [self.dateFormatter stringFromDate:reminderDate]];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.reminderSummaryTextView.text = [self.reminderSummaryTextView.text stringByAppendingString:newreminderText];
        self.doneBarButton.enabled = YES;
    });
}

#pragma mark - IB Actions

- (IBAction)setreminderButtonPressed:(UIButton *)sender {
    
    // Prepare reminder date
    NSDate *reminderDate = nil;
    switch (self.reminderIntervalSegmentedControl.selectedSegmentIndex) {
        case 0: {
            reminderDate = [NSDate dateWithTimeInterval:-ONE_DAY sinceDate:self.closestStreetCleaningDate];
            break;
        }
        case 1: {
            reminderDate = [NSDate dateWithTimeInterval:-ONE_DAY/2 sinceDate:self.closestStreetCleaningDate];
            break;
        }
        case 2: {
            reminderDate = [NSDate dateWithTimeInterval:-ONE_DAY/24 sinceDate:self.closestStreetCleaningDate];
            break;
        }
        case 3: {
            reminderDate = [NSDate dateWithTimeInterval:-ONE_DAY/48 sinceDate:self.closestStreetCleaningDate];
            break;
        }
        default: {
            reminderDate = [NSDate dateWithTimeInterval:-ONE_DAY sinceDate:self.closestStreetCleaningDate];
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
                    if ([self scheduleEventForDate:reminderDate withEventStore:eventStore]) return;
                } else {
                    // Permission not granted
                    NSLog(@"requestAccessToEntityType permission not granted");
                }
            } else {
                // Error occurred requesting access
                NSLog(@"%@", error);
            }
            // Schedule a local notif if event fails
            [self scheduleLocalNotifForDate:reminderDate];
        }];
    } else {
        // Schedule a local notif if app delegate is not SFSSAppDelegate
        [self scheduleLocalNotifForDate:reminderDate];
    }
}

- (IBAction)doneBarButtonPressed:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
