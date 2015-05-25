//
//  KerbChatManager.m
//  KerbChat
//
//  Created by Anton Rodick on 23.05.15.
//  Copyright (c) 2015 Anton Rodick. All rights reserved.
//

#import "KerbChatManager.h"
#import "BBAES.h"

const NSString *kLOGIN_URL_STRING = @"https://ancient-fortress-4575.herokuapp.com/as/login";
const NSString *kTGS_URL_STRING = @"https://ancient-fortress-4575.herokuapp.com/tgs";

@interface KerbChatManager ()

@end

@implementation KerbChatManager

+ (KerbChatManager*)sharedKerbChatManager {
    static dispatch_once_t onceToken;
    static KerbChatManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)clearData {
    
}

- (NSString*)loginUrlString {
    return [kLOGIN_URL_STRING copy];
}

- (NSString*)tgsUrlString {
    return [kTGS_URL_STRING copy];
}

- (NSString*)encryptJsonFromDictionary:(NSDictionary*) json WithKey:(NSData*) key{
    NSData *jsonToEncrypt = [NSJSONSerialization dataWithJSONObject:json
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
    NSString *encryptedJson = [BBAES encryptedStringFromData:jsonToEncrypt
                                                          IV:[BBAES randomIV]
                                                         key:key
                                                     options:BBAESEncryptionOptionsIncludeIV];
    return encryptedJson;
}

- (NSData*)decryptJsonFromData:(NSData*) result WithKey:(NSData*) key{
    NSString *str = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    NSLog(@"responce string : %@",str);
    NSData *encodeData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *resultBase64Decoded = [[NSData alloc] initWithBase64EncodedData:encodeData
                                                                    options:0];
    NSData *decryptedResult = [BBAES decryptedDataFromData:resultBase64Decoded
                                                        IV:nil
                                                       key:key];
    return decryptedResult;
}

- (NSString*) getCurrentDataString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
    return stringFromDate;
}

@end
