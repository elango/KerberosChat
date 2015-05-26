//
//  AuthHelper.h
//  KerbChat
//
//  Created by Anton Rodick on 25.05.15.
//  Copyright (c) 2015 Anton Rodick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AuthHelper : NSObject

@property (nonatomic,readonly) BOOL isOk;
@property (nonatomic,readonly) NSString* login;
@property (nonatomic,readonly) NSString* password;
@property (nonatomic,readonly) NSData* ticket;

+ (AuthHelper*)helper;
- (void)connectToChatWithLogin:(NSString*) login password:(NSString*)password;

@end
