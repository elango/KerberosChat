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

@interface MainScreenViewController ()<SRWebSocketDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *roomsTableView;

@end

@implementation MainScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self connect];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)connect
{
    NSString *chatUrl = [[KerbChatManager manager] chatUrlString];
    [[KerbChatManager manager] initSocketWithUrl:chatUrl];
    [[KerbChatManager manager] socket];
    [[KerbChatManager manager] setSocketDelegate:self];
    [[KerbChatManager manager] openSocket];
}

#pragma mark 
#pragma mark Socket Delegate methods

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"Websocket connected");
    [self sendInitialMessage];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@":( Websocket Failed With Error %@", error);
    [[KerbChatManager manager] removeSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSDictionary *json = [[ChatHelper helper] decryptedJsonForFirstReceive:message];
    NSString *messageType = [json valueForKey:@"type"];
    [self handlingReceiveMessage:json withType:messageType];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"WebSocket closed");
    [[KerbChatManager manager] removeSocket];
}

#pragma mark
#pragma mark Sending methods

- (BOOL)sendMessage:(NSString*) message
{
    [[KerbChatManager manager] sendSocketMessage:message];
//    [self.messages addObject:[[TCMessage alloc] initWithMessage:message fromMe:YES]];
    return YES;
}

- (void)sendInitialMessage {
    NSDictionary *jsonToSend = [[ChatHelper helper] jsonForFirstSocketConnectionWithLogin:[[AuthHelper helper] login]
                                                                                 password:[[AuthHelper helper] password]];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonToSend
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if ([self sendMessage:jsonString]) {
        NSLog(@"Initial request sent");
    }
}

#pragma mark
#pragma mark Receive methods

- (void)handlingReceiveMessage:(NSDictionary*) message withType:(NSString*) type {
    if ([type isEqualToString:@"online"]) {
        NSLog(@"---- %@ ---- Received JSON with online type : %@",[message valueForKey:@"timestamp"], message);
        [[KerbChatManager manager] setRooms: [message valueForKey:@"rooms"]];
        [[KerbChatManager manager] setOnlineUsers:[message valueForKey:@"users_online"]];
        [self.roomsTableView reloadData];
        return;
    }
    if ([type isEqualToString:@"new_chat"]) {
        NSLog(@"Received JSON with new_chat type : %@",message);
        [[[KerbChatManager manager] rooms] addObject:[message valueForKey:@"room"]];
        // TODO : set secret for new room
        return;
    }
    
}

#pragma mark
#pragma mark Table View delegate & data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[KerbChatManager manager] rooms] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:18];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [[[[KerbChatManager manager] rooms] objectAtIndex:indexPath.row] valueForKey:@"name"];
    cell.detailTextLabel.text = [[[[[KerbChatManager manager] rooms] objectAtIndex:indexPath.row] valueForKey:@"users"] componentsJoinedByString:@""];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)logoutButton:(id)sender {
    [[KerbChatManager manager] closeSocket];
    [[KerbChatManager manager] removeSocket];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

