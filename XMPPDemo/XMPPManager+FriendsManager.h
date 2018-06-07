//
//  XMPPManager+FriendsManager.h
//  XMPPDemo
//
//  Created by xieqilin on 2018/6/6.
//  Copyright © 2018年 xieqilin. All rights reserved.
//

#import "XMPPManager.h"

@interface XMPPManager (FriendsManager)

/**
 添加好友

 @param name 用户账号
 */
- (void)XMPPAddFriendSubscribe:(NSString *)name;

/**
 接受好友请求
 */
- (void)acceptFriendsRequest:(NSString *)presenceFromUser;

/**
 删除好友

 @param name 用户账号
 */
- (void)removeBuddy:(NSString *)name;

/**
 获取好友列表
 */
- (void)getFriendsList;

@end
