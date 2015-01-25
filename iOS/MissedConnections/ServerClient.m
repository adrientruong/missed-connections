//
//  ServerClient.m
//  MissedConnections
//
//  Created by Adrien on 1/24/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import "ServerClient.h"
@import CoreLocation;

#define kBaseURLString @"https://fierce-wildwood-9429.herokuapp.com/"

@implementation ServerClient

+ (ServerClient *)sharedClient
{
    static ServerClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[ServerClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseURLString]];
    });
    
    return sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super initWithBaseURL:url sessionConfiguration:configuration];
    
    if (!self) {
        return nil;
    }
    
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    
    return self;
}

- (void)postLocationUpdate:(CLLocation *)location forFacebookUserID:(NSString *)facebookUserID
{
    NSNumber *latitude = @(location.coordinate.latitude);
    NSNumber *longitude = @(location.coordinate.longitude);
    NSArray *coordinates = @[latitude, longitude];
    NSNumber *timestamp = @([location.timestamp timeIntervalSince1970]);
    
    NSDictionary *parameters = @{@"uid": facebookUserID,
                                 @"coordinates": coordinates,
                                 @"timestamp": timestamp};
    
    [self POST:@"location" parameters:parameters success:^(NSURLSessionDataTask *task, id response) {
    } failure: ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error posting location data:%@", error);
    }];
}

- (void)postLocationUpdates:(NSArray *)locations forFacebookUserID:(NSString *)facebookUserID
{
    for (CLLocation *location in locations) {
        [self postLocationUpdate:location forFacebookUserID:facebookUserID];
    }
}

@end
