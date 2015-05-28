//
//  KerbChatManager.h
//  KerbChat
//
//  Created by Anton Rodick on 23.05.15.
//  Copyright (c) 2015 Anton Rodick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

@interface KerbChatManager : NSObject

@property (nonatomic) BOOL isLoggedIn;
@property (nonatomic, strong) NSData *secretKey;

@property (nonatomic,strong) SRWebSocket *socket;

+ (KerbChatManager*)manager;

- (NSString*)loginUrlString;
- (NSString*)tgsUrlString;
- (NSString*)chatUrlString;

- (NSString*)getCurrentDataString;
- (NSString*)encryptJsonFromDictionary:(NSDictionary*) json withKey:(NSData*) key;
- (NSData*)decryptJsonFromData:(NSData*) result withKey:(NSData*) key;

- (void)initSocketWithUrl:(NSString*) url;
- (void)openSocket;
- (void)closeSocket;
- (void)removeSocket;

- (NSString*)hashForPasswordString:(NSString*)password;
- (NSData*)hashForPasswordData:(NSData*)password;

- (void)clearData;

@end
