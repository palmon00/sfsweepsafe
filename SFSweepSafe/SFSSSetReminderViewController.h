//
//  SFSSSetReminderViewController.h
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/17/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SFSSPlacemark;

@interface SFSSSetReminderViewController : UIViewController

@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSString *street;
@property (strong, nonatomic) NSArray *placemarks; // of SFSSPlacemark;

@end