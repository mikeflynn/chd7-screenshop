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
#define CARRIER_ROW 2
#define NOTIFICATION_ROW 3
#define TIME_ROW 4

#define COLLECTION_VIEW_TOP_BORDER 20
#define COLLECTION_VIEW_SIDE_BORDER 20

@interface MasterViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

-(IBAction)save:(id)sender;
-(IBAction)changePhotoButtonPushed:(id)sender;

//buttons
-(IBAction)randomNotificationAdded:(id)sender;
-(IBAction)randomNotificationRemoved:(id)sender;

@property (nonatomic) IBOutlet UIImageView *screenshotImageView;
@property (nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) UISegmentedControl *batteryControl;
@property (nonatomic) UILabel *batteryLabel;

@property (nonatomic) UILabel *receptionLabel;
@property (nonatomic) UISegmentedControl *receptionControl;

@end

