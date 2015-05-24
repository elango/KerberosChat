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

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.loginTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)login:(id)sender {
    NSDictionary *jsonArray = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"tgs", @"tgs_name",
                               @"2015-05-23 09:44:44", @"timestamp",
                               nil];
    NSData *jsonToSend = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"json to send: %@", [[NSString alloc] initWithData:jsonToSend encoding:NSUTF8StringEncoding]);
    NSString *encryptedJson = [BBAES encryptedStringFromData:jsonToSend IV:[BBAES randomIV] key:[self.passwordTextField.text dataUsingEncoding:NSUTF8StringEncoding] options:BBAESEncryptionOptionsIncludeIV];
    NSLog(@"encJson: %s",[encryptedJson UTF8String]);
    NSString* params = [NSString stringWithFormat:@"login=%@&encrypted=%s", self.loginTextField.text, [encryptedJson UTF8String]];
//    NSString* plainString = @"hello world!1111";
//    NSData *data = [NSData dataWithBytes:[plainString UTF8String] length:plainString.length];
//    NSString *string = [BBAES encryptedStringFromData:data IV:[BBAES randomIV] key:[self.passwordTextField.text dataUsingEncoding:NSUTF8StringEncoding] options:BBAESEncryptionOptionsIncludeIV];
//    NSLog(@"test string %@",string);
    NSURL* url = [NSURL URLWithString:[[KerbChatManager sharedKerbChatManager] loginUrlString]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    request.timeoutInterval = 10;
    NSURLResponse *response;
    NSError *error = nil;
    NSError *errorJson = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:&response
                                                       error:&error];
    if (error) {
        [self showAlert];
    } else {
        NSString *str = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"responce string : %@",str);
        //str = @"LSyU7aJ8aUwRtjMQf9Geh6p2dx1uav9ECUbXLDZu48I=";
        NSData *encodeData = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSData *resultBase64Decoded = [[NSData alloc] initWithBase64EncodedData:encodeData options:0];
        NSData *decryptedResult = [BBAES decryptedDataFromData:resultBase64Decoded IV:nil key:[self.passwordTextField.text dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *message = [[NSString alloc] initWithData:decryptedResult encoding:NSUTF8StringEncoding];
        NSLog(@"Decrypted message: %@",message);
        if (!decryptedResult) {
            [self showAlert];
        } else {
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:decryptedResult options:kNilOptions error:&errorJson];
            NSLog(@"%@", responseDict);
            [self successfulLogin];
        }
    }
}

-(void) successfulLogin {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainScreenViewController *viewController = (MainScreenViewController *)[storyboard instantiateViewControllerWithIdentifier:@"main"];
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void) showAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something wrong!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

@end
