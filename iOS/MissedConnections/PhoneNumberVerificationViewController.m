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
#import <Parse/Parse.h>

@interface PhoneNumberVerificationViewController () <MFMessageComposeViewControllerDelegate>

- (IBAction)verifyButtonWasTapped;

@property (nonatomic, strong) NSString *verificationCode;
@property (nonatomic, weak) IBOutlet UILabel *stepTwolabel;
@property (nonatomic, weak) IBOutlet UIButton *verifyButton;

@end

@implementation PhoneNumberVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.stepTwolabel.layer.borderColor = [self.stepTwolabel.textColor CGColor];
    self.stepTwolabel.layer.borderWidth = 5.0;
    self.stepTwolabel.layer.cornerRadius = self.stepTwolabel.frame.size.height / 2;
    
    self.verifyButton.backgroundColor = self.stepTwolabel.textColor;
    self.verifyButton.layer.shadowOffset = CGSizeMake(0, 3);
    self.verifyButton.layer.shadowOpacity = 1.0;
    self.verifyButton.layer.shadowRadius = 0;
    self.verifyButton.layer.shadowColor = [[UIColor colorWithRed:0.0f/255.0f green:167.0f/255.0f blue:135.0f/255.0f alpha:1.0] CGColor];
    [self.verifyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];    // Do any additional setup after loading the view from its nib.
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
                PFUser *user = [PFUser currentUser];
                [user setObject:phoneNumber forKey:@"phoneNumber"];
                [user saveEventually];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"verifiedNumber"];
                [self performSegueWithIdentifier:@"showLocationPermission" sender:self];
            } else {
                NSLog(@"DARN!");
            }
        }];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
