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

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
                      [self performSegueWithIdentifier:@"loggedIn" sender:self];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end