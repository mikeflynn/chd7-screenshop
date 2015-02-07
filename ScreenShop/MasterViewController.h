//
//  MasterViewController.h
//  ScreenShop
//
//  Created by Toby Muresianu on 2/6/15.
//  Copyright (c) 2015 ScreenshopTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BATTERY_NOT_SET -1

#define BATTERY_ROW 0
#define RECEPTION_ROW 1

#define COLLECTION_VIEW_TOP_BORDER 20
#define COLLECTION_VIEW_SIDE_BORDER 20

@interface MasterViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

-(IBAction)save:(id)sender;
-(IBAction)changePhotoButtonPushed:(id)sender;

@property (nonatomic) IBOutlet UIImageView *screenshotImageView;
@property (nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) UISegmentedControl *batteryControl;
@property (nonatomic) UILabel *batteryLabel;

@property (nonatomic) UILabel *receptionLabel;
@property (nonatomic) UISegmentedControl *receptionControl;

@end

