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

@interface MainScreenViewController ()<SRWebSocketDelegate>

@property (nonatomic, strong) IBOutlet UIButton* btn;

@end

@implementation MainScreenViewController {
    SRWebSocket *_webSocket;
    NSMutableArray *_messages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    NSDictionary *jsonToSend = [[ChatHelper helper] jsonForFirstSocketConnectionWithLogin:[[AuthHelper helper] login] password:[[AuthHelper helper] password]];
//    NSData *jsonData = [NSKeyedArchiver archivedDataWithRootObject:jsonToSend];
    NSString *jsonString = [[NSString alloc] initWithFormat:@"%@", jsonToSend];
    [self sendMessage:jsonString];
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
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://ancient-fortress-4575.herokuapp.com/chat"]]];
    _webSocket.delegate = self;
    
    // self.title = @"Opening Connection...";
    [_webSocket open];
    
}
- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    self.title = @"Connected!";
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    self.title = @"Connection Failed! (see logs)";
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
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


@end

