//
//  SFSSPlacemark.h
//
//  Created by Raymond Louie on 4/16/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define SFSSWEEKSTYPEUNKNOWN @"Unknown"
#define SFSSWEEKSTYPE1ST @"1st"
#define SFSSWEEKSTYPE1ST3RD @"1st and 3rd"
#define SFSSWEEKSTYPE2ND4TH @"2nd and 4th"
#define SFSSWEEKSTYPE1ST3RD5TH @"1st, 3rd, and 5th"
#define SFSSWEEKSTYPEEVERY @"Every"

@interface SFSSPlacemark : NSObject

@property (strong, nonatomic, readonly) NSString *street;
@property (nonatomic, readonly) NSInteger startLeftNumber;
@property (nonatomic, readonly) NSInteger endLeftNumber;
@property (nonatomic, readonly) NSInteger startRightNumber;
@property (nonatomic, readonly) NSInteger endRightNumber;
@property (nonatomic, readonly) NSInteger zip;
@property (strong, nonatomic, readonly) NSString *date; // @"Sun", @"Mon", @"Tues", @"Wed", @"Thu", @"Fri", @"Sat"
@property (strong, nonatomic, readonly) NSString *blockside;
@property (nonatomic, readonly) NSInteger fromHour;
@property (nonatomic, readonly) NSInteger toHour;
@property (nonatomic, readonly) BOOL holidays;
@property (nonatomic, readonly) BOOL week1ofMonth;
@property (nonatomic, readonly) BOOL week2ofMonth;
@property (nonatomic, readonly) BOOL week3ofMonth;
@property (nonatomic, readonly) BOOL week4ofMonth;
@property (nonatomic, readonly) BOOL week5ofMonth;
@property (strong, nonatomic, readonly) NSMutableArray *coordinates; // of CLLocation

+(NSArray *)dates;  // @[@"Sun", @"Mon", @"Tues", @"Wed", @"Thur", @"Fri", @"Sat"]

-(NSString *)weeksOfMonthType;
-(NSString *)fromHourAMPM;
-(NSString *)toHourAMPM;

- (instancetype)initWithString:(NSString *)placemarkString;

- (instancetype)initWithNumber:(NSString *)number street:(NSString *)street date:(NSString *)date fromHour:(NSInteger)fromHour toHour:(NSInteger)toHour weeksOfMonthType:(NSString *)weeksOfMonthType;

- (instancetype)initWithPlacemark:(SFSSPlacemark *)placemark andDate:(NSString *)date;

@end
