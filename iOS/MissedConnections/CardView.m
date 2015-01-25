//
//  CardView.m
//  Flashback
//
//  Created by Sachin Kesiraju on 1/25/15.
//  Copyright (c) 2015 Sachin Kesiraju. All rights reserved.
//

#import "CardView.h"
#import <Parse/Parse.h>

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
    
    NSLog(@"Profile %@", profile);
    self.nameLabel.text = [profile objectForKey:@"name"];
    PFFile *imageFile = [profile objectForKey:@"picture"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         self.profileImageView.image = [UIImage imageWithData:data];
     }];
    
    self.openChatButton.titleLabel.text = [NSString stringWithFormat:@"Open chat with %@", [profile objectForKey:@"name"]];
    
    self.user = profile;
}

- (IBAction)sendFriendRequest:(id)sender
{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"fb-messenger://user/%d", [self.userProfile[@"fbid"] intValue]]]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"fb-messenger://user/%d", [self.userProfile[@"fbid"] intValue]]]];
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
