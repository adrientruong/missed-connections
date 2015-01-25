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
    self.currentProfileIndex = 0;
    self.userDetailsArray = [[NSMutableArray alloc] init];
    for(int i=0; i<self.profileIDArray.count; i++)
    {
        PFQuery *query  = [PFQuery queryWithClassName:@"User"];
        [query whereKey:@"fbid" equalTo:[self.profileIDArray objectAtIndex:i]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
            if(!error && objects)
            {
                NSLog(@"Object %@", objects[0]);
                [self.userDetailsArray addObject:objects[0]];
            }
             else
             {
                 NSLog(@"Error %@", error);
             }
         }];
    }
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
