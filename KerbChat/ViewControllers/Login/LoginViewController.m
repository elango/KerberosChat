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
#import "AuthHelper.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden: YES animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.loginTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)login:(id)sender {
    [[AuthHelper helper] connectToChatWithLogin:self.loginTextField.text password:self.passwordTextField.text];
    if ([[AuthHelper helper] isOk]) {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

@end
