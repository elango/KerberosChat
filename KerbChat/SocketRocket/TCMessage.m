//
//  TCMessage.m
//  KerbChat
//
//  Created by Anton Rodick on 26.05.15.
//  Copyright (c) 2015 Anton Rodick. All rights reserved.
//

#import "TCMessage.h"

@implementation TCMessage

@synthesize message = _message;
@synthesize fromMe = _fromMe;

- (id)initWithMessage:(NSString *)message fromMe:(BOOL)fromMe;
{
    self = [super init];
    if (self) {
        _fromMe = fromMe;
        _message = message;
    }
    
    return self;
}

@end

