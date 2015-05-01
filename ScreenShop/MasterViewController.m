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
#import "ActionSheetCustomPicker.h"

#import <Photos/Photos.h>


@interface MasterViewController ()

@property NSInteger batteryLevel;
@property NSInteger receptionLevel;
@property NSString *timeString;

@property NSString *carrier;
@property NSArray *carriers;
@property NSString *carrierSpeed;
@property NSArray *carrierSpeeds;

@property NSString *signalStrength;
@property NSArray *signalStrengths;

@property NSMutableArray *notificationImages;
@property NSString *selectedNotificationName;

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
    //[self setupCollectionView];
    [self setupNotificationImages];
    [self setDefaultImage];
    
    self.navigationController.navigationBarHidden = YES;
    self.batteryLevel = BATTERY_NOT_SET;
    self.selectedNotificationIndex = 0;
    self.carrierSpeed = @"4G";
    
    [self.screenshotImageView addSubview:self.batteryOverlay];
    [self.screenshotImageView addSubview:self.receptionOverlay];
    [self.screenshotImageView addSubview:self.notificationOverlay];
    [self.screenshotImageView addSubview:self.carrierView];
    
    self.carriers = @[@"No change",@"AT&T", @"Verizon", @"T-Mobile", @"Sprint", @"Boost", @"Metro PCS", @"Vodafone UK (+)", @"Bell Canada (+)", @"Telecom NZ (+)", @"中国移动 (+)"];
    self.carrierSpeeds = @[@"No change", @"EDGE", @"3G", @"4G", @"4G LTE", @"7G", @"Warren G"];
    self.signalStrengths = @[@"No bars", @"1 bar", @"3 bars", @"4 bars", @"5 bars"];
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

#pragma mark - Responding to actions

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

-(void)showNokia{
    
    //self.carrier = nil;
    self.carrierView.hidden = YES;
    self.carrierLabel.hidden = YES;
    self.batteryOverlay.hidden = YES;
    self.receptionOverlay.hidden = YES;
    self.notificationOverlay.hidden = YES;
    self.screenshotImageView.image = [UIImage imageNamed:@"nokia2.png"];
    
}

#pragma mark - Updating Screenshot

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
        
        NSString *carrier = ([self.carrier isEqualToString:@"Bell Canada"]) ? @"Bell" : self.carrier;
        self.carrierView.hidden = NO;
        self.carrierLabel.text = [NSString stringWithFormat:@"%@  %@", carrier, self.carrierSpeed];
        
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
    
    NSLog(@"updateReceptionOnScreenshot");
    
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
    NSLog(@"updateTimeOnScreenshot called");
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
    self.carrierView.hidden = NO;
}


#pragma mark - Collection View

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
#pragma mark - ActionSheets

-(IBAction)showCarrierPicker:(id)sender {
    
    ActionSheetCustomPicker *receptionPicker = [[ActionSheetCustomPicker alloc] initWithTitle:@"Pick Carrier and Speed" delegate:self showCancelButton:YES origin:sender];
    //sender initialSelections:@[self.carrier, [NSString stringWithFormat:@"%li", self.receptionLevel]]
    //receptionPicker.pickerView.tag = CARRIER_ROW;
    //receptionPicker.delegate = self;
    [receptionPicker showActionSheetPicker];
    
    /*
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
        
    } origin:sender];*/
    
}

-(IBAction)showReceptionPicker:(id)sender {
    
    /*
    ActionSheetCustomPicker *receptionPicker = [[ActionSheetCustomPicker alloc] initWithTitle:@"Select Reception Level" delegate:self showCancelButton:YES origin:sender];
    //sender initialSelections:@[self.carrier, [NSString stringWithFormat:@"%li", self.receptionLevel]]
    receptionPicker.delegate = self;
    
    [receptionPicker showActionSheetPicker];*/
    
    //[ActionSheetCustomPicker showPickerWithTitle:@"Select Reception Level" delegate:self showCancelButton:YES origin:sender];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Reception Level" rows:@[@"No change", @"1 bar", @"2 bars", @"3 bars", @"4 bars"] initialSelection:self.receptionLevel doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        
        self.receptionLevel = (selectedIndex < 4) ? selectedIndex : 4;
        NSLog(@"new reception level: %li", self.receptionLevel);
        
        [self updateReceptionOnScreenshot];
        
        /*
        if (!self.carrier) {
            self.carrier = @"Metro PCS";
        }
        
        if (selectedIndex == 5)
            self.carrierSpeed = @"LTE";
        else if (selectedIndex == 6){
            self.carrierSpeed = @"E";
            self.receptionLevel = 1;
            [self updateReceptionOnScreenshot];
        }
        else if (selectedIndex == 7)
            self.carrierSpeed = @"3G";
        else if (selectedIndex == 8)
            self.carrierSpeed = @"4G";
        else if (selectedIndex == 9)
            self.carrierSpeed = @"LTE";
        else if (selectedIndex == 10)
            self.carrierSpeed = @"7G";
        else if (selectedIndex == 11)
            self.carrierSpeed = @"WARREN G";
        [self updateCarrierOnScreenshot];
         */
        
        
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
/*
-(void)actionSheetPicker:(AbstractActionSheetPicker *)actionSheetPicker configurePickerView:(UIPickerView *)pickerView {
    
    NSLog(@"Configure picker view");
    
}
*/

/*
- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
    
    NSString *resultMessage;
    if (!self.selectedKey && !self.selectedScale)
    {
        
        resultMessage = [NSString stringWithFormat:@"Nothing is selected, inital selections: %@, %@",
                         notesToDisplayForKey[(NSUInteger) [(UIPickerView *) actionSheetPicker.pickerView selectedRowInComponent:0]],
                         scaleNames[(NSUInteger) [(UIPickerView *) actionSheetPicker.pickerView selectedRowInComponent:1]]];
    }
    else
        resultMessage = [NSString stringWithFormat:@"%@ %@ selected.",
                         self.selectedKey,
                         self.selectedScale];
    [[[UIAlertView alloc] initWithTitle:@"Success!" message:resultMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}
*/
/////////////////////////////////////////////////////////////////////////
#pragma mark - UIPickerViewDataSource Implementation
/////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSLog(@"Number of components in picker view: 2");
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    // Returns
    
    NSInteger numberOfRows;
    
    switch (component) {
        case 0:
            numberOfRows = [self.carriers count];
            break;
        case 1:
            numberOfRows = [self.carrierSpeeds count];
            break;
        default:
            numberOfRows = 0;
    }
    
    NSLog(@"Number of rows for component %li: %li", component, numberOfRows);
    
    return numberOfRows;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark UIPickerViewDelegate Implementation
/////////////////////////////////////////////////////////////////////////

// returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 160.0f;
}


/*- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
 {
 return
 }
 */
// these methods return either a plain UIString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSString *text;
    
    switch (component) {
        case 0:
            text = self.carriers[(NSUInteger) row];
            break;
        case 1:
            text = self.carrierSpeeds[(NSUInteger) row];
            break;
        default:
            text = @"NOT FOUND";
            break;
    }
    
    NSLog(@"titleForRow: %li component: %li string: %@", row, (long)component, text);
    return text;
}

/////////////////////////////////////////////////////////////////////////
/*
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Row %li selected in component %li", (long)row, (long)component);
    switch (component) {
        case 0:
            self.selectedKey = notesToDisplayForKey[(NSUInteger) row];
            return;
            
        case 1:
            self.selectedScale = scaleNames[(NSUInteger) row];
            return;
        default:break;
    }
}
*/


#pragma mark - UIPickerView

/*
-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *text;
    
    switch (row) {
        case 0:
            text = self.carriers[(NSUInteger) row];
        case 1:
            text = self.carrierSpeeds[(NSUInteger) row];
        default:
            break;
    }
    
    NSLog(@"Text: %@", text);
    
    return [[NSAttributedString alloc] initWithString:text];
}
*/

- (void) actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
    NSLog(@"actionPickerDidSucceed:");
    
    UIPickerView *pickerView = (UIPickerView *)actionSheetPicker.pickerView;
    
    NSInteger selectedCarrier, selectedSpeed;
    
    selectedCarrier = [pickerView selectedRowInComponent:0];
    selectedSpeed = [pickerView selectedRowInComponent:1];
    
    if (selectedSpeed == NO_CHANGE_ROW && selectedCarrier == NO_CHANGE_ROW)
        return;
    
    if (selectedCarrier != NO_CHANGE_ROW) {
        
        self.carrier = self.carriers[selectedCarrier];
    }
    
    if (selectedSpeed != NO_CHANGE_ROW){
        self.carrierSpeed = self.carrierSpeeds[selectedSpeed];
    }
    
    [self updateCarrierOnScreenshot];
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"didSelectRow called");
    /*
    self.carrier = [self.carriers objectAtIndex:row];
    [self updateCarrierOnScreenshot];*/
}

@end
