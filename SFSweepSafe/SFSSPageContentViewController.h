//
//  SFSSContentViewController.h
//  SFSweepSafe
//
//  Created by Raymond Louie on 4/18/14.
//  Copyright (c) 2014 Raymond Louie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFSSPageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;

@end
