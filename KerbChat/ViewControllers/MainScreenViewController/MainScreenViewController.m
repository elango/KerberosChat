//
//  ViewController.m
//  KerbChat
//
//  Created by Anton Rodick on 23.05.15.
//  Copyright (c) 2015 Anton Rodick. All rights reserved.
//

#import "MainScreenViewController.h"
#import "ChatViewController.h"
#import "SRWebSocket.h"
#import "TCMessage.h"
#import "ChatHelper.h"
#import "AuthHelper.h"
#import "KerbChatManager.h"

@interface MainScreenViewController ()<SRWebSocketDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *roomsTableView;
@property (nonatomic) NSInteger clickedIndex;
@property (strong, nonatomic) NSString *clickedRoomName;

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
    [[KerbChatManager manager] setSocketDelegate:self];
    [[KerbChatManager manager] openSocket];
}

- (IBAction)logoutButton:(id)sender {
    [[KerbChatManager manager] closeSocket];
    [[KerbChatManager manager] removeSocket];
    [self.navigationController popViewControllerAnimated:YES];
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
    NSDictionary *json = [[ChatHelper helper] decryptedJsonFromServer:message];
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
    return YES;
}

- (void)sendInitialMessage {
    NSDictionary *jsonToSend = [[ChatHelper helper]
                                jsonForFirstSocketConnectionWithLogin:[[AuthHelper helper] login]
                                password:[[AuthHelper helper] password]];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonToSend
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if ([self sendMessage:jsonString]) {
        NSLog(@"Initial request sent");
    }
}

- (void)sendSecretMessageWithRoom:(NSString*) room {
    NSString *encryptedJson = [[ChatHelper helper] jsonForSecretWithRoom:room];
    if ([self sendMessage:encryptedJson]) {
        NSLog(@"Send secret message");
    }
}

#pragma mark
#pragma mark Receive methods

- (void)handlingReceiveMessage:(NSDictionary*) message withType:(NSString*) type {
    if ([type isEqualToString:@"handshake"]) {
        NSString *service = [message valueForKey:@"service"];
        if (![service isEqualToString:@"chat"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }
    if ([type isEqualToString:@"online"]) {
        NSLog(@"---- %@ ---- Received JSON with online type : %@",[message valueForKey:@"timestamp"], message);
        NSMutableDictionary *rooms = [NSMutableDictionary dictionary];
        for (NSDictionary *room in [message valueForKey:@"rooms"]) {
            [rooms setValue:room forKey:[room valueForKey:@"name"]];
        }
        [[KerbChatManager manager] setRooms:rooms];
        [[KerbChatManager manager] setOnlineUsers:[message valueForKey:@"users_online"]];
        [self.roomsTableView reloadData];
        return;
    }
    if ([type isEqualToString:@"new_room"]) {
        NSLog(@"Received JSON with new_chat type : %@",message);
        NSString *name = [[message valueForKey:@"room"] valueForKey:@"name"];
        NSString *secret = [message valueForKey:@"secret"];
        [[KerbChatManager manager] addSecretToStoreWithKey:name andValue:secret];
        return;
    }
    if ([type isEqualToString:@"get_secret"]) {
        NSLog(@"Received JSON with get_secret type : %@",message);
        NSString *room = [[message valueForKey:@"room"] valueForKey:@"name"];
        [self sendSecretMessageWithRoom:room];
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
    NSString *key = [[[[KerbChatManager manager] rooms] allKeys] objectAtIndex:indexPath.row];
    NSString *room = [[[KerbChatManager manager] rooms] objectForKey:key];
    cell.textLabel.text = [room valueForKey:@"name"];
    cell.detailTextLabel.text = [[room valueForKey:@"users"] componentsJoinedByString:@","];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.clickedIndex = indexPath.row;
    self.clickedRoomName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    [self performSegueWithIdentifier:@"room" sender:self];
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

#pragma mark
#pragma mark

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"room"])
    {
        [(ChatViewController*)[segue destinationViewController] setRoomName:self.clickedRoomName];
        [[KerbChatManager manager] setSocketDelegate:nil];
    }
    else
    {
        [super prepareForSegue:segue sender:sender];
    }

}

@end

