//
//  MainViewController.m
//  MissedConnections
//
//  Created by Sachin Kesiraju on 1/25/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>

@interface MainViewController () <MKMapViewDelegate>

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    NSString *url = [NSString stringWithFormat:@"https://fierce-wildwood-9429.herokuapp.com/history?uid=%@", [[PFUser currentUser] objectForKey:@"fbid"]];
    NSLog(@"current id %@", [[PFUser currentUser] objectForKey:@"fbid"]);
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
        if(!error)
        {
            NSError *jsonError = nil;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if(!jsonError && jsonResponse)
            {
                NSArray *annotationLocation = jsonResponse[@"clusters"];
                for(NSDictionary *annotation in annotationLocation)
                {
                    CGPoint point = CGPointMake([annotation[@"coordinates"][@"x"] floatValue], [annotation[@"coordinates"][@"y"] floatValue]);
                    NSLog(@"coordinate point %f %f", point.x, point.y);
                    [self addAnnotationAtPoint:point];
                }
            }
        }
         else
         {
             NSLog(@"Error %@", error);
         }
     }];
}

- (void) addAnnotationAtPoint: (CGPoint) point
{
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(point.x, point.y);
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coord;
    NSLog(@"annotation %@", annotation);
    [self.mapView addAnnotation:annotation];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *customPinView = nil;
    if(annotation!= mapView.userLocation)
    {
        customPinView = [[MKPinAnnotationView alloc]
                         initWithAnnotation:annotation reuseIdentifier:@"Custom Identifier"];
        customPinView.pinColor = MKPinAnnotationColorRed;
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
        //customPinView.image = custom annotation view image
        
    }
    return customPinView;
}

- (IBAction)toggleDatePicker:(id)sender
{
    
}

#pragma mark - Map view delegate

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    //Open Tinder View
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
