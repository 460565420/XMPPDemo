
//
//  XMPPManager.m
//  XMPPDemo
//
//  Created by xieqilin on 2018/6/5.
//  Copyright © 2018年 xieqilin. All rights reserved.
//

#import "XMPPManager.h"

@interface XMPPManager ()

/** 好友列表数组 */
@property (nonatomic, strong) NSMutableArray *frilistList;

@end

@implementation XMPPManager

+ (instancetype)instence {
    static XMPPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XMPPManager alloc] init];
    });
    
    return manager;
}

#pragma mark Connect/disconnect
- (BOOL)connect
{
    if (![self.xmppStream isDisconnected]) {
        return YES;
    }

    if (myJID == nil || myPassword == nil) {
        return NO;
    }
    //不设置被其他设备挤掉，没有回调， 同时收不到消息
    [self.xmppStream setMyJID:[XMPPJID jidWithString:myJID resource:@"1"]];
    
    NSError *error = nil;
    if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                            message:@"See console for error details."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    
    return YES;
}

//退出并断开连接
- (void)disconnect
{
    [self goOffline];
    [self.xmppStream disconnect];
}

#pragma mark Private
- (void)setupStream
{
    NSAssert(self.xmppStream == nil, @"Method setupStream invoked multiple times");
    self.xmppStream = [[XMPPStream alloc] init];
    //设置连接的端口和服务器地址
    [self.xmppStream setHostName:Khost];
    [self.xmppStream setHostPort:Kport];
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];

#if !TARGET_IPHONE_SIMULATOR
    {
        self.xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    //添加功能模块
    //1.autoPing 发送的时一个stream:ping 对方如果想表示自己是活跃的，应该返回一个pong
    self.xmppAutoPing = [[XMPPAutoPing alloc] init];
    //所有的Module模块，都要激活active
    [self.xmppAutoPing activate:self.xmppStream];
    
    //autoPing由于它会定时发送ping,要求对方返回pong,因此这个时间我们需要设置
    [self.xmppAutoPing setPingInterval:180];
    //不仅仅是服务器来得响应;如果是普通的用户，一样会响应
    [self.xmppAutoPing setRespondsToQueries:YES];
    //这个过程是C---->S  ;观察 S--->C(需要在服务器设置）
    
    //2.autoReconnect 自动重连，当我们被断开了，自动重新连接上去，并且将上一次的信息自动加上去
    self.xmppReconnect = [[XMPPReconnect alloc] init];
    [self.xmppReconnect activate:self.xmppStream];
    [self.xmppReconnect setAutoReconnect:YES];
    
    // 3.好友模块 支持我们管理、同步、申请、删除好友
    self.xmppRosterMemoryStorage = [[XMPPRosterMemoryStorage alloc] init];
    self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterMemoryStorage];
    [self.xmppRoster activate:self.xmppStream];
    
    //同时给_xmppRosterMemoryStorage 和 _xmppRoster都添加了代理
    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //设置好友同步策略,XMPP一旦连接成功，同步好友到本地
    [self.xmppRoster setAutoFetchRoster:YES]; //自动同步，从服务器取出好友
    //关掉自动接收好友请求，默认开启自动同意
    [self.xmppRoster setAutoAcceptKnownPresenceSubscriptionRequests:NO];
    
    //4.消息模块，这里用单例，不能切换账号登录，否则会出现数据问题。
    self.xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    self.xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:self.xmppMessageArchivingCoreDataStorage dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 9)];
    [self.xmppMessageArchiving activate:self.xmppStream];
    
    //5、文件接收
    self.xmppIncomingFileTransfer = [[XMPPIncomingFileTransfer alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
    [self.xmppIncomingFileTransfer activate:self.xmppStream];
    [self.xmppIncomingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppIncomingFileTransfer setAutoAcceptFileTransfers:YES];
    
    //6、Setup vCard 好友名片实体类
    self.xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    //好友头像
    self.xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:self.xmppvCardStorage];
    self.xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.xmppvCardTempModule];
    
    // Setup capabilities
    self.xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    self.xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:self.xmppCapabilitiesStorage];

    self.xmppCapabilities.autoFetchHashedCapabilities = YES;
    self.xmppCapabilities.autoFetchNonHashedCapabilities = NO;

    [self.xmppvCardTempModule   activate:self.xmppStream];
    [self.xmppvCardAvatarModule activate:self.xmppStream];
    [self.xmppCapabilities      activate:self.xmppStream];
}

- (void)teardownStream
{
    [self.xmppStream removeDelegate:self];
    [self.xmppRoster removeDelegate:self];
    [self.xmppAutoPing removeDelegate:self];
    
    [self.xmppReconnect         deactivate];
    [self.xmppRoster            deactivate];
    [self.xmppvCardTempModule   deactivate];
    [self.xmppvCardAvatarModule deactivate];
    [self.xmppCapabilities      deactivate];
    [self.xmppAutoPing deactivate];

    [self.xmppStream disconnect];
    
    self.xmppStream = nil;
    self.xmppReconnect = nil;
    self.xmppRoster = nil;
    self.xmppvCardStorage = nil;
    self.xmppvCardTempModule = nil;
    self.xmppvCardAvatarModule = nil;
    self.xmppCapabilities = nil;
    self.xmppCapabilitiesStorage = nil;
    self.xmppAutoPing = nil;
}

//available 上线
//away 离开
//do not disturb 忙碌
//unavailable 下线

//上线
- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.xmppStream sendElement:presence];
}

//离线
- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

#pragma mark XMPPStream Delegate
//socket 连接建立成功
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
    NSLog(@"%s",__func__);
}

//这个是xml流初始化成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    [self.xmppStream authenticateWithPassword:myPassword error:nil];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    NSLog(@"%s",__func__);
}

//登录失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"%s",__func__);
}

//登录成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    [self goOnline];
}

//获取好友状态  同时返回好友列表 一次返回一个
//available 上线
//away 离开
//do not disturb 忙碌
//unavailable 下线
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    NSLog(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
    NSLog(@"%@", [presence type]);
    if ([presence.type isEqual:@"available"]) {
        [self.frilistList addObject:presence.fromStr];
    } else if ([presence.type isEqual:@"unavailable"]) {
        
    } else if ([presence.type isEqual:@"away"]) {
        
    } else if ([presence.type isEqual:@"do not disturb"]) {
        
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(getFriendList:)]) {
        [self.delegate getFriendList:self.frilistList];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error {
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}


#pragma mark -- XMPPAutoPingDelegate
- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender {
    NSLog(@"- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender");
}
- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender {
    NSLog(@"- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender");
}

- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender {
    NSLog(@"- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender");
}

#pragma mark XMPPRosterDelegate
- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence {
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
}

#pragma mark ===== 文件接收=======
/** 是否同意对方发文件给我 */
- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didReceiveSIOffer:(XMPPIQ *)offer {
    NSLog(@"%s",__FUNCTION__);
    //弹出一个是否接收的询问框
    //    [self.xmppIncomingFileTransfer acceptSIOffer:offer];
}

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didSucceedWithData:(NSData *)data named:(NSString *)name {
//    XMPPJID *jid = [sender.senderJID copy];
//    NSLog(@"%s",__FUNCTION__);
//    //在这个方法里面，我们通过带外来传输的文件
//    //因此我们的消息同步器，不会帮我们自动生成Message,因此我们需要手动存储message
//    //根据文件后缀名，判断文件我们是否能够处理，如果不能处理则直接显示。
//    //图片 音频 （.wav,.mp3,.mp4)
//    NSString *extension = [name pathExtension];
//    if (![@"wav" isEqualToString:extension]) {
//        return;
//    }
//    //创建一个XMPPMessage对象,message必须要有from
//    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:jid];
//    //将这个文件的发送者添加到Message的from
//    [message addAttributeWithName:@"from" stringValue:sender.senderJID.bare];
//    [message addSubject:@"audio"];
//
//    //保存data
//    NSString *path =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    path = [path stringByAppendingPathComponent:[XMPPStream generateUUID]];
//    path = [path stringByAppendingPathExtension:@"wav"];
//    [data writeToFile:path atomically:YES];
//
//    [message addBody:path.lastPathComponent];
//
//    [self.xmppMessageArchivingCoreDataStorage archiveMessage:message outgoing:NO xmppStream:self.xmppStream];
}

#pragma getter
- (NSMutableArray *)frilistList {
    if (!_frilistList) {
        _frilistList = [NSMutableArray array];
    }
    return _frilistList;
}


@end
