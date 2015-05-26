//
//  ChatHelper.m
//  KerbChat
//
//  Created by Anton Rodick on 26.05.15.
//  Copyright (c) 2015 Anton Rodick. All rights reserved.
//

#import "ChatHelper.h"
#import "AuthHelper.h"
#import "KerbChatManager.h"

@interface ChatHelper ()

@property (nonatomic,strong) NSData *passwordData;

@end

@implementation ChatHelper

+ (ChatHelper*)helper {
    static dispatch_once_t onceToken;
    static ChatHelper *helper = nil;
    dispatch_once(&onceToken, ^{
        helper = [[self alloc] init];
    });
    return helper;
}

- (NSDictionary*)jsonForFirstSocketConnectionWithLogin:(NSString*) login
                                                  password:(NSString*)password {
    self.passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"tgs", @"tgs_name",
                                    @"2015-05-23 09:44:44", @"timestamp",
                                    nil];
    return [self jsonToChatWithDictionary:jsonDictionary];
}

- (NSDictionary*)jsonToChatWithDictionary:(NSDictionary*) jsonDictionary {
    NSString *encryptedJson = [[KerbChatManager manager] encryptJsonFromDictionary:jsonDictionary
                                                                           withKey:self.passwordData];
    NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"login", @"type",
                                    encryptedJson, @"authenticator",
                                    @"chat", @"service",
                                    [[AuthHelper helper] ticket], @"service_ticket",
                                    nil];
    return json;
    
}

@end
