//
//  ViewController.m
//  KerbChat
//
//  Created by Anton Rodick on 23.05.15.
//  Copyright (c) 2015 Anton Rodick. All rights reserved.
//

#import "MainScreenViewController.h"
#import "SRWebSocket.h"
#import "TCMessage.h"
#import "ChatHelper.h"
#import "AuthHelper.h"
#import "KerbChatManager.h"

@interface MainScreenViewController ()<SRWebSocketDelegate>

@property (nonatomic, strong) IBOutlet UIButton* btn;
@property (nonatomic) BOOL isCheckedConnection;
@end

@implementation MainScreenViewController {
    SRWebSocket *_webSocket;
    NSMutableArray *_messages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    _messages = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendPing:(id)sender;
{
    [_webSocket sendPing:nil];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [self _reconnect];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _webSocket.delegate = nil;
    [_webSocket close];
    _webSocket = nil;
}


- (void)_reconnect;
{
    _webSocket.delegate = nil;
    [_webSocket close];
    
    NSString *chatUrl = [[KerbChatManager manager] chatUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:chatUrl]];
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    _webSocket.delegate = self;
    
    [_webSocket open];
    
}
- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket connected");
    self.title = @"Connected!";
    self.isCheckedConnection = NO;
    [self sendJsonString];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    self.title = @"Connection Failed! (see logs)";
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    if (!self.isCheckedConnection) {
        NSDictionary *json = [[ChatHelper helper] decryptedJsonForFirstReceive:message];
        NSLog(@"Received JSON : %@",json);
        return;
    }
    NSLog(@"Received \"%@\"", message);
    [_messages addObject:[[TCMessage alloc] initWithMessage:message fromMe:NO]];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    self.title = @"Connection Closed! (see logs)";
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    NSLog(@"Websocket received pong");
}

- (bool)sendMessage:(NSString*) message
{
    [_webSocket send:message];
    [_messages addObject:[[TCMessage alloc] initWithMessage:message fromMe:YES]];
    return YES;
}

- (void) sendJsonString {
    NSDictionary *jsonToSend = [[ChatHelper helper] jsonForFirstSocketConnectionWithLogin:[[AuthHelper helper] login]
                                                                                 password:[[AuthHelper helper] password]];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonToSend
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if ([self sendMessage:jsonString]) {
        NSLog(@"Message sent");
    }
    
}

@end

