//
//  CardView.h
//  Flashback
//
//  Created by Sachin Kesiraju on 1/25/15.
//  Copyright (c) 2015 Sachin Kesiraju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CardView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *openChatButton;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *professionalDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *interestsLabel;

@property (strong, nonatomic) NSDictionary *userProfile;

- (void) populateCardWithProfile: (PFUser *) profile;
@end
