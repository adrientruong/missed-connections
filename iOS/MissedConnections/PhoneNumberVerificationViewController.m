//
//  PhoneNumberVerificationViewController.m
//  sms-verification
//
//  Created by Adrien on 1/24/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import "PhoneNumberVerificationViewController.h"
#import <MessageUI/MessageUI.h>
#import "PhoneNumberVerificationClient.h"
#import "LocationPermissionViewController.h"

@interface PhoneNumberVerificationViewController () <MFMessageComposeViewControllerDelegate>

- (IBAction)verifyButtonWasTapped;

@property (nonatomic, strong) NSString *verificationCode;

@end

@implementation PhoneNumberVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)verifyButtonWasTapped
{
    self.verificationCode = [[[NSUUID UUID] UUIDString] substringToIndex:8];
    
    MFMessageComposeViewController *messageComposeController = [[MFMessageComposeViewController alloc] init];
    messageComposeController.recipients = @[kPhoneNumberToSendTo];
    messageComposeController.body = [NSString stringWithFormat: @"Tap send to verify your phone number.\n\nCode:%@", self.verificationCode];
    messageComposeController.messageComposeDelegate = self;
    
    [self presentViewController:messageComposeController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent) {
        PhoneNumberVerificationClient *client = [PhoneNumberVerificationClient sharedClient];
        [client verifyWithIdentifier:self.verificationCode completionHandler:^(NSString *phoneNumber) {
            if ([phoneNumber length] > 0) {
                [self performSegueWithIdentifier:@"showLocationPermission" sender:self];
            } else {
                NSLog(@"DARN!");
            }
        }];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
