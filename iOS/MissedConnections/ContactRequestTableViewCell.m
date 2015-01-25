//
//  ContactRequestTableViewCell.m
//  MissedConnections
//
//  Created by Adrien on 1/25/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import "ContactRequestTableViewCell.h"

@implementation ContactRequestTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2;
    self.profileImageView.layer.masksToBounds = YES;
}

@end
