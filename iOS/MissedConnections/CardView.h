//
//  CardView.h
//  Flashback
//
//  Created by Sachin Kesiraju on 1/25/15.
//  Copyright (c) 2015 Sachin Kesiraju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) NSDictionary *userProfile;

- (void) populateCardWithProfile: (NSDictionary *) profileInfo;

@end
