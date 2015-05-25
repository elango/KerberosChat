//
//  KerbChatManager.h
//  KerbChat
//
//  Created by Anton Rodick on 23.05.15.
//  Copyright (c) 2015 Anton Rodick. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KerbChatManager : NSObject

@property (nonatomic) BOOL isLoggedIn;
@property (nonatomic, strong) NSData *secretKey;

+ (KerbChatManager*)manager;

- (NSString*)loginUrlString;
- (NSString*)tgsUrlString;

- (NSString*)getCurrentDataString;
- (NSString*)encryptJsonFromDictionary:(NSDictionary*) json withKey:(NSData*) key;
- (NSData*)decryptJsonFromData:(NSData*) result withKey:(NSData*) key;

- (void)clearData;

@end
