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

@end
