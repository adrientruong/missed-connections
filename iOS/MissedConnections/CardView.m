//
//  CardView.m
//  Flashback
//
//  Created by Sachin Kesiraju on 1/25/15.
//  Copyright (c) 2015 Sachin Kesiraju. All rights reserved.
//

#import "CardView.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface CardView ()

@property (nonatomic, strong) PFUser *user;

@end

@implementation CardView

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
       
    }
    
    return self;
}

- (void) populateCardWithProfile: (PFUser *) profile
{
    self.layer.cornerRadius = 10.0f;
    self.layer.masksToBounds = YES;
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openFacebookProfile)];
    [self.profileImageView addGestureRecognizer:tapGesture];
    
    self.nameLabel.text = [profile objectForKey:@"name"];
    self.openChatButton.titleLabel.text = [NSString stringWithFormat:@"Open chat with %@", [profile objectForKey:@"name"]];
    PFFile *imageFile = [profile objectForKey:@"picture"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         self.profileImageView.image = [UIImage imageWithData:data];
     }];
    
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@",[profile objectForKey:@"fbid"]]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              NSLog(@"REsult %@", result);
                          }];
    
    self.user = profile;

}

- (void) openFacebookProfile
{
    //Open web view with url (facebook.com/sachin.kesiraju)
}

- (IBAction)sendFriendRequest:(id)sender
{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"fb-messenger://user/%@", self.userProfile[@"fbid"]]]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"fb-messenger://user/%@", self.userProfile[@"fbid"]]]];
    }
}

- (IBAction)requestContactInfo:(id)sender
{
    PFObject *contactRequest = [PFObject objectWithClassName:@"ContactRequest"];
    contactRequest[@"fromUser"] = [PFUser currentUser];
    contactRequest[@"toUser"] = self.user;
    contactRequest[@"status"] = @"requested";
    
    [contactRequest saveEventually];
    
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"owner" equalTo:self.user[@"fbid"]];
    
    NSString *message = [NSString stringWithFormat:@"%@ has requested your contact info.", [PFUser currentUser][@"name"]];
    // Send push notification to query
    [PFPush sendPushMessageToQueryInBackground:pushQuery
                                   withMessage:message];
}

@end
