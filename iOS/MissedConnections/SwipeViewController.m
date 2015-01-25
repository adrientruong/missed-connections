//
//  SwipeViewController.m
//  HackGenyY
//
//  Created by Sachin Kesiraju on 1/25/15.
//  Copyright (c) 2015 Sachin Kesiraju. All rights reserved.
//

#import "SwipeViewController.h"
#import "ZLSwipeableView.h"
#import "CardView.h"
#import <Parse/Parse.h>

@interface SwipeViewController () <ZLSwipeableViewDataSource, ZLSwipeableViewDelegate>

@property (strong, nonatomic) ZLSwipeableView *swipeableView;
@property (nonatomic) NSInteger currentProfileIndex;
@property (strong, nonatomic) NSArray *peopleProfileArray;

@end

@implementation SwipeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.swipeableView = [[ZLSwipeableView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.swipeableView];
    self.currentProfileIndex = 0;
    [self.swipeableView setNeedsLayout];
    [self.swipeableView layoutIfNeeded];
    self.swipeableView.delegate = self;
    self.swipeableView.dataSource = self;
    PFQuery *query = [PFUser query];
    [query whereKey:@"fbid" containedIn:self.peopleArray];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
       if(!error && objects)
       {
           self.peopleProfileArray = [[NSArray alloc] initWithArray:objects];
       }
    }];
    [self.swipeableView discardAllSwipeableViews];
    [self.swipeableView loadNextSwipeableViewsIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Swipeable view delegate

- (void)swipeableView: (ZLSwipeableView *)swipeableView didSwipeLeft:(UIView *)view {
    NSLog(@"did swipe left");
}
- (void)swipeableView: (ZLSwipeableView *)swipeableView didSwipeRight:(UIView *)view {
    NSLog(@"did swipe right");
}
- (void)swipeableView:(ZLSwipeableView *)swipeableView didStartSwipingView:(UIView *)view atLocation:(CGPoint)location {
    NSLog(@"did start swiping at location: x %f, y%f", location.x, location.y);
}
- (void)swipeableView: (ZLSwipeableView *)swipeableView swipingView:(UIView *)view atLocation:(CGPoint)location {
    NSLog(@"swiping at location: x %f, y%f", location.x, location.y);
}
- (void)swipeableView:(ZLSwipeableView *)swipeableView didEndSwipingView:(UIView *)view atLocation:(CGPoint)location {
    NSLog(@"did start swiping at location: x %f, y%f", location.x, location.y);
}

#pragma mark - ZLSwipeableView datasource

- (UIView *) nextViewForSwipeableView:(ZLSwipeableView *)swipeableView
{
    if(self.currentProfileIndex < self.peopleArray.count)
    {
        CardView *cardView = [[CardView alloc] initWithFrame:self.view.frame];
        [cardView populateCardWithProfile:[self.peopleProfileArray objectAtIndex:self.currentProfileIndex]];
        self.currentProfileIndex ++;
        return cardView;
    }
    else
    {
        return nil;
    }
}

@end
