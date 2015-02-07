//
//  MasterViewController.m
//  ScreenShop
//
//  Created by Toby Muresianu on 2/6/15.
//  Copyright (c) 2015 ScreenshopTeam. All rights reserved.
//

#import "MasterViewController.h"
#import "ControlCollectionViewCell.h"

@interface MasterViewController ()

@property NSInteger batteryLevel;
@property NSInteger receptionLevel;

@property NSString *timeString;
@property NSString *carrier;

@property NSMutableArray *notificationImages;
@property NSString *selectedNotificationName;

//segmented control or slider
-(void)batteryLevelAdjusted:(id)sender;
-(void)receptionLevelAdjusted:(id)sender;

//Selection wheels
-(void)carrierAdjusted:(id)sender;
-(void)timeUpdated:(id)sender;

//buttons
-(void)randomNotificationAdded;
-(void)randomNotificationRemoved;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionView];
    [self setupNotificationImages];
}

-(void)setupNotificationImages {
    
    self.notificationImages = [NSMutableArray arrayWithObjects:@"twitterNotification", @"fbNotification", @"gmailNotification", nil];
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

#pragma mark - IBActions

-(IBAction)save:(id)sender {
    NSLog(@"Save image to photos");
}

-(IBAction)changePhotoButtonPushed:(id)sender{
    
    NSLog(@"Select a new photo from photos");
    
}

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
    
    self.batteryLabel.text = [NSString stringWithFormat:@"Battery: %li%%", self.batteryLevel];
    
}

-(void)receptionLevelAdjusted:(id)sender {
    
    self.receptionLevel = ((UISegmentedControl *)sender).selectedSegmentIndex;
    
    //adjust the screenshot for the new reception value
    
}

-(void)carrierAdjusted:(NSString *)newCarrier {
    
    self.carrier = newCarrier;
    
}

-(void)timeUpdated:(NSDate *)newDate {
    
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    myDateFormatter.timeStyle = NSDateFormatterShortStyle;
    myDateFormatter.dateStyle = NSDateFormatterNoStyle;
    
    self.timeString = [myDateFormatter stringFromDate:newDate];
    
}
-(void)randomNotificationAdded {
    
    int randomIndex = (int)arc4random_uniform(self.notificationImages.count);
    
    if (randomIndex == self.notificationImages.count) {
        randomIndex--;
    }
    
    self.selectedNotificationName = (NSString *)[self.notificationImages objectAtIndex:randomIndex];
    [self.notificationImages removeObjectAtIndex:randomIndex];
    
    //code to add notification to screenshot goes here
    
}
-(void)randomNotificationRemoved {
    
    [self.notificationImages addObject:self.selectedNotificationName];
    self.selectedNotificationName = nil;
    
    //code to remove notification from screenshot goes here
    
    
}

-(void)updateCarrierOnScreenshot {
    //use self.carrier for the carrier name
}
-(void)updateReceptionOnScreenshot {
    //use self.receptionLevel for value
    
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
    return 2;
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
        default:
            break;
    }
    
    
    return cell;
}

-(void)configureReceptionCell:(UICollectionViewCell *)cell {
    
    
    UISegmentedControl *batteryControl = (UISegmentedControl *)[cell viewWithTag:2];
    
    if (self.receptionControl == nil){
        self.receptionControl = batteryControl;
        [self.receptionControl addTarget:self action:@selector(batteryLevelAdjusted:) forControlEvents:UIControlEventValueChanged];
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
@end
