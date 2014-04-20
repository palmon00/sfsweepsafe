//
//  SFSSPlacemarkCollection.m
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/17/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import "SFSSPlacemarkCollection.h"
#import "SFSSPlacemark.h"

@interface SFSSPlacemarkCollection ()

@property (strong, nonatomic, readwrite) NSMutableArray *placemarks;

@end

@implementation SFSSPlacemarkCollection

-(instancetype)initWithFile:(NSString *)file
{
    self = [super init];
    
    if (self) {
        
        // open file
        _placemarks = [[NSMutableArray alloc] init];
        
        NSString *dataPath = [[NSBundle mainBundle] pathForResource:file ofType:nil];
        
        NSError *error = nil;
        NSString *fileContents = [NSString stringWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:&error];
        
        if (!error) {
            NSArray *placemarkStrings = [fileContents componentsSeparatedByString:@"\n"];
            for (NSString *placemarkString in placemarkStrings) {
                [_placemarks addObject:[[SFSSPlacemark alloc] initWithString:placemarkString]];
            }
        } else {
            NSLog(@"%@", error);
        }
    }
    return self;
}

// Returns array of placemarks filtered by a street name and address number
- (NSArray *)placemarksFilteredByStreet:(NSString *)street andNumber:(NSString *)number
{
    NSMutableArray *filteredPlacemarks = [[NSMutableArray alloc] init];
    
    NSArray *evenBlockSides = @[@"North", @"East", @"Northwest", @"SouthWest"]; // SF has even numbering on these blocksides
    NSArray *oddBlockSides = @[@"South", @"West", @"Southeast", @"Northeast"]; // and odd numbering on these blocksides
    
    NSInteger addressNumber = [number integerValue];
    BOOL odd = addressNumber % 2;
    
    
    for (SFSSPlacemark *placemark in self.placemarks) {
        
        // Ignore "Holiday" entries
        if (![placemark.date isEqualToString:@"Holiday"]) {
            
            // Street must match
            if ([placemark.street isEqualToString:street]) {
                
                // address number must be between left or right numbers
                if ((placemark.startLeftNumber <= addressNumber &&
                     addressNumber <= placemark.endLeftNumber) ||
                    (placemark.startRightNumber <= addressNumber &&
                     addressNumber <= placemark.endRightNumber)) {
                        
                        // and blockside can be null
                        // or odd and match an odd blockside
                        // or even and match an even blockside
                        if ([placemark.blockside isEqualToString:@"(null)"] ||
                            (odd && ([oddBlockSides indexOfObject:placemark.blockside] != NSNotFound)) ||
                            (!odd && ([evenBlockSides indexOfObject:placemark.blockside] != NSNotFound))) {
                            
                            // Otherwise, add to results
                            [filteredPlacemarks addObject:placemark];
                        }
                    }
            }
        }
    }
    
    return [NSArray arrayWithArray:filteredPlacemarks];
}

@end
