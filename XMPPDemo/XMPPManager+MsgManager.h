//
//  XMPPManager+MsgManager.h
//  XMPPDemo
//
//  Created by xieqilin on 2018/6/6.
//  Copyright © 2018年 xieqilin. All rights reserved.
//

#import "XMPPManager.h"

@interface XMPPManager (MsgManager)

- (void)sendMessage:(NSString *)message toUser:(NSString *)user;
- (void)sendMessage:(NSString *)message toJID:(XMPPJID *)jid;

- (void)sendPic:(NSString *)pic toUesr:(NSString *)user bodyName:(NSString *)name;

/**
 本地的历史记录消息

 @param jid jid
 */
- (NSArray <XMPPMessageArchiving_Message_CoreDataObject *>*)getCoreDataHisMessage:(NSString *)jid;

@end
