//
//  MainViewController.m
//  MissedConnections
//
//  Created by Sachin Kesiraju on 1/25/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import "MainViewController.h"
#import "SwipeableViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"

@interface MainViewController () <MKMapViewDelegate>

@property (strong, nonatomic) NSMutableArray *peopleLocationArray;
@property (nonatomic) NSInteger indexTag;
@property (strong, nonatomic) NSArray *selectedPeopleArray;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.peopleLocationArray = [[NSMutableArray alloc] init];
    self.selectedPeopleArray = [[NSArray alloc] init];
}

- (void) viewDidAppear:(BOOL)animated
{
    self.selectedPeopleArray = [[NSArray alloc] init];
    if(![PFUser currentUser])
    {
        NSLog(@"No user");
        [self performSegueWithIdentifier:@"showIntro" sender:self];
    }
    else
    {
        NSLog(@"User does exist");
        [self getPeopleLocation];
    }
}

- (void) getPeopleLocation
{
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
                 for(int i=0; i<annotationLocation.count; i++)
                 {
                     NSDictionary *annotation = annotationLocation[i];
                     CGPoint point = CGPointMake([annotation[@"coordinates"][@"x"] floatValue], [annotation[@"coordinates"][@"y"] floatValue]);
                     NSLog(@"coordinate point %f %f", point.x, point.y);
                     self.indexTag = i;
                     [self.peopleLocationArray addObject:annotation[@"users"]];
                     CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(point.x, point.y);
                     [self getLocationNameForCoordinates:coord];
                     MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
                     pointAnnotation.coordinate = coord;
                     [self.mapView addAnnotation:pointAnnotation];
                 }
             }
         }
         else
         {
             NSLog(@"Error %@", error);
         }
     }];
}

- (void) getLocationNameForCoordinates: (CLLocationCoordinate2D) coord
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%f,%f&oauth_token=CL4IQQRNBM1TA2PQ5ZQEECWXVPQNXHRFON1IVSAGA3XEQWZB&v=20150125",coord.latitude, coord.longitude]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
       if(!error)
       {
           NSError *error = nil;
           NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
           NSString *name = response[@"response"][@"venues"][0][@"name"];
           NSLog(@"Name %@", name);
       }
    }];
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
        customPinView.tag = self.indexTag;
        [customPinView setSelected:NO animated:YES];
        customPinView.image = [UIImage imageNamed:@"annotation"];
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
    if(view.annotation!=self.mapView.userLocation) {
    NSLog(@"Annotation selected = %li", (long)view.tag);
    NSLog(@"Selected users %@", [self.peopleLocationArray objectAtIndex:view.tag]);
    self.selectedPeopleArray = [NSArray arrayWithArray:[self.peopleLocationArray objectAtIndex:view.tag]];
    SwipeableViewController *swipeableView = [[SwipeableViewController alloc] init];
    swipeableView.profileIDArray = [NSArray arrayWithArray:self.selectedPeopleArray];
    [self presentViewController:swipeableView animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
