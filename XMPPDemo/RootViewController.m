//
//  RootViewController.m
//  XMPPDemo
//
//  Created by xieqilin on 2018/6/5.
//  Copyright © 2018年 xieqilin. All rights reserved.
//

#import "RootViewController.h"
#import "XMPPManager.h"
#import "XMPPManager+MsgManager.h"
#import "XMPPManager+FriendsManager.h"
#import "XMPPManagerDelegate.h"

@interface RootViewController () <XMPPManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *msgText;
@property (weak, nonatomic) IBOutlet UITextField *addText;
@property (weak, nonatomic) IBOutlet UIButton *friendsList;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)connect:(id)sender {
    [XMPPManager instence].delegate = self;
    [[XMPPManager instence] setupStream];
    [[XMPPManager instence] connect];
}

- (IBAction)disconnect:(id)sender {
    [[XMPPManager instence] disconnect];
}

- (IBAction)send:(id)sender {
    [[XMPPManager instence] sendMessage:@"哈哈哈哈哈" toUser:@"x1"];
}

- (IBAction)addFriends:(id)sender {
    [[XMPPManager instence] XMPPAddFriendSubscribe:self.addText.text];
}

- (IBAction)firendsList:(id)sender {
    NSMutableArray *list = [NSMutableArray arrayWithArray:[XMPPManager instence].xmppRosterMemoryStorage.unsortedUsers];
    XMPPUserMemoryStorageObject *user = list[0];
    NSLog(@"%@",user);
//    [[XMPPManager instence] getCoreDataHisMessage:@"db1@10.206.20.45"];
    [[XMPPManager instence] sendPic:@"" toUesr:@"lm" bodyName:nil];
    
}
@end
