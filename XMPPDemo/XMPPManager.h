//
//  XMPPManager.h
//  XMPPDemo
//
//  Created by xieqilin on 2018/6/5.
//  Copyright © 2018年 xieqilin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPFramework/XMPPFramework.h>
#import "XMPPManagerDelegate.h"

static NSString *Khost = @"";
static NSInteger Kport = 5222;
static NSString *myJID = @"";
static NSString *myPassword = @"123456";

typedef void (^DICTBLOCK)(NSDictionary *dict);
typedef void (^ERRORBLOCK)(NSError *error);
typedef void (^LISTBLOCK)(NSArray *list);
typedef void (^BOOLBLOCK)(BOOL boolValue);
typedef void (^STRINGBLOCK)(NSString *str);
typedef void (^VOIDBLOCK)(void);
typedef void (^IDBLOCK)(id obj);

@interface XMPPManager : NSObject <XMPPStreamDelegate,XMPPRosterDelegate,XMPPRosterMemoryStorageDelegate,XMPPIncomingFileTransferDelegate>

@property (nonatomic, strong) XMPPStream *xmppStream;
//autoReconnect 自动重连
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
/** 心跳包 */
@property (nonatomic, strong) XMPPAutoPing *xmppAutoPing;

// 3.好友模块 支持我们管理、同步、申请、删除好友
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterMemoryStorage *xmppRosterMemoryStorage;

 //5、文件接收
@property (nonatomic, strong) XMPPIncomingFileTransfer *xmppIncomingFileTransfer;

/* XMPP聊天消息本地化处理对象 这里用单例，不能切换账号登录，否则会出现数据问题。*/
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchiving;
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property(nonatomic,strong) NSManagedObjectContext *messageContext;

@property (nonatomic, strong) XMPPPresence *receivePresence;


@property (nonatomic, strong) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
/** 好友名片（昵称，签名，性别，年龄等信息）在core data中的操作类 */
@property (nonatomic, strong) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic, strong) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong) XMPPvCardAvatarModule *xmppvCardAvatarModule;


@property (nonatomic, weak) id<XMPPManagerDelegate> delegate;


+ (instancetype)instence;
- (void)setupStream;

- (BOOL)connect;
- (void)disconnect;


@end
