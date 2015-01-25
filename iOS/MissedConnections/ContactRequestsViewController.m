//
//  ContactRequestsViewController.m
//  MissedConnections
//
//  Created by Adrien on 1/25/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import "ContactRequestsViewController.h"
#import <Parse/Parse.h>
#import "ContactRequestTableViewCell.h"

@interface ContactRequestsViewController ()

@property (nonatomic, strong) NSArray *contactRequests;
@property (nonatomic, strong) NSArray *establishedContacts;

@end

@implementation ContactRequestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"ContactRequestTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"ContactRequestCell"];
    
    self.tableView.rowHeight = 80;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"ContactRequest"];
    [fromUserQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];

    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"ContactRequest"];
    [toUserQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];

    PFQuery *query = [PFQuery orQueryWithSubqueries:@[fromUserQuery, toUserQuery]];
    [query includeKey:@"fromUser"];
    [query includeKey:@"toUser"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error getting contact requests:%@", error);
            return;
        }
        
        NSMutableArray *contactRequests = [NSMutableArray array];
        NSMutableArray *establishedContacts = [NSMutableArray array];
        
        for (PFObject *contactRequest in objects) {
            if ([contactRequest[@"status"] isEqualToString:@"requested"]) {
                [contactRequests addObject:contactRequest];
            } else {
                [establishedContacts addObject:contactRequest];
            }
        }
        
        self.contactRequests = contactRequests;
        self.establishedContacts = establishedContacts;
        
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.contactRequests;
    if (section == 1) {
        array = self.establishedContacts;
    }

    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactRequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactRequestCell" forIndexPath:indexPath];
    
    NSArray *array = self.contactRequests;
    if (indexPath.section == 1) {
        array = self.establishedContacts;
    }
    
    PFObject *contactRequest = array[indexPath.row];
    PFUser *otherUser = contactRequest[@"fromUser"];
    if ([otherUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
        otherUser = contactRequest[@"toUser"];
    }
    cell.nameLabel.text = otherUser[@"name"];
    
    PFFile *imageFile = [otherUser objectForKey:@"picture"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
         cell.profileImageView.image = [UIImage imageWithData:data];
     }];

    
    cell.acceptButton.hidden = [contactRequest[@"status"] isEqualToString:@"accepted"];
    cell.rejectButton.hidden = [contactRequest[@"status"] isEqualToString:@"accepted"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return;
    }
    
    PFObject *contactRequest = self.contactRequests[indexPath.row];
    
    PFUser *otherUser = contactRequest[@"fromUser"];
    if (otherUser.objectId == [PFUser currentUser].objectId) {
        otherUser = contactRequest[@"toUser"];
    }

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Phone Number" message:otherUser[@"phoneNumber"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

- (void)acceptButtonTapped:(UIButton *)button
{
    PFObject *contactRequest = self.contactRequests[button.tag];
    contactRequest[@"status"] = @"accepted";
    [contactRequest saveEventually];
}

@end
