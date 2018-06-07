//
//  XMPPManager+FriendsManager.m
//  XMPPDemo
//
//  Created by xieqilin on 2018/6/6.
//  Copyright © 2018年 xieqilin. All rights reserved.
//

#import "XMPPManager+FriendsManager.h"

@implementation XMPPManager (FriendsManager)

- (void)XMPPAddFriendSubscribe:(NSString *)name {
    //user@name
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:Khost resource:@"1"];
    //添加好友
    [self.xmppRoster subscribePresenceToUser:jid];
}

- (void)acceptFriendsRequest:(NSString *)presenceFromUser {
    XMPPJID *jid = [XMPPJID jidWithString:presenceFromUser];
    //接收添加好友请求
    [self.xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
}

//删除好友，name为好友账号
- (void)removeBuddy:(NSString *)name {
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",name,Khost]];
    [self.xmppRoster removeUser:jid];
}

#pragma mark ===== 好友模块 委托=======
/** 收到出席订阅请求（代表对方想添加自己为好友) */
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    //添加好友一定会订阅对方，但是接受订阅不一定要添加对方为好友
    self.receivePresence = presence;
    
//    NSString *message = [NSString stringWithFormat:@"【%@】想加你为好友",presence.from.bare];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
//    [alertView show];
}

/**
 好友在线状态改变   available  unavailable  away
 */
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    //收到对方取消定阅我得消息
    if ([presence.type isEqualToString:@"unsubscribe"]) {
        //从我的本地通讯录中将他移除
        [self.xmppRoster removeUser:presence.from];
    }
}

/**
 * 开始同步服务器发送过来的自己的好友列表
 **/
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender {
    
}

/**
 * 同步结束
 **/
//收到好友列表IQ会进入的方法，并且已经存入我的存储器
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {
//    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROSTER_CHANGE object:nil];
}

//收到每一个好友
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item {
    
}

// 如果不是初始化同步来的roster,那么会自动存入我的好友存储器
- (void)xmppRosterDidChange:(XMPPRosterMemoryStorage *)sender {
//    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROSTER_CHANGE object:nil];
}


@end
