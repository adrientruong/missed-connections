//
//  PhoneNumberVerificationClient.h
//  sms-verification
//
//  Created by Adrien on 1/24/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>

#define kPhoneNumberToSendTo @"14088504337"

@interface PhoneNumberVerificationClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (void)verifyWithIdentifier:(NSString *)identifier completionHandler:(void (^)(NSString *phoneNumber))completionHandler;

@end
