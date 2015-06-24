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
                                    login, @"user_name",
                                    [[KerbChatManager manager] getCurrentDataString], @"timestamp",
                                    nil];
    return [self jsonToChatWithDictionary:jsonDictionary];
}

- (NSDictionary*)jsonToChatWithDictionary:(NSDictionary*) jsonDictionary {
    NSString *encryptedJson = [[KerbChatManager manager] encryptJsonFromDictionary:jsonDictionary
                                                                           withKey:[[KerbChatManager manager] secretKey]];
    NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"login", @"type",
                                    encryptedJson, @"authenticator",
                                    @"chat", @"service",
                                    [[AuthHelper helper] ticket], @"service_ticket",
                                    nil];
    return json;
    
}

- (NSString*)jsonForMessageRequestFromUser:(NSString*) user
                                           withMessage:(NSString*) message andRoom:(NSString*) room {
    NSDictionary *messageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       user, @"from",
                                       [[KerbChatManager manager] getCurrentDataString], @"time",
                                       message,  @"text",
                                       room, @"room",
                                  nil];
    NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"new_message", @"type",
                                    user, @"from",
                                    [[KerbChatManager manager] getCurrentDataString], @"timestamp",
                                    messageDictionary, @"message",
                                    room, @"room",
                                    nil];
    return [self jsonForMessageWithDictionary:json];
}

- (NSString*) jsonForGoRoomWithName:(NSString*) name {
    NSDictionary *room = [[[KerbChatManager manager] rooms] valueForKey:name];
    NSString *roomName = [room valueForKey:@"name"];
    NSString *secret = [[KerbChatManager manager] getSecretForRoom:roomName];
    NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:
                          secret, @"secret",
                          @"go_room", @"type",
                          [[AuthHelper helper] login], @"from",
                          [[KerbChatManager manager] getCurrentDataString], @"timestamp",
                          roomName, @"room",
                          nil];
    NSString *encryptedJson = [self jsonForMessageWithDictionary:json];
    return encryptedJson;
}

- (NSString*) jsonForNewRoomWithUsers:(NSMutableArray*) users
                            threshold:(NSString*)threshold
                              andName:(NSString*) name {
    NSString *login = [[AuthHelper helper] login];
    NSString *time = [[KerbChatManager manager] getCurrentDataString];
    NSString *thresholdValue = threshold;
    if ([thresholdValue isEqualToString:@""]) {
        thresholdValue = [NSString stringWithFormat:@"%ld",[users count]];
    }
    NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"new_room", @"type",
                          name, @"room",
                          login, @"from",
                          time, @"timestamp",
                          users, @"users",
                          threshold, @"threshold",
                          nil];
    NSString *encryptedJson = [self jsonForMessageWithDictionary:json];
    return encryptedJson;
}


- (NSString*)jsonForSecretWithRoom:(NSString*) room {
    NSString *time = [[KerbChatManager manager] getCurrentDataString];
    NSString *secret = [[KerbChatManager manager] getSecretForRoom:room];
    NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"secret", @"type",
                          room, @"room",
                          secret, @"secret",
                          time, @"timestamp",
                          [[AuthHelper helper] login], @"from",
                          nil];
    NSString *encryptedJson = [self jsonForMessageWithDictionary:json];
    return encryptedJson;

}

- (NSString*)jsonForMessageWithDictionary:(NSDictionary*) jsonDictionary {
    NSString *encryptedJson = [[KerbChatManager manager] encryptJsonFromDictionary:jsonDictionary
                                                                           withKey:[[KerbChatManager manager] secretKey]];
    return encryptedJson;
    
}

- (NSDictionary*)decryptedJsonFromServer:(NSString*) message {
    NSData *jsonData = [[KerbChatManager manager] decryptJsonFromData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                           withKey:[[KerbChatManager manager] secretKey]];
    NSError *errorJson = nil;
    NSDictionary* jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                       options:kNilOptions
                                                                         error:&errorJson];
    return jsonDictionary;
}

- (void)showAlertToCloseRoom {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Комната закрыта"
                                                    message:@"Это связано с тем, что кто-то из участников не в сети."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

@end

