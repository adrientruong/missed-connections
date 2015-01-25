//
//  MainViewController.h
//  MissedConnections
//
//  Created by Sachin Kesiraju on 1/25/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;

@end
