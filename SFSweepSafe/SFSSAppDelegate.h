//
//  SFSSAppDelegate.h
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/17/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface SFSSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic, readonly) EKEventStore *eventStore;

@end
