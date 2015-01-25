//
//  ServerClient.h
//  MissedConnections
//
//  Created by Adrien on 1/24/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import "AFHTTPSessionManager.h"
@import CoreLocation;

@interface ServerClient : AFHTTPSessionManager

+ (ServerClient *)sharedClient;

- (void)postLocationUpdate:(CLLocation *)location forFacebookUserID:(NSString *)facebookUserID;
- (void)postLocationUpdates:(NSArray *)locations forFacebookUserID:(NSString *)facebookUserID;

@end
