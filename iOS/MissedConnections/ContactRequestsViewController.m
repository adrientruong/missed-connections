//
//  ContactRequestsViewController.m
//  MissedConnections
//
//  Created by Adrien on 1/25/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import "ContactRequestsViewController.h"
#import <Parse/Parse.h>

@interface ContactRequestsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *contactRequests;

@end

@implementation ContactRequestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PFQuery *query = [PFQuery queryWithClassName:@"ContactRequest"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"Error getting contact requests:%@", error);
            return;
        }
        
        self.contactRequests = objects;
        
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contactRequests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UIButton *acceptButton = (UIButton *)cell.accessoryView;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        
        UIButton *accept = [UIButton buttonWithType:UIButtonTypeCustom];
        accept.tag = indexPath.row;
        cell.accessoryView = accept;
    }
    
    PFObject *contactRequest = self.contactRequests[indexPath.row];
    PFUser *fromUser = contactRequest[@"fromUser"];
    cell.textLabel.text = fromUser[@"name"];
    
    acceptButton.hidden = [contactRequest[@"status"] isEqualToString:@"accepted"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *contactRequest = self.contactRequests[indexPath.row];
    
    if ([contactRequest[@"status"] isEqualToString:@"accepted"]) {
        PFUser *fromUser = contactRequest[@"fromUser"];

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Phone Number" message:fromUser[@"phoneNumber"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)acceptButtonTapped:(UIButton *)button
{
    PFObject *contactRequest = self.contactRequests[button.tag];
    contactRequest[@"status"] = @"accepted";
    [contactRequest saveEventually];
    
}

@end
