//
//  ChatHelper.h
//  KerbChat
//
//  Created by Anton Rodick on 26.05.15.
//  Copyright (c) 2015 Anton Rodick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatHelper : NSObject

+ (ChatHelper*)helper;

- (NSDictionary*)jsonForFirstSocketConnectionWithLogin:(NSString*) login
                                              password:(NSString*)password;

- (NSString*)jsonForMessageRequestFromUser:(NSString*) user
                               withMessage:(NSString*) message
                                   andRoom:(NSString*) room;

-(NSDictionary*)decryptedJsonFromServer:(NSString*) message;

- (NSString*) jsonForGoRoomWithName:(NSString*) name;

- (NSString*) jsonForNewRoomWithUsers:(NSMutableArray*) users
                            threshold:(NSString*) threshold
                              andName:(NSString*) name;

- (NSString*)jsonForSecretWithRoom:(NSString*) room;

- (void)showAlertToCloseRoom;

@end
