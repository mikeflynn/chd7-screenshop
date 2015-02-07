//
//  MasterViewController.h
//  ScreenShop
//
//  Created by Toby Muresianu on 2/6/15.
//  Copyright (c) 2015 ScreenshopTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

-(IBAction)save:(id)sender;
-(IBAction)sliderAdjusted:(id)sender;
-(IBAction)changePhotoButtonPushed:(id)sender;

@property (nonatomic) IBOutlet UIImageView *screenshotImageView;

@end

