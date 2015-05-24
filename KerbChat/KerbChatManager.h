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

+(KerbChatManager*) sharedKerbChatManager;
-(void) clearData;
-(NSString*) loginUrlString;

@end
