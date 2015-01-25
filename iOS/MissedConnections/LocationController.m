//
//  LocationController.m
//  MissedConnections
//
//  Created by Adrien on 1/24/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import "LocationController.h"
#import "ServerClient.h"
#import <Parse/Parse.h>
#import <AudioToolbox/AudioServices.h>


@implementation LocationController

+ (LocationController *)sharedController
{
    static LocationController *sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[LocationController alloc] init];
    });
    
    return sharedController;
}

- (instancetype)init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = 30;
    _locationManager.pausesLocationUpdatesAutomatically = YES;
    _locationManager.activityType = CLActivityTypeFitness;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        [_locationManager startUpdatingLocation];
    }

    return self;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [_locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSString *facebookUserID = [[PFUser currentUser] objectForKey:@"fbid"];
    
    [[ServerClient sharedClient] postLocationUpdates:locations forFacebookUserID:facebookUserID];
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.fireDate = [NSDate date];
    notif.alertBody = [notif.fireDate description];
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
