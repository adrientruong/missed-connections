//
//  LoginViewController.m
//  MissedConnections
//
//  Created by Sachin Kesiraju on 1/25/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Parse/Parse.h>

@import CoreLocation;

@interface LoginViewController ()

@property (nonatomic, weak) IBOutlet UIButton *signInButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.signInButton.backgroundColor = [UIColor colorWithRed:6.0f/255.0f green:150.0f/255.0f blue:222.0f/255.0f alpha:1.0];
    self.signInButton.layer.shadowOffset = CGSizeMake(0, 3);
    self.signInButton.layer.shadowOpacity = 1.0;
    self.signInButton.layer.shadowRadius = 0;
    self.signInButton.layer.shadowColor = [[UIColor colorWithRed:0.0f/255.0f green:126.0f/255.0f blue:188.0f/255.0f alpha:1.0] CGColor];
    [self.signInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // Do any additional setup after loading the view.
}

- (IBAction)login:(id)sender
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"public_profile", @"user_friends", nil];
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error)
     {
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         if(!error)
         {
             NSDictionary *userData = (NSDictionary *)result;
             
             NSString *facebookID = userData[@"id"];
             
             NSURLResponse *response = nil;
             NSError *error = nil;
             
             NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
             NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:pictureURL] returningResponse:&response error:&error];
             PFFile *file = [PFFile fileWithName:@"ProfPic" data:data];
             [[PFUser currentUser] setObject:file forKey:@"picture"];
             
             NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:6];
             
             if (facebookID) {
                 userProfile[@"fbId"] = facebookID;
             }
             
             if (userData[@"name"]) {
                 userProfile[@"name"] = userData[@"name"];
             }
             
             [[PFUser currentUser] setObject:[result objectForKey:@"name"] forKey:@"name"];
             [[PFUser currentUser] setObject:userData[@"id"] forKey:@"fbid"];
             NSLog(@"Saved user facebook id %@", userData[@"id"]);
             
             [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded,NSError *error)
              {
                  if(succeeded)
                  {
                      NSLog(@"Save was a success");
                      PFInstallation *installation = [PFInstallation currentInstallation];
                      [installation setObject:[[PFUser currentUser] objectForKey:@"fbid"] forKey:@"owner"];
                      [installation saveInBackground];
                      //[self importFriends];
                      if([[NSUserDefaults standardUserDefaults] boolForKey:@"verifiedNumber"])
                      {
                          if([self authorizationStatus])
                          {
                              [self performSegueWithIdentifier:@"showMain" sender:self];
                          }
                          else
                          {
                              [self performSegueWithIdentifier:@"showLocation" sender:self];
                          }
                          
                      }
                      else {
                      [self performSegueWithIdentifier:@"loggedIn" sender:self];
                      }
                  }
                  else if(error)
                  {
                      NSLog(@"Error %@",error);
                  }
              }];
         }
         else
         {
             NSLog(@"Error %@", error);
         }
     }];
     }];
}

- (BOOL) authorizationStatus
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch(status)
    {
        case kCLAuthorizationStatusAuthorizedAlways: return YES;
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse: return YES;
            break;
        case kCLAuthorizationStatusDenied: return NO;
            break;
        case kCLAuthorizationStatusNotDetermined: return NO;
            break;
        case kCLAuthorizationStatusRestricted: return NO;
            break;
    }
}

/*
- (void) importFriends
{
    [FBRequestConnection startWithGraphPath:@"/me/friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              NSArray *friends = (NSArray *) result; //Array of facebook friends
                              NSLog(@"Friends %@", friends);
                              for(NSDictionary *friend in friends)
                              {
                                  NSLog(@"Friend %@", friend);
                                  PFUser *user = [PFUser user];
                                  [user setObject:friend[@"objectID"] forKey:@"fbid"];
                                  NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", friend[@"objectID"]]];
                                  NSURLResponse *response = nil;
                                  NSError *error = nil;
                                  NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:pictureURL] returningResponse:&response error:&error];
                                  PFFile *file = [PFFile fileWithName:@"ProfPic" data:data];
                                  [user setObject:file forKey:@"picture"];
                                  [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                   {
                                       
                                   }];
                              }
                              
                              }];
}
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
