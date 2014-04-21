//
//  SFSSAppDelegate.m
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/17/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import "SFSSAppDelegate.h"

@interface SFSSAppDelegate ()

@property (strong, nonatomic, readwrite) EKEventStore *eventStore;

@end

@implementation SFSSAppDelegate

-(EKEventStore *)eventStore
{
    if (!_eventStore) _eventStore = [[EKEventStore alloc] init];
    return _eventStore;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    // setup nav bar
    [[UINavigationBar appearance] setBarTintColor:[UIColor clearColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{NSForegroundColorAttributeName : [UIColor whiteColor],// colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
       NSFontAttributeName : [UIFont fontWithName:@"Copperplate" size:20.0]}];
    
    // Change bar button item fonts
    NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [UIFont fontWithName:@"Copperplate" size:20.0]}; // , NSForegroundColorAttributeName: [UIColor blackColor]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Copperplate" size:12.0]} forState:UIControlStateNormal];
//    [[UILabel appearanceWhenContainedIn:[UISegmentedControl class], nil] setFont:[UIFont fontWithName:@"Copperplate" size:12.0]];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
