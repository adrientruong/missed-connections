//
//  ContactRequestTableViewCell.h
//  MissedConnections
//
//  Created by Adrien on 1/25/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactRequestTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIButton *acceptButton;
@property (nonatomic, weak) IBOutlet UIButton *rejectButton;

@end
