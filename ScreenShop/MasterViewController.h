//
//  MasterViewController.h
//  ScreenShop
//
//  Created by Toby Muresianu on 2/6/15.
//  Copyright (c) 2015 ScreenshopTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionSheetCustomPicker.h"

#define BATTERY_NOT_SET -1
#define BATTERY_ROW 0
#define RECEPTION_ROW 1
#define CARRIER_ROW 2
#define NOTIFICATION_ROW 3
#define NOKIA_ROW 4
#define SAVE_ROW 5

#define NO_CHANGE_ROW 0
//#define TIME_ROW 4

#define COLLECTION_VIEW_TOP_BORDER 20
#define COLLECTION_VIEW_SIDE_BORDER 20

@interface MasterViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ActionSheetCustomPickerDelegate>

-(IBAction)save:(id)sender;
-(IBAction)changePhotoButtonPushed:(id)sender;
-(IBAction)showCarrierPicker:(id)sender;
-(IBAction)showBatteryPicker:(id)sender;
-(IBAction)showTimePicker:(id)sender;
//-(IBAction)showNotificationPicker:(id)sender;
-(IBAction)showReceptionPicker:(id)sender;

//buttons
-(IBAction)randomNotificationAdded:(id)sender;
-(IBAction)randomNotificationRemoved:(id)sender;

@property (nonatomic) IBOutlet UIButton *carrierButton;
@property (nonatomic) IBOutlet UIButton *receptionButton;
@property (nonatomic) IBOutlet UIButton *notificationButton;
@property (nonatomic) IBOutlet UIButton *batteryButton;
@property (nonatomic) IBOutlet UIButton *timeButton;
@property (nonatomic) IBOutlet UIButton *modifyScreenshotButton;

@property IBOutlet UIImageView *batteryOverlay;
@property IBOutlet UIImageView *receptionOverlay;
@property IBOutlet UIView *carrierView;
@property IBOutlet UILabel *carrierLabel;
@property IBOutlet UIImageView *notificationOverlay;

@property (nonatomic) IBOutlet UIImageView *screenshotImageView;
@property (nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) UISegmentedControl *batteryControl;
@property (nonatomic) UILabel *batteryLabel;

@property (nonatomic) UILabel *receptionLabel;
@property (nonatomic) UISegmentedControl *receptionControl;

@end

