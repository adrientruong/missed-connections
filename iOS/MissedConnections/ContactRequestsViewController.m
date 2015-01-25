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
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"Header"];
    
    self.tableView.rowHeight = 80;
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.85];

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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
    
    if (section == 0) {
        headerView.textLabel.text = @"REQUESTS TO CONNECT";
    } else {
        headerView.textLabel.text = @"CONNECTIONS";
    }
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    
    headerView.contentView.backgroundColor = [UIColor grayColor];
    headerView.textLabel.textColor = [UIColor whiteColor];
    headerView.textLabel.font = [UIFont systemFontOfSize:12];
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
    
    cell.acceptButton.tag = indexPath.row;
    cell.acceptButton.tag = indexPath.row;
    
    if ([[cell.acceptButton allTargets] count] == 0) {
        [cell.acceptButton addTarget:self action:@selector(acceptButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell.rejectButton addTarget:self action:@selector(rejectButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = self.contactRequests;
    if (indexPath.section == 1) {
        array = self.establishedContacts;
    }
    PFObject *contactRequest = array[indexPath.row];

    if ([contactRequest[@"status"] isEqualToString:@"accepted"]) {
        PFUser *otherUser = contactRequest[@"fromUser"];
        if ([otherUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
            otherUser = contactRequest[@"toUser"];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Phone Number" message:otherUser[@"phoneNumber"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)acceptButtonTapped:(UIButton *)button
{
    PFObject *contactRequest = self.contactRequests[button.tag];
    contactRequest[@"status"] = @"accepted";
    [contactRequest saveEventually];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)rejectButtonTapped:(UIButton *)button
{
    PFObject *contactRequest = self.contactRequests[button.tag];
    contactRequest[@"status"] = @"rejected";
    [contactRequest saveEventually];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
