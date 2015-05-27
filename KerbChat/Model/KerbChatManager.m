//
//  KerbChatManager.m
//  KerbChat
//
//  Created by Anton Rodick on 23.05.15.
//  Copyright (c) 2015 Anton Rodick. All rights reserved.
//

#import "KerbChatManager.h"
#import "BBAES.h"
#import <CommonCrypto/CommonDigest.h>

const NSString *kLOGIN_URL_STRING = @"https://ancient-fortress-4575.herokuapp.com/as/login";
const NSString *kTGS_URL_STRING = @"https://ancient-fortress-4575.herokuapp.com/tgs";
const NSString *kCHAT_STRING = @"ws://ancient-fortress-4575.herokuapp.com/chat";

@interface KerbChatManager ()

@end

@implementation KerbChatManager

+ (KerbChatManager*)manager {
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


- (NSString*)chatUrlString {
    return [kCHAT_STRING copy];
}

- (NSString*)encryptJsonFromDictionary:(NSDictionary*) json withKey:(NSData*) key{
    if (key == nil) {
        key = [self secretKey];
    }
    NSData *jsonToEncrypt = [NSJSONSerialization dataWithJSONObject:json
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
    NSString *encryptedJson = [BBAES encryptedStringFromData:jsonToEncrypt
                                                          IV:[BBAES randomIV]
                                                         key:key
                                                     options:BBAESEncryptionOptionsIncludeIV];
    return encryptedJson;
}

- (NSData*)decryptJsonFromData:(NSData*) result withKey:(NSData*) key{
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

#pragma mark
#pragma mark Hash

- (NSString*)sha256HashForString:(NSString*)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

- (NSData*)sha256HashForData:(NSData*) data {
    unsigned int outputLength = CC_SHA256_DIGEST_LENGTH;
    unsigned char output[outputLength];
    
    CC_SHA256(data.bytes, (unsigned int) data.length, output);
    return [NSMutableData dataWithBytes:output length:outputLength];
}

- (NSString*)hashForPasswordString:(NSString*)password {
    NSString *halfSizeHash = [[self sha256HashForString:password] substringToIndex:16];
    return halfSizeHash;
}

- (NSData*)hashForPasswordData:(NSData*)password {
    NSData* halfSizeHash = [[self sha256HashForData:password] subdataWithRange:NSMakeRange(0, 16)];
    return halfSizeHash;
}


@end
