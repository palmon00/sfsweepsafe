//
//  SFSPOPlacemark.m
//
//  Created by Raymond Louie on 4/16/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import "SFSSPlacemark.h"

@interface SFSSPlacemark ()

@property (strong, nonatomic, readwrite) NSString *street;
@property (nonatomic, readwrite) NSInteger startLeftNumber;
@property (nonatomic, readwrite) NSInteger endLeftNumber;
@property (nonatomic, readwrite) NSInteger startRightNumber;
@property (nonatomic, readwrite) NSInteger endRightNumber;
@property (strong, nonatomic, readwrite) NSString *date;
@property (strong, nonatomic, readwrite) NSString *blockside;
@property (nonatomic, readwrite) NSInteger fromHour;
@property (nonatomic, readwrite) NSInteger toHour;
@property (nonatomic, readwrite) BOOL holidays;
@property (nonatomic, readwrite) BOOL week1ofMonth;
@property (nonatomic, readwrite) BOOL week2ofMonth;
@property (nonatomic, readwrite) BOOL week3ofMonth;
@property (nonatomic, readwrite) BOOL week4ofMonth;
@property (nonatomic, readwrite) BOOL week5ofMonth;
@property (strong, nonatomic, readwrite) NSMutableArray *coordinates; // of CLLocation

@end

@implementation SFSSPlacemark

+(NSArray *)dates
{
    return @[@"Sun", @"Mon", @"Tues", @"Wed", @"Thu", @"Fri", @"Sat"];
}

-(NSString *)weeksOfMonthType
{
    if (self.week1ofMonth &&
        !self.week2ofMonth &&
        !self.week3ofMonth &&
        !self.week4ofMonth &&
        !self.week5ofMonth)
        return SFSSWEEKSTYPE1ST;
    if (self.week1ofMonth &&
        self.week3ofMonth &&
        !self.week2ofMonth &&
        !self.week4ofMonth &&
        !self.week5ofMonth)
        return SFSSWEEKSTYPE1ST3RD;
    if (self.week2ofMonth &&
        self.week4ofMonth &&
        !self.week1ofMonth &&
        !self.week3ofMonth &&
        !self.week5ofMonth)
        return SFSSWEEKSTYPE2ND4TH;
    if (self.week1ofMonth &&
        self.week3ofMonth &&
        self.week5ofMonth &&
        !self.week2ofMonth &&
        !self.week4ofMonth)
        return SFSSWEEKSTYPE1ST3RD5TH;
    if (self.week1ofMonth &&
        self.week2ofMonth &&
        self.week3ofMonth &&
        self.week4ofMonth &&
        self.week5ofMonth)
        return SFSSWEEKSTYPEEVERY;
    return SFSSWEEKSTYPEUNKNOWN;
}

-(NSString *)fromHourAMPM
{
    return [self hourAMPM:self.fromHour];
}

-(NSString *)toHourAMPM
{
    return [self hourAMPM:self.toHour];
}

-(NSString *)hourAMPM:(NSInteger)hour
{
    if (hour == 0 || hour == 24) return @"12 A.M.";
    else if (hour < 12) return [NSString stringWithFormat:@"%d A.M.", (int)hour];
    else if (hour == 12) return @"12 P.M.";
    else if (hour < 24) return [NSString stringWithFormat:@"%d P.M.", (int)hour - 12];
    return nil;
}

- (instancetype)initWithString:(NSString *)placemarkString
{
    self = [super init];
    
    if (self) {
        if ([placemarkString length]) {
            // decompose string
            NSArray *fields = [placemarkString componentsSeparatedByString:@"|"];
            
            // extract data
            _street = fields[0];
            _startLeftNumber = [fields[1] integerValue];
            _endLeftNumber = [fields[2] integerValue];
            _startRightNumber = [fields[3] integerValue];
            _endRightNumber = [fields[4] integerValue];
            _zip = [fields[5] integerValue];
            _date = fields[6];
            _blockside = fields[7];
            _fromHour = [fields[8] integerValue];
            _toHour = [fields[9] integerValue];
            _holidays = [fields[10] isEqualToString:@"Y"] ? YES : NO;
            _week1ofMonth = [fields[11] isEqualToString:@"Y"] ? YES : NO;
            _week2ofMonth = [fields[12] isEqualToString:@"Y"] ? YES : NO;
            _week3ofMonth = [fields[13] isEqualToString:@"Y"] ? YES : NO;
            _week4ofMonth = [fields[14] isEqualToString:@"Y"] ? YES : NO;
            _week5ofMonth = [fields[15] isEqualToString:@"Y"] ? YES : NO;
            
            // Process coordinates
            NSString *coordinatesString = fields[16];
            _coordinates = [[NSMutableArray alloc] init];
            
            // Create CLLocations for each coordinate
            NSArray *cooridinateFields = [coordinatesString componentsSeparatedByString:@" "];
            for (NSString *coordinateField in cooridinateFields) {
                NSArray *coordinateStrings = [coordinateField componentsSeparatedByString:@","];
                if ([coordinateStrings count] == 2) {
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:[coordinateStrings[1]doubleValue] longitude:[coordinateStrings[0]doubleValue]];
                    [_coordinates addObject:location];
                }
            }
        }
    }
    return self;
}

- (instancetype)initWithPlacemark:(SFSSPlacemark *)placemark andDate:(NSString *)date
{
    self = [super init];
    
    if (self) {
        _street = placemark.street;
        _startLeftNumber = placemark.startLeftNumber;
        _endLeftNumber = placemark.endLeftNumber;
        _startRightNumber = placemark.startRightNumber;
        _endRightNumber = placemark.endRightNumber;
        _date = date;
        _blockside = placemark.blockside;
        _fromHour = placemark.fromHour;
        _toHour = placemark.toHour;
        _holidays = placemark.holidays;
        _week1ofMonth = placemark.week1ofMonth;
        _week2ofMonth = placemark.week2ofMonth;
        _week3ofMonth = placemark.week3ofMonth;
        _week4ofMonth = placemark.week4ofMonth;
        _week5ofMonth = placemark.week5ofMonth;
        _coordinates = placemark.coordinates;
    }
    return self;
}


- (instancetype)initWithNumber:(NSString *)number street:(NSString *)street date:(NSString *)date fromHour:(NSInteger)fromHour toHour:(NSInteger)toHour weeksOfMonthType:(NSString *)weeksOfMonthType
{
    self = [super init];
    
    if (self) {
        _street = street;
        _startLeftNumber = [number integerValue];
        _endLeftNumber = [number integerValue];
        _startRightNumber = [number integerValue];
        _endRightNumber = [number integerValue];
        _date = date;
        _blockside = @"(null)";
        _fromHour = fromHour;
        _toHour = toHour;
        _holidays = NO;
        
        if ([weeksOfMonthType isEqualToString:SFSSWEEKSTYPE1ST]) {
            _week1ofMonth = YES;
            _week2ofMonth = NO;
            _week3ofMonth = NO;
            _week4ofMonth = NO;
            _week5ofMonth = NO;
        } else if ([weeksOfMonthType isEqualToString:SFSSWEEKSTYPE1ST3RD]) {
            _week1ofMonth = YES;
            _week2ofMonth = NO;
            _week3ofMonth = YES;
            _week4ofMonth = NO;
            _week5ofMonth = NO;
        } else if ([weeksOfMonthType isEqualToString:SFSSWEEKSTYPE2ND4TH]) {
            _week1ofMonth = NO;
            _week2ofMonth = YES;
            _week3ofMonth = NO;
            _week4ofMonth = YES;
            _week5ofMonth = NO;
        } else if ([weeksOfMonthType isEqualToString:SFSSWEEKSTYPE1ST3RD5TH]) {
            _week1ofMonth = YES;
            _week2ofMonth = NO;
            _week3ofMonth = YES;
            _week4ofMonth = NO;
            _week5ofMonth = YES;
        } else if ([weeksOfMonthType isEqualToString:SFSSWEEKSTYPEEVERY]) {
            _week1ofMonth = YES;
            _week2ofMonth = YES;
            _week3ofMonth = YES;
            _week4ofMonth = YES;
            _week5ofMonth = YES;
        }
        _coordinates = [@[] mutableCopy];
    }
    return self;
}

@end