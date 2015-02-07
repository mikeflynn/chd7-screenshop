//
//  ControlCollectionViewCell.h
//  ScreenShop
//
//  Created by Toby Muresianu on 2/6/15.
//  Copyright (c) 2015 ScreenshopTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ControlCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UISlider *slider;

-(void)updateCell;

@end
