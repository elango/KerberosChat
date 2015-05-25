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

+ (KerbChatManager*)sharedKerbChatManager;

- (NSString*)loginUrlString;
- (NSString*)tgsUrlString;

- (NSString*)getCurrentDataString;
- (NSString*)encryptJsonFromDictionary:(NSDictionary*) json WithKey:(NSData*) key;
- (NSData*)decryptJsonFromData:(NSData*) result WithKey:(NSData*) key;

- (void)clearData;

@end
