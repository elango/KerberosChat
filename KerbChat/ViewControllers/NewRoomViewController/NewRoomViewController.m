//
//  NewRoomViewController.m
//  KerbChat
//
//  Created by Anton Rodick on 30.05.15.
//  Copyright (c) 2015 Anton Rodick. All rights reserved.
//

#import "NewRoomViewController.h"
#import "KerbChatManager.h"
#import "ChatHelper.h"

@interface NewRoomViewController () <SRWebSocketDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *roomNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *thresholdTextField;
@property (nonatomic, strong) NSMutableArray *selectedUsers;

@end

@implementation NewRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedUsers = [NSMutableArray array];
    [[KerbChatManager manager] setSocketDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark
#pragma mark Socket Delegate methods

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

- (void)sendToCreateNewRoom {
    NSString *encryptedJson = [[ChatHelper helper] jsonForNewRoomWithUsers:self.selectedUsers
                                                                 threshold:self.thresholdTextField.text
                                                                   andName:self.roomNameTextField.text];
    if ([self sendMessage:encryptedJson]) {
        NSLog(@"Send new_room message");
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
    if ([type isEqualToString:@"online"]) {
        NSLog(@"---- %@ ---- Received JSON with online type : %@",[message valueForKey:@"timestamp"], message);
        NSMutableDictionary *rooms = [NSMutableDictionary dictionary];
        for (NSDictionary *room in [message valueForKey:@"rooms"]) {
            [rooms setValue:room forKey:[room valueForKey:@"name"]];
        }
        [[KerbChatManager manager] setRooms:rooms];
        [[KerbChatManager manager] setOnlineUsers:[message valueForKey:@"users_online"]];
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
    return [[[KerbChatManager manager] onlineUsers] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:16];
    cell.textLabel.text = [[[KerbChatManager manager] onlineUsers] objectAtIndex:indexPath.row];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *user = cell.textLabel.text;
    if([self.selectedUsers containsObject:user]){
        [self.selectedUsers removeObject:user];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }else{
        [self.selectedUsers addObject:user];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }

}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

#pragma mark
#pragma mark

- (IBAction)createRoom:(id)sender {
    [self sendToCreateNewRoom];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
