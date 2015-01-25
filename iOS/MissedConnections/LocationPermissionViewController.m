//
//  LocationPermissionViewController.m
//  MissedConnections
//
//  Created by Adrien on 1/24/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import "LocationPermissionViewController.h"
#import "LocationController.h"

@interface LocationPermissionViewController ()

- (IBAction)allowLocationAccessButtonWasTapped;

@property (nonatomic, weak) IBOutlet UIButton *giveLocationAccessButton;

@end

@implementation LocationPermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.giveLocationAccessButton.backgroundColor = [UIColor greenColor];
    self.giveLocationAccessButton.layer.shadowOffset = CGSizeMake(0, 3);
    self.giveLocationAccessButton.layer.shadowOpacity = 1.0;
    self.giveLocationAccessButton.layer.shadowRadius = 0;
    self.giveLocationAccessButton.layer.shadowColor = [[UIColor colorWithRed:0.0f/255.0f green:167.0f/255.0f blue:135.0f/255.0f alpha:1.0] CGColor];
    [self.giveLocationAccessButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)allowLocationAccessButtonWasTapped
{
    [[LocationController sharedController].locationManager requestAlwaysAuthorization];
}

@end
