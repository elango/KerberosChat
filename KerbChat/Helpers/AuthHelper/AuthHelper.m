//
//  AuthHelper.m
//  KerbChat
//
//  Created by Anton Rodick on 25.05.15.
//  Copyright (c) 2015 Anton Rodick. All rights reserved.
//

#import "AuthHelper.h"
#import "KerbChatManager.h"

@interface AuthHelper ()

@property (nonatomic,strong) NSString *login;
@property (nonatomic,strong) NSString *password;
@property (nonatomic,strong) NSData *passwordData;
@property (nonatomic) BOOL isOk;
@property (nonatomic,strong) NSData *ticket;

@end

@implementation AuthHelper

+ (AuthHelper*)helper {
    static dispatch_once_t onceToken;
    static AuthHelper *helper = nil;
    dispatch_once(&onceToken, ^{
        helper = [[self alloc] init];
    });
    return helper;
}

- (void)connectToChatWithLogin:(NSString*) login password:(NSString*)password {
    self.passwordData = [[KerbChatManager manager]
                         hashForPasswordData:[password dataUsingEncoding:NSUTF8StringEncoding]];
    [self setPassword:password];
    [self setLogin:login];
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"tgs", @"tgs_name",
                                    [[KerbChatManager manager] getCurrentDataString], @"timestamp",
                                    nil];
    [self authentificateWithJson:jsonDictionary];
    
}

#pragma mark
#pragma mark authentification

- (void)authentificateWithJson:(NSDictionary*) jsonDictionary {
    NSError *error = nil;
    NSData *result = [self encryptedDataFromAuthentificationServerWithJson:jsonDictionary
                                                                     error:&error];
    if (error) {
        [self showAlertWithMessage:@"Error in authentificateWithJson"];
        return;
    }
    NSData *decryptedResult = [[KerbChatManager manager] decryptJsonFromData:result
                                                                         withKey:self.passwordData];
    NSDictionary *responseDictionary = [self dictionaryFromDecryptedData:decryptedResult];
    if (responseDictionary) {
        [self setSecretKeyByString:[responseDictionary valueForKey:@"session_key"]];
        [self authorizateTgsWithTicket:[responseDictionary valueForKey:@"tgs_ticket"]];
    }
}

- (NSData*)encryptedDataFromAuthentificationServerWithJson:(NSDictionary*) jsonToSend
                                                     error:(NSError**) error {
    NSString *encryptedJson = [[KerbChatManager manager] encryptJsonFromDictionary:jsonToSend
                                                                           withKey:self.passwordData];
    NSString* params = [NSString stringWithFormat:@"login=%@&encrypted=%s",
                        self.login, [encryptedJson UTF8String]];
    NSURL* url = [NSURL URLWithString:[[KerbChatManager manager] loginUrlString]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    request.timeoutInterval = 10;
    NSURLResponse *response;
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:&response
                                                       error:error];
    return result;
}

#pragma mark
#pragma mark autorization with TGS

- (void)authorizateTgsWithTicket:(NSString*)ticket {
    NSError *error = nil;
    NSData *result = [self encryptedDataFromTgsWithTicket:ticket
                                                    error:&error];
    if (error) {
        [self showAlertWithMessage:@"Error in authorizateTgsWithTicket"];
        return;
    }
    NSData *decryptedResult = [[KerbChatManager manager]
                               decryptJsonFromData:result
                               withKey:[[KerbChatManager manager] secretKey]];
    NSDictionary *responseDictionary = [self dictionaryFromDecryptedData:decryptedResult];
    if (responseDictionary) {
        [self setSecretKeyByString:[responseDictionary valueForKey:@"client_service_sk"]];
        self.ticket = [responseDictionary valueForKey:@"service_ticket"];
        self.isOk = YES;
        NSLog(@"Done!");
    }
}

- (NSData*)encryptedDataFromTgsWithTicket:(NSString*) ticket error:(NSError**) error{
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.login, @"user_name",
                                    [[KerbChatManager manager] getCurrentDataString], @"timestamp",
                                    nil];
    NSString *authenticator = [[KerbChatManager manager]
                               encryptJsonFromDictionary:jsonDictionary
                               withKey:[[KerbChatManager manager] secretKey]];
    NSString* params = [NSString stringWithFormat:@"authenticator=%@&tgs_ticket=%@&service=%@",
                        authenticator, ticket, @"chat"];
    NSURL* url = [NSURL URLWithString:[[KerbChatManager manager] tgsUrlString]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    request.timeoutInterval = 10;
    NSURLResponse *response;
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:&response
                                                       error:error];
    return result;
}

#pragma mark 
#pragma mark

- (NSDictionary*) dictionaryFromDecryptedData:(NSData*) decryptedResult {
    if (!decryptedResult) {
        [self showAlertWithMessage:@"Error in dictionaryFromDecryptedData"];
        return nil;
    }
    NSError *errorJson = nil;
    NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:decryptedResult
                                                                       options:kNilOptions
                                                                         error:&errorJson];
    NSLog(@"%@",responseDictionary);
    return responseDictionary;
}

- (void) setSecretKeyByString:(NSString*) string {
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
    [[KerbChatManager manager] setSecretKey:decodedData];
}

- (void)showAlertWithMessage:(NSString*) message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
