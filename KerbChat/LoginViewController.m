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
    NSData *encryptedJson = [jsonToSend AES128EncryptedDataWithKey:self.passwordTextField.text];
    NSString* params = [NSString stringWithFormat:@"login=%@&encrypted=%@", self.loginTextField.text, encryptedJson];
    NSURL* url = [NSURL URLWithString:[[KerbChatManager sharedKerbChatManager] loginUrlString]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    NSURLResponse *response;
    NSError *error = nil;
    NSError *errorJson = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:&response
                                                       error:&error];
    NSLog(@"result : %@", result);
    NSData *resultBase64Decoded = [[NSData alloc] initWithBase64EncodedData:result options:0];
    NSData *decryptedResult = [resultBase64Decoded AES128DecryptedDataWithKey:self.passwordTextField.text];
    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:decryptedResult options:kNilOptions error:&errorJson];
    NSLog(@"%@", responseDict);
    [self successfulLogin];
}

-(void) successfulLogin {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainScreenViewController *viewController = (MainScreenViewController *)[storyboard instantiateViewControllerWithIdentifier:@"main"];
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
