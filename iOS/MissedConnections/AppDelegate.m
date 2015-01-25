//
//  AppDelegate.m
//  MissedConnections
//
//  Created by Adrien on 1/24/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "LocationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse setApplicationId:@"XUpDAVEYCleovR0qxxifa14OEOqymXR0Flw62JJj" clientKey:@"oCQBCxw8TfAL18a7zs0dEI2oHbKaL1U55iImLuS7"];
    [PFFacebookUtils initializeFacebook];

    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [LocationController sharedController];
    
    [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:20], NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"verifiedNumber"];
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to push with error:%@", error);
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Error %@", error);
            }
            else {
                // only update locally if the remote update succeeded so they always match
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
                NSLog(@"updated badge");
            }
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[PFFacebookUtils session] close];
}

@end
