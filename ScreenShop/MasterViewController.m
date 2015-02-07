//
//  MasterViewController.m
//  ScreenShop
//
//  Created by Toby Muresianu on 2/6/15.
//  Copyright (c) 2015 ScreenshopTeam. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController ()

@property NSMutableArray *objects;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    cell.textLabel.text = @"Test";
    
    return cell;
}

@end
