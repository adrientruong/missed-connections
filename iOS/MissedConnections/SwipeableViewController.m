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
    self.swipeableView = [[ZLSwipeableView alloc] initWithFrame:self.view.frame];
    [self.swipeableView setNeedsLayout];
    [self.swipeableView layoutIfNeeded];
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
         }
         else
         {
             NSLog(@"Error %@", error);
         }
     }];
    [self.swipeableView discardAllSwipeableViews];
    [self.swipeableView loadNextSwipeableViewsIfNeeded];
}

#pragma mark - Swipeable view datasource

- (UIView *) nextViewForSwipeableView:(ZLSwipeableView *)swipeableView
{
    if(self.currentProfileIndex < self.userDetailsArray.count)
    {
        CardView *cardView = [[NSBundle mainBundle] loadNibNamed:@"CardView" owner:self options:nil][0];
        [cardView setUserProfile:[self.userDetailsArray objectAtIndex:self.currentProfileIndex]];
        self.currentProfileIndex ++;
        return cardView;
    }
    else
    {
        return nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
