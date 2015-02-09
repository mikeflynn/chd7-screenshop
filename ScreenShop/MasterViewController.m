//
//  MasterViewController.m
//  ScreenShop
//
//  Created by Toby Muresianu on 2/6/15.
//  Copyright (c) 2015 ScreenshopTeam. All rights reserved.
//

#import "MasterViewController.h"
#import "ControlCollectionViewCell.h"

#import "ActionSheetStringPicker.h"
#import "ActionSheetDatePicker.h"

#import <Photos/Photos.h>


@interface MasterViewController ()

@property NSInteger batteryLevel;
@property NSInteger receptionLevel;

@property NSString *timeString;
@property NSString *carrier;
@property NSArray *carriers;

@property NSMutableArray *notificationImages;
@property NSString *selectedNotificationName;
@property NSString *signalStrength;

@property NSInteger selectedNotificationIndex;

@property UIImage *backupImage;

//@property UIView *carrierOverlay;

@property UIImagePickerController *imagePickerController;

//segmented control or slider
-(void)batteryLevelAdjusted:(id)sender;
-(void)receptionLevelAdjusted:(id)sender;

//Selection wheels
-(void)carrierAdjusted:(id)sender;
-(void)timeUpdated:(id)sender;


@end

@implementation MasterViewController



- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionView];
    [self setupNotificationImages];
    [self setDefaultImage];
    
    self.navigationController.navigationBarHidden = YES;
    self.batteryLevel = BATTERY_NOT_SET;
    self.selectedNotificationIndex = 0;
    self.signalStrength = @"4G";
    
    [self.screenshotImageView addSubview:self.batteryOverlay];
    [self.screenshotImageView addSubview:self.receptionOverlay];
    [self.screenshotImageView addSubview:self.notificationOverlay];
    [self.screenshotImageView addSubview:self.carrierView];
    
    self.carriers = @[@"Unchanged",@"AT&T", @"Verizon", @"T-Mobile", @"Sprint", @"Boost", @"Metro PCS", @"Vodafone UK (+)", @"Bell Canada (+)", @"Telecom NZ (+)", @"中国移动 (+)"];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)setupNotificationImages {
    
    self.notificationImages = [NSMutableArray arrayWithObjects:@"tinderNotification", @"okcNotification", @"gmailNotification", @"twitterNotification", nil];
}

-(void)setDefaultImage {
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    PHAsset *lastAsset = [fetchResult lastObject];
    [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                               targetSize:self.screenshotImageView.bounds.size
                                              contentMode:PHImageContentModeAspectFill
                                                  options:PHImageRequestOptionsVersionCurrent
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    
                                                    NSLog(@"Retrieved image w = %f h = %f", result.size.width, result.size.height);
                                                    
                                                    NSLog(@"my screen w = %f h = %f", [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                                                    
                                                    if (result != nil && result.size.height/2 == [UIScreen mainScreen].bounds.size.height && result.size.width/2 == [UIScreen mainScreen].bounds.size.width)
                                                        self.screenshotImageView.image = result;
                                                    
                                                });
                                            }];
}

-(void)setupCollectionView {
    
    /*
   [self.collectionView registerClass:[ControlCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    
    //CGFloat itemWidth = self.collectionView.frame.size.width - 2 * COLLECTION_VIEW_SIDE_BORDER;
    //CGFloat itemHeight = self.collectionView.frame.size.height - 2 * COLLECTION_VIEW_TOP_BORDER;
    
    //[flowLayout setItemSize:CGSizeMake(itemWidth, itemHeight)];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setCollectionViewLayout:flowLayout];*/
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Photos

-(IBAction)save:(id)sender {
    
    NSLog(@"Save image to photos");
    
    UIGraphicsBeginImageContextWithOptions(self.screenshotImageView.bounds.size, self.screenshotImageView.opaque, 0.0);
    [self.screenshotImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData* imdata = UIImagePNGRepresentation (viewImage); // get PNG representation
    UIImage* im2 = [UIImage imageWithData:imdata]; // wrap UIImage around PNG representation
    
    UIImageWriteToSavedPhotosAlbum(im2, self, // send the message to 'self' when calling the callback
                                   @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), // the selector to tell the method to call on completion
                                   NULL); // save to photo album
    
}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    
    UIAlertView *alert;
    
    if (error) {
        NSString *errorString = [NSString stringWithFormat:@"Unable to save picture in your saved photos. Your privacy settings may be preventing this. Try opening the Settings app and selecting \"Privacy\", then \"Photos\", and making sure ScreenShop has permission to access your photo library.\"\nFull error:\n%@.", [error description]];
        alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    } else {
        
            alert = [[UIAlertView alloc] initWithTitle:@"Image saved!" message:@"\nYour image has been saved as a picture in your saved photos.\n\nShare it with your friends safe from ridicule."delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];

        
    }
    
    [alert show];
    
}

-(IBAction)changePhotoButtonPushed:(id)sender{
    
    NSLog(@"Select a new photo from photos");
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;

    [self presentViewController:self.imagePickerController animated:YES completion:nil];
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    self.screenshotImageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions

-(void)batteryLevelAdjusted:(id)sender;{
    
    UISegmentedControl *control = sender;
    
    if (control.selectedSegmentIndex == 0) {
        //slider.value = 0;
        self.batteryLevel = 0;
    }
    else if (control.selectedSegmentIndex == 1){//slider.value < 0.75){
        //slider.value = 0.5;
        self.batteryLevel = -1;
    }
    else {
        //slider.value = 1;
        self.batteryLevel = 100;
    }
    
    NSLog(@"Battery: %li%%", self.batteryLevel);
    [self updateBatteryLevelOnScreenshot];
}

-(void)receptionLevelAdjusted:(id)sender {
    
    self.receptionLevel = ((UISegmentedControl *)sender).selectedSegmentIndex;
    
    NSLog(@"Reception level: %li", self.receptionLevel);
    
    //adjust the screenshot for the new reception value
    
    [self updateReceptionOnScreenshot];
    
}

-(void)carrierAdjusted:(NSString *)newCarrier {
    
    self.carrier = newCarrier;
    
    NSLog(@"New carrier: %@", newCarrier);
    
    [self updateCarrierOnScreenshot];
    
}

-(void)timeUpdated:(NSDate *)newDate {
    
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    myDateFormatter.timeStyle = NSDateFormatterShortStyle;
    myDateFormatter.dateStyle = NSDateFormatterNoStyle;
    
    self.timeString = [myDateFormatter stringFromDate:newDate];
    
    NSLog(@"New time string: %@", self.timeString);
    
    [self updateTimeOnScreenshot];
    
}
-(IBAction)randomNotificationAdded:(id)sender {
    
    
   // NSString *prevnotification = self.selectedNotificationName;
    
    //int randomIndex = (int)arc4random_uniform(100);
    //NSLog(@"Random index: %i", randomIndex);
    
    //randomIndex = randomIndex % self.notificationImages.count;
    
    if (self.selectedNotificationIndex == self.notificationImages.count) {
        self.selectedNotificationIndex = 0;
        [self removeNotificationFromScreenshot];
    }
    else {
        self.selectedNotificationName = (NSString *)[self.notificationImages objectAtIndex:self.selectedNotificationIndex];
        NSLog(@"Selected notification: %@", self.selectedNotificationName);
        [self addNewNotificationToScreenshot];
        
        self.selectedNotificationIndex++;
    }
    /*
    [self.notificationImages removeObjectAtIndex:randomIndex];
    
    if (prevnotification) {
        [self.notificationImages addObject:prevnotification];
    }*/
    
    
    
    
}
-(IBAction)randomNotificationRemoved:(id)sender {
    
    [self.notificationImages addObject:self.selectedNotificationName];
    self.selectedNotificationName = nil;
    
    if (self.selectedNotificationName) {
        
        NSLog(@"STILL selected notification: %@", self.selectedNotificationName);
    }
    else {
        NSLog(@"Removed notification");
    }
    
    [self removeNotificationFromScreenshot];
    
}

-(void)updateBatteryLevelOnScreenshot {
    
    if(self.batteryLevel == 0) {
        self.batteryOverlay.hidden = NO;
        self.batteryOverlay.image = [UIImage imageNamed:@"battery_empty"];
    } else if(self.batteryLevel == 100) {
        self.batteryOverlay.image = [UIImage imageNamed:@"battery_full"];
        self.batteryOverlay.hidden = NO;
    } else {
        self.batteryOverlay.hidden = YES;
    }
    
}

-(void)updateCarrierOnScreenshot {
    //use self.carrier for the carrier name

    if (self.carrier){
        
        self.carrierView.hidden = NO;
        self.carrierLabel.text = [NSString stringWithFormat:@"%@ %@", self.carrier, self.signalStrength];
        
    }
    else {
        self.carrierView.hidden = YES;
    }
    /*
    if(!self.carrier) {
        CGRect carrierOverlaySize = CGRectMake(20.0f, 20.0f, 100.0f, 20.0f);
        self.carrierOverlay = [[UIView alloc] initWithFrame:carrierOverlaySize];
    }
    
    if([self.carrier isEqual:@"Unchanged"]) {
        [self.carrierOverlay removeFromSuperview];
    } else {
        NSString *pattern = [NSString stringWithFormat:@"[\\-&\\s]+"];
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSString *carrierStr = [regex stringByReplacingMatchesInString:self.carrier options:0 range:NSMakeRange(0, self.carrier.length) withTemplate:@""];
        carrierStr = [carrierStr lowercaseString];
        
        NSString *carrierImg = [NSString stringWithFormat:@"carrier_%@", carrierStr];
        NSLog(@"Carrier Img: %@", carrierImg);
        //self.carrierOverlay.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:carrierImg]];
        self.carrierOverlay.backgroundColor = [UIColor redColor];
        [self.screenshotImageView addSubview:self.carrierOverlay];
    }*/
}

-(void)updateReceptionOnScreenshot {
    //use self.receptionLevel for value
    if(self.receptionLevel == -1) {
        self.receptionOverlay.hidden = YES;
    } else {
        NSString *receptionImg = [NSString stringWithFormat:@"reception_%ld", self.receptionLevel];
        
        self.receptionOverlay.image = [UIImage imageNamed:receptionImg];
        self.receptionOverlay.hidden = NO;
        //self.receptionOverlay.image = nil;
    }
}
-(void)updateTimeOnScreenshot {
    //use self.timeString for the string value
    
}
-(void)addNewNotificationToScreenshot{
    //self.selectedNotificationName is the image name
    
    self.carrierView.hidden = YES;
    self.notificationOverlay.hidden = NO;
    self.notificationOverlay.image = [UIImage imageNamed:self.selectedNotificationName];
}
-(void)removeNotificationFromScreenshot{
    //self.selectedNotificationName is the current image name

    self.notificationOverlay.hidden = YES;
}


#pragma mark - Table View

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"pictureCell" forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    
    NSString *imageName;
    
    switch (indexPath.row) {
        case BATTERY_ROW:
            imageName = @"screenshop-01.png";
            break;
        case RECEPTION_ROW:
            imageName = @"screenshop-02.png";
            break;
        case NOTIFICATION_ROW:
            imageName = @"screenshop-04.png";
            break;
        case CARRIER_ROW:
            imageName = @"screenshop-03.png";
            break;
        case NOKIA_ROW:
            imageName = @"screenshop-07.png";
            break;
        case SAVE_ROW:
            imageName = @"screenshop-08.png";
            break;
        default:
            break;
    }
    
    UIImage *image = [UIImage imageNamed:imageName];
    imageView.image = image;
    /*
    switch (indexPath.row) {
        case BATTERY_ROW:
            cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"batteryCell" forIndexPath:indexPath];
            [self configureBatteryCell:cell];
            break;
        case RECEPTION_ROW:
            cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"receptionCell" forIndexPath:indexPath];
            break;
        case NOTIFICATION_ROW:
            cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"notificationCell" forIndexPath:indexPath];
            break;
        case TIME_ROW:
            cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"timeCell" forIndexPath:indexPath];
            break;
        case CARRIER_ROW:
            cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"carrierCell" forIndexPath:indexPath];
            break;
        default:
            break;
    }
    */
    
    return cell;
}

-(void)showNotificationPicker:(id)sender {
    
    [self randomNotificationAdded:sender];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    switch (indexPath.row) {
        case BATTERY_ROW:
            [self showBatteryPicker:cell];
            break;
        case CARRIER_ROW:
            [self showCarrierPicker:cell];
            break;
        case NOTIFICATION_ROW:
            [self showNotificationPicker:cell];
            break;
        case RECEPTION_ROW:
            [self showReceptionPicker:cell];
            break;
        case NOKIA_ROW:
            [self showNokia];
            break;
        case SAVE_ROW:
            [self save:cell];
            break;
        default:
            break;
    }
}

-(void)showNokia{
    
    //self.carrier = nil;
    self.carrierView.hidden = YES;
    self.carrierLabel.hidden = YES;
    self.batteryOverlay.hidden = YES;
    self.receptionOverlay.hidden = YES;
    self.notificationOverlay.hidden = YES;
    self.screenshotImageView.image = [UIImage imageNamed:@"nokia.png"];
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
}

-(void)configureReceptionCell:(UICollectionViewCell *)cell {
    
    
    UISegmentedControl *batteryControl = (UISegmentedControl *)[cell viewWithTag:2];
    
    if (self.receptionControl == nil){
        self.receptionControl = batteryControl;
        [self.receptionControl addTarget:self action:@selector(receptionLevelAdjusted:) forControlEvents:UIControlEventValueChanged];
    }
    else if(self.receptionControl != batteryControl) {
        self.receptionControl = batteryControl;
    }
 
}

-(void)configureBatteryCell:(UICollectionViewCell *)cell {
    
    
    UISegmentedControl *batteryControl = (UISegmentedControl *)[cell viewWithTag:2];
    
    if (self.batteryControl == nil){
        self.batteryControl = batteryControl;
        [self.batteryControl addTarget:self action:@selector(batteryLevelAdjusted:) forControlEvents:UIControlEventValueChanged];
    }
    else if(self.batteryControl != batteryControl) {
        self.batteryControl = batteryControl;
    }
    
    /*
    self.batteryLabel = (UILabel *)[cell viewWithTag:1];
    
    if (self.batteryLevel == BATTERY_NOT_SET) {
        self.batteryLabel.text = @"Not changed";
    }
    else {
        self.batteryLabel.text = [NSString stringWithFormat:@"Battery: %li%%", self.batteryLevel];
    }*/
}
#pragma mark ActionSheets -

-(IBAction)showCarrierPicker:(id)sender {
    
    int selectedIndex = 0;
    
    if (self.carrier) {
        for (int i = 0; i < self.carriers.count; ++i) {
            if ([(NSString *)[self.carriers objectAtIndex:i] isEqualToString:self.carrier]){
                selectedIndex = i;
                break;
            }
        }
    }
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Carrier" rows:self.carriers initialSelection:selectedIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {

        self.carrier = (selectedIndex == 0) ? nil : [self.carriers objectAtIndex:selectedIndex];
        if (self.carrier && [self.carrier containsString:@" (+)"]){
            self.carrier = [self.carrier substringToIndex:(self.carrier.length - 4)];
        }
        NSLog(@"new carrier: %@", self.carrier);
        [self updateCarrierOnScreenshot];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:sender];
    
}

-(IBAction)showReceptionPicker:(id)sender {
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Reception Level" rows:@[@"No change", @"1 bar", @"2 bars", @"3 bars", @"4 bars", @"4 bars + LTE", @"EDGE", @"3G", @"4G", @"LTE", @"7G", @"WARREN G (+)"] initialSelection:self.receptionLevel doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        
        self.receptionLevel = (selectedIndex < 4) ? selectedIndex : 4;
        NSLog(@"new reception level: %li", self.receptionLevel);
        
        [self updateReceptionOnScreenshot];
        
        if (!self.carrier) {
            self.carrier = @"Metro PCS";
        }
        
        if (selectedIndex == 5)
            self.signalStrength = @"LTE";
        else if (selectedIndex == 6){
            self.signalStrength = @"E";
            self.receptionLevel = 1;
            [self updateReceptionOnScreenshot];
        }
        else if (selectedIndex == 7)
            self.signalStrength = @"3G";
        else if (selectedIndex == 8)
            self.signalStrength = @"4G";
        else if (selectedIndex == 9)
            self.signalStrength = @"LTE";
        else if (selectedIndex == 10)
            self.signalStrength = @"7G";
        else if (selectedIndex == 11)
            self.signalStrength = @"WARREN G";
        /*
        else
            self.signalStrength = @"4G";*/
        
        [self updateCarrierOnScreenshot];
        
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:sender];
    
}

-(IBAction)showTimePicker:(id)sender {
    
    [ActionSheetDatePicker showPickerWithTitle:@"Select time" datePickerMode:UIDatePickerModeTime selectedDate:[NSDate date] doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        
        [self timeUpdated:selectedDate];
        
    } cancelBlock:^(ActionSheetDatePicker *picker) {
        
    } origin:sender];
    
}
-(IBAction)showBatteryPicker:(id)sender {
    
    int selectedIndex;
    
    if (self.batteryLevel == BATTERY_NOT_SET) {
        selectedIndex = 0;
    }
    else if (self.batteryLevel == 0){
        selectedIndex = 1;
    }
    else {
        selectedIndex = 2;
    }
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Battery Level" rows:@[@"Unchanged", @"Empty", @"Full"]initialSelection:selectedIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        
        if (selectedIndex != 0 || self.batteryLevel != BATTERY_NOT_SET) {
            
        
        if (selectedIndex == 0)
            self.batteryLevel = BATTERY_NOT_SET;
        else if (selectedIndex == 1)
            self.batteryLevel = 0;
        else
            self.batteryLevel = 100;
        
        NSLog(@"New battery level: %li", self.batteryLevel);
        
        [self updateBatteryLevelOnScreenshot];
        }
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:sender];
    
}


#pragma mark - UIPickerView

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return self.carriers.count;
}
-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [[NSAttributedString alloc] initWithString:[self.carriers objectAtIndex:row]];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.carrier = [self.carriers objectAtIndex:row];
    [self updateCarrierOnScreenshot];
}
@end
