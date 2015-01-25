//
//  SwipeableViewController.m
//  MissedConnections
//
//  Created by Sachin Kesiraju on 1/25/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import "SwipeableViewController.h"
#import <Parse/Parse.h>
#import "ZLSwipeableView.h"
#import "CardView.h"

@interface SwipeableViewController () <ZLSwipeableViewDataSource, ZLSwipeableViewDelegate>

@property (strong,nonatomic) NSMutableArray *userDetailsArray;
@property (strong, nonatomic) ZLSwipeableView *swipeableView;
@property (nonatomic) NSInteger currentProfileIndex;

@end

@implementation SwipeableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"Id's received %@", self.profileIDArray);
    self.view.backgroundColor = [UIColor grayColor];
    self.swipeableView = [[ZLSwipeableView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.swipeableView];
    self.swipeableView.dataSource = self;
    self.swipeableView.delegate = self;
    self.currentProfileIndex = 0;
    self.userDetailsArray = [[NSMutableArray alloc] init];
    PFQuery *query  = [PFUser query];
    [query whereKey:@"fbid" containedIn:self.profileIDArray];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if(!error && objects)
         {
             NSLog(@"Object %@", objects);
             [self.userDetailsArray addObjectsFromArray:objects];
             [self.swipeableView discardAllSwipeableViews];
             [self.swipeableView loadNextSwipeableViewsIfNeeded];
         }
         else
         {
             NSLog(@"Error %@", error);
         }
     }];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeView)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeGesture];
}

- (void) closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Swipeable view datasource

- (void) swipeableView:(ZLSwipeableView *)swipeableView didSwipeLeft:(UIView *)view
{
    NSLog(@"Swiped left");
}

- (void) swipeableView:(ZLSwipeableView *)swipeableView didSwipeRight:(UIView *)view
{
    NSLog(@"Swiped right");
}

- (UIView *) nextViewForSwipeableView:(ZLSwipeableView *)swipeableView
{
    NSLog(@"Calling tinder method %li %lu", (long)self.currentProfileIndex, (unsigned long)self.userDetailsArray.count);
    if(self.currentProfileIndex < self.userDetailsArray.count)
    {
        CardView *cardView = [[NSBundle mainBundle] loadNibNamed:@"CardView" owner:self options:nil][0];
        [cardView populateCardWithProfile:[self.userDetailsArray objectAtIndex:self.currentProfileIndex]];
        self.currentProfileIndex ++;
        return cardView;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
