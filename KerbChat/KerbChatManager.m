//
//  KerbChatManager.m
//  KerbChat
//
//  Created by Anton Rodick on 23.05.15.
//  Copyright (c) 2015 Anton Rodick. All rights reserved.
//

#import "KerbChatManager.h"

const NSString *kLOGIN_URL_STRING = @"https://ancient-fortress-4575.herokuapp.com/as/login/";

@interface KerbChatManager ()

@end

@implementation KerbChatManager

+(KerbChatManager*) sharedKerbChatManager {
    static dispatch_once_t onceToken;
    static KerbChatManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

-(void) clearData {
    
}

-(NSString*) loginUrlString {
    return [kLOGIN_URL_STRING copy];
}

@end
