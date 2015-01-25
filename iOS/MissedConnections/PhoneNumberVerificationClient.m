//
//  PhoneNumberVerificationClient.m
//  sms-verification
//
//  Created by Adrien on 1/24/15.
//  Copyright (c) 2015 Adrien Truong. All rights reserved.
//

#import "PhoneNumberVerificationClient.h"

#define kBaseURLString @"https://young-shore-4766.herokuapp.com"

@interface PhoneNumberVerificationClient()

@property (nonatomic, assign) BOOL didVerify;
@property (nonatomic, weak) NSTimer *pollTimer;
@property (nonatomic, weak) NSString *identifier;
@property (nonatomic, copy) void (^completionHandler)(NSString *);

@end

@implementation PhoneNumberVerificationClient

+ (instancetype)sharedClient
{
    static PhoneNumberVerificationClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[PhoneNumberVerificationClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseURLString]];
    });
    
    return _sharedClient;
}

- (void)verifyWithIdentifier:(NSString *)identifier completionHandler:(void (^)(NSString *))completionHandler
{
    self.didVerify = NO;
    self.identifier = identifier;
    self.completionHandler = completionHandler;
    self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(verify) userInfo:nil repeats:YES];
}

- (void)verify
{
    if (self.didVerify) {
        return;
    }
    
    NSDictionary *parameters = @{@"vc": self.identifier};
    
    [self GET:@"get" parameters:parameters success:^(NSURLSessionDataTask *task, id response) {
        if (self.didVerify) {
            return;
        }
        
        BOOL verified = [response[@"verified"] boolValue];
        NSString *phoneNumber = response[@"number"];
        
        if (verified) {
            self.didVerify = YES;
            self.completionHandler(phoneNumber);
            
            [self.pollTimer invalidate];
            self.pollTimer = nil;
            
            self.completionHandler = nil;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

@end
