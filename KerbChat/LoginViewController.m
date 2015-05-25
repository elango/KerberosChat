//
//  LoginViewController.m
//  KerbChat
//
//  Created by Anton Rodick on 23.05.15.
//  Copyright (c) 2015 Anton Rodick. All rights reserved.
//

#import "LoginViewController.h"
#import "MainScreenViewController.h"
#import "KerbChatManager.h"
#import "NSData+AES.h"
#import "BBAES.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self successfulLogin];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.loginTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"tgs", @"tgs_name",
                               @"2015-05-23 09:44:44", @"timestamp",
                               nil];
    [self authentificationWithJson:jsonDictionary];
}

- (void)successfulLogin {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainScreenViewController *viewController = (MainScreenViewController *)[storyboard instantiateViewControllerWithIdentifier:@"main"];
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark Cryptography

- (void)authentificationWithJson:(NSDictionary*) jsonDictionary {
    NSError *error = nil;
    NSData *result = [self dataFromAuthentificationWithJSON:jsonDictionary Error:&error];
    if (error) {
        [self showAlert];
    } else {
        NSError *errorJson = nil;
        NSData *decryptedResult = [[KerbChatManager sharedKerbChatManager] decryptJsonFromData:result WithKey:[self.passwordTextField.text dataUsingEncoding:NSUTF8StringEncoding]];
        if (!decryptedResult) {
            [self showAlert];
        } else {
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:decryptedResult
                                                                         options:kNilOptions
                                                                           error:&errorJson];
            NSString *secretKeyString = [responseDict valueForKey:@"session_key"];
            [self setSecretKeyByString:secretKeyString];
            NSLog(@"%@", responseDict);
            [self authorizationTGSWithTicket:[responseDict valueForKey:@"tgs_ticket"]];
            [self successfulLogin];
        }
    }
}

- (NSData*)dataFromAuthentificationWithJSON:(NSDictionary*) jsonToSend Error:(NSError**) error{
    NSString *encryptedJson = [[KerbChatManager sharedKerbChatManager] encryptJsonFromDictionary:jsonToSend WithKey:[self.passwordTextField.text dataUsingEncoding:NSUTF8StringEncoding]];
    //    NSLog(@"encJson: %s",[encryptedJson UTF8String]);
    NSString* params = [NSString stringWithFormat:@"login=%@&encrypted=%s", self.loginTextField.text, [encryptedJson UTF8String]];
    NSURL* url = [NSURL URLWithString:[[KerbChatManager sharedKerbChatManager] loginUrlString]];
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

- (void)authorizationTGSWithTicket:(NSString*)ticket {
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                               self.loginTextField.text, @"user_name",
                               @"2015-05-26 09:44:44", @"timestamp",
                               nil];
    NSString *authenticator = [[KerbChatManager sharedKerbChatManager] encryptJsonFromDictionary:jsonDictionary WithKey:[[KerbChatManager sharedKerbChatManager] secretKey]];
    NSString* params = [NSString stringWithFormat:@"authenticator=%@&tgs_ticket=%@&service=%@",authenticator, ticket, @"chat"];
    NSURL* url = [NSURL URLWithString:[[KerbChatManager sharedKerbChatManager] tgsUrlString]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    request.timeoutInterval = 10;
    NSURLResponse *response;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:&response
                                                       error:&error];
    if (error) {
        [self showAlert];
    } else {
        NSError *errorJson = nil;
        NSData *decryptedResult = [[KerbChatManager sharedKerbChatManager] decryptJsonFromData:result WithKey:[[KerbChatManager sharedKerbChatManager] secretKey]];
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:decryptedResult
                                                                     options:kNilOptions
                                                                       error:&errorJson];
        NSLog(@"%@",responseDict);
    }

}

- (void) setSecretKeyByString:(NSString*) string {
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
    [[KerbChatManager sharedKerbChatManager] setSecretKey:decodedData];
}

- (void)showAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Something wrong!"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
