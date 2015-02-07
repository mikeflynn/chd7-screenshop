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

@property UIView *batteryOverlay;
@property UIView *receptionOverlay;
@property UIView *carrierOverlay;

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
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.carriers = @[@"Unchanged",@"AT&T", @"Verizon", @"T-Mobile", @"Sprint", @"Boost", @"Metro PCS"];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)setupNotificationImages {
    
    self.notificationImages = [NSMutableArray arrayWithObjects:@"twitterNotification", @"fbNotification", @"gmailNotification", nil];
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
    
   [self.collectionView registerClass:[ControlCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    
    CGFloat itemWidth = self.collectionView.frame.size.width - 2 * COLLECTION_VIEW_SIDE_BORDER;
    CGFloat itemHeight = self.collectionView.frame.size.height - 2 * COLLECTION_VIEW_TOP_BORDER;
    
    [flowLayout setItemSize:CGSizeMake(itemWidth, itemHeight)];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setCollectionViewLayout:flowLayout];
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
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.screenshotImageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
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
    
    
    NSString *prevnotification = self.selectedNotificationName;
    
    int randomIndex = (int)arc4random_uniform(100);
    NSLog(@"Random index: %i", randomIndex);
    
    randomIndex = randomIndex % self.notificationImages.count;
    
    if (randomIndex == self.notificationImages.count) {
        randomIndex--;
    }
    
    self.selectedNotificationName = (NSString *)[self.notificationImages objectAtIndex:randomIndex];
    [self.notificationImages removeObjectAtIndex:randomIndex];
    
    if (prevnotification) {
        [self.notificationImages addObject:prevnotification];
    }
    
    NSLog(@"Selected notification: %@", self.selectedNotificationName);
    
    [self addNewNotificationToScreenshot];
    
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
    if(!self.batteryOverlay) {
        CGRect batteryOverlaySize = CGRectMake(self.screenshotImageView.frame.size.width - 5.0f, 0.0f, 55.0f, 20.0f);
        self.batteryOverlay = [[UIView alloc] initWithFrame:batteryOverlaySize];
    }
    
    if(self.batteryLevel == 0) {
        //self.batteryOverlay.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"battery_full"]];
        self.batteryOverlay.backgroundColor = [UIColor redColor];
        [self.screenshotImageView addSubview:self.batteryOverlay];
    } else if(self.batteryLevel == 100) {
        self.batteryOverlay.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"battery_full"]];
        [self.screenshotImageView addSubview:self.batteryOverlay];
    } else {
        [self.batteryOverlay removeFromSuperview];
    }
}

-(void)updateCarrierOnScreenshot {
    //use self.carrier for the carrier name

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
    }
}

-(void)updateReceptionOnScreenshot {
    //use self.receptionLevel for value
    if(!self.receptionOverlay) {
        CGRect receptionOverlaySize = CGRectMake(0.0f, 0.0f, 85.0f, 20.0f);
        self.receptionOverlay = [[UIView alloc] initWithFrame:receptionOverlaySize];
    }
    
    if(self.receptionLevel == -1) {
        [self.receptionOverlay removeFromSuperview];
    } else {
        NSString *receptionImg = [NSString stringWithFormat:@"reception_%ld", self.receptionLevel];
        NSLog(@"Reception Img: %@", receptionImg);
        self.receptionOverlay.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:receptionImg]];
        //self.receptionOverlay.backgroundColor = [UIColor redColor];
        [self.screenshotImageView addSubview:self.receptionOverlay];
    }
}
-(void)updateTimeOnScreenshot {
    //use self.timeString for the string value
    
}
-(void)addNewNotificationToScreenshot{
    //self.selectedNotificationName is the image name
}
-(void)removeNotificationFromScreenshot{
    //self.selectedNotificationName is the current image name
}


#pragma mark - Table View

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell;
    
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
    
    
    return cell;
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
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select carrier" rows:self.carriers initialSelection:selectedIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {

        self.carrier = (selectedIndex == 0) ? nil : [self.carriers objectAtIndex:selectedIndex];
        NSLog(@"new carrier: %@", self.carrier);
        [self updateCarrierOnScreenshot];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:self.carrierButton];
    
}

-(IBAction)showReceptionPicker:(id)sender {
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select reception level" rows:@[@"No bars", @"1 bar", @"2 bars", @"3 bars", @"Full bars"] initialSelection:self.receptionLevel doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        self.receptionLevel = selectedIndex;
        NSLog(@"new reception level: %li", self.receptionLevel);
        
        [self updateReceptionOnScreenshot];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:self.carrierButton];
    
}

-(IBAction)showTimePicker:(id)sender {
    
    [ActionSheetDatePicker showPickerWithTitle:@"Select time" datePickerMode:UIDatePickerModeTime selectedDate:[NSDate date] doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        
        [self timeUpdated:selectedDate];
        
    } cancelBlock:^(ActionSheetDatePicker *picker) {
        
    } origin:self.timeButton];
    
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
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select battery level" rows:@[@"Unchanged", @"Empty", @"Full"]initialSelection:selectedIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        
        if (selectedIndex == 0)
            self.batteryLevel = BATTERY_NOT_SET;
        else if (selectedIndex == 1)
            self.batteryLevel = 0;
        else
            self.batteryLevel = 100;
        
        NSLog(@"New battery level: %li", self.batteryLevel);
        
        [self updateBatteryLevelOnScreenshot];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:self.carrierButton];
    
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
