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
        self.layer.cornerRadius = 5.0f;
        self.layer.masksToBounds = YES;
        self.layer.shadowRadius = 2.0f;
        self.layer.shadowColor = [UIColor grayColor].CGColor;
    }
    
    return self;
}

- (void) populateCardWithProfile: (NSDictionary *) profileInfo
{
    NSMutableArray *names = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"fbid" equalTo:profileInfo[@"_id"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
        if(!error && objects.count >0)
        {
            [names addObjectsFromArray:objects];
        }
         
         self.user = [objects firstObject];
     }];
    self.nameLabel.text = names[0][@"name"];
    self.profileImageView.image = profileInfo[@"image"];
    self.userProfile = profileInfo;
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
