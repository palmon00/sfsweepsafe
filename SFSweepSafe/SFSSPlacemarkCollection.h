//
//  SFSSPlacemarkCollection.h
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/17/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFSSPlacemarkCollection : NSObject

@property (strong, nonatomic, readonly) NSMutableArray *placemarks; // of SFSSPlacemark;

-(instancetype)initWithFile:(NSString *)file;

-(NSArray *)placemarksFilteredByStreet:(NSString *)street andNumber:(NSString *)number;

@end
