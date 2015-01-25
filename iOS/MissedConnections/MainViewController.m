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
#import "ContactRequestsViewController.h"

@interface MainViewController () <MKMapViewDelegate>

@property (strong, nonatomic) NSMutableArray *peopleLocationArray;
@property (nonatomic) NSInteger indexTag;
@property (strong, nonatomic) NSArray *selectedPeopleArray;

@property (nonatomic, strong) ContactRequestsViewController *contactRequestsViewController;
@property (nonatomic, strong) NSArray *constraintsToRemove;

- (IBAction)contactsButtonTapped:(id)sender;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Flashback";
    self.mapView.delegate = self;
    self.peopleLocationArray = [[NSMutableArray alloc] init];
    self.selectedPeopleArray = [[NSArray alloc] init];
    self.dateButton.backgroundColor = [UIColor colorWithRed:231.0f/255.0f green:76.0f/255.0f blue:60.0f/255.0f alpha:1.0000];
    self.dateButton.layer.cornerRadius = 6.0f;
    self.dateButton.layer.masksToBounds = YES;
    self.connectButton.layer.cornerRadius = 5.0f;
    self.connectButton.layer.masksToBounds = YES;
    self.exploreButton.layer.cornerRadius = 5.0f;
    self.exploreButton.layer.masksToBounds = YES;
    [self.exploreButton addTarget:self action:@selector(showExploreMap) forControlEvents:UIControlEventAllTouchEvents];
    [self.connectButton addTarget:self action:@selector(showConnectMap) forControlEvents:UIControlEventAllTouchEvents];
}

- (void) showExploreMap
{
    NSMutableArray * annotationsToRemove = [self.mapView.annotations mutableCopy] ;
    [annotationsToRemove removeObject:self.mapView.userLocation];
    [self.mapView removeAnnotations:annotationsToRemove];
    [self getExplorePeopleLocation];
}

- (void) showConnectMap
{
    NSMutableArray * annotationsToRemove = [self.mapView.annotations mutableCopy] ;
    [annotationsToRemove removeObject:self.mapView.userLocation];
    [self.mapView removeAnnotations:annotationsToRemove];
    [self getPeopleLocation];
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

- (void) getExplorePeopleLocation
{
    NSString *url = [NSString stringWithFormat:@"https://fierce-wildwood-9429.herokuapp.com/explore"];
    NSOperationQueue *queue  = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if(!error)
        {
            NSError *jsonError = nil;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if(!jsonError && jsonResponse)
            {
                NSArray *points = jsonResponse[@"points"];
                for(NSDictionary *point in points)
                {
                    NSArray *coords = point[@"loc"][@"coordinates"];
                    CGPoint coordPoint = CGPointMake([coords[0] floatValue], [coords[1] floatValue]);
                    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(coordPoint.x, coordPoint.y);
                    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
                    pointAnnotation.coordinate = coord;
                    [self.mapView addAnnotation:pointAnnotation];
                }
            }
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
    MKAnnotationView *customPinView = nil;
    if(annotation!= mapView.userLocation)
    {
        customPinView = [[MKAnnotationView alloc]
                         initWithAnnotation:annotation reuseIdentifier:@"Custom Identifier"];
        customPinView.tag = self.indexTag;
        [customPinView setSelected:NO animated:YES];
        customPinView.image = [UIImage imageNamed:@"annotation"];
    }
    return customPinView;
}

- (IBAction)toggleDatePicker:(id)sender
{
    
}

- (IBAction)contactsButtonTapped:(id)sender
{
    if (!self.contactRequestsViewController) {
        self.contactRequestsViewController = [[ContactRequestsViewController alloc] initWithStyle:UITableViewStylePlain];
        [self addChildViewController:self.contactRequestsViewController];
        
        UIView *tableView = self.contactRequestsViewController.view;
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(tableView);
        [self.view addSubview:tableView];
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[tableView]|" options:0 metrics:nil views:views]];
        [self.view addConstraint:constraint];
        
        [self.view layoutIfNeeded];
        
        [self.view removeConstraint:constraint];
        
        self.constraintsToRemove = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:views];
        [self.view addConstraints:self.constraintsToRemove];
        
        [UIView animateWithDuration:0.30 animations:^{
            [self.view layoutIfNeeded];
        }];
        
        [self.contactRequestsViewController didMoveToParentViewController:self];
    } else {
        [self.view removeConstraints:self.constraintsToRemove];
        
        UIView *tableView = self.contactRequestsViewController.view;
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        [self.view addConstraint:constraint];
        
        [UIView animateWithDuration:0.30 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.contactRequestsViewController removeFromParentViewController];
            self.contactRequestsViewController = nil;
        }];
    }
}

#pragma mark - Map view delegate

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
   //Show Foursquare Location
    if(view.annotation!=self.mapView.userLocation) {
        NSLog(@"Annotation selected = %li", (long)view.tag);
        NSLog(@"Selected users %@", [self.peopleLocationArray objectAtIndex:view.tag]);
        self.selectedPeopleArray = [NSArray arrayWithArray:[self.peopleLocationArray objectAtIndex:view.tag]];
        SwipeableViewController *swipeableView = [[SwipeableViewController alloc] init];
        swipeableView.profileIDArray = [NSArray arrayWithArray:self.selectedPeopleArray];
        [self presentViewController:swipeableView animated:YES completion:nil];
    }
}

- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
