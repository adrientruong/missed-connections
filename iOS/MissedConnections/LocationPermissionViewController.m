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

@end

@implementation LocationPermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
