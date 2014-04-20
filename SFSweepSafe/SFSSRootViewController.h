//
//  SFSSRootViewController.h
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/18/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFSSRootViewController : UIViewController <UIPageViewControllerDataSource>

- (IBAction)startWalkthrough:(UIButton *)sender;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@end
