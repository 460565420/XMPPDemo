//
//  XMPPManager+MsgManager.m
//  XMPPDemo
//
//  Created by xieqilin on 2018/6/6.
//  Copyright © 2018年 xieqilin. All rights reserved.
//

#import "XMPPManager+MsgManager.h"
#import <AFNetworking/AFNetworking.h>

@implementation XMPPManager (MsgManager)

/**
 发送消息
 */
- (void)sendMessage:(NSString *)message toUser:(NSString *)user {
    NSString *siID = [self.xmppStream generateUUID];
    XMPPJID *jid = [XMPPJID jidWithUser:user domain:Khost resource:nil];
    XMPPMessage *mess = [[XMPPMessage alloc] initWithType:@"chat" to:jid elementID:siID];
    NSXMLElement *receipt = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
    [mess addChild:receipt];
    [mess addBody:message];
    [self.xmppStream sendElement:mess];
}

/**
 发送消息
 */
- (void)sendMessage:(NSString *)message toJID:(XMPPJID *)jid {
    NSString *siID = [self.xmppStream generateUUID];
    XMPPMessage *mess = [[XMPPMessage alloc] initWithType:@"chat" to:jid elementID:siID];
    NSXMLElement *receipt = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
    [mess addChild:receipt];
    [mess addBody:message];
    [self.xmppStream sendElement:mess];
}

- (void)sendPic:(NSString *)pic toUesr:(NSString *)user bodyName:(NSString *)name {
    NSString *siID = [self.xmppStream generateUUID];
    XMPPJID *jid = [XMPPJID jidWithUser:user domain:Khost resource:nil];
    XMPPMessage *mess = [[XMPPMessage alloc] initWithType:@"chat" to:jid elementID:siID];

    NSXMLElement *receipt = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
    [mess addChild:receipt];
    [mess addBody:[NSString stringWithFormat:@" Image://img_%@.png# ", siID]];
//    [self.xmppStream sendElement:mess];

    UIImage *image = [UIImage imageNamed:@"111111.jpg"];
    NSData *data = UIImageJPEGRepresentation(image, .5);
//    NSString *base64 = [data base64EncodedStringWithOptions:0];
//    XMPPElement *attment = [XMPPElement elementWithName:@"attachment" stringValue:base64];
//    [attment addChild:attment];
//    [self.xmppStream sendElement:attment];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30.0;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",nil];
    NSString *urlStr = [@"" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:urlStr parameters:@{@"id":siID,@"createJID":jid} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"file1" mimeType:@"image/jpg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"服务器返回:%@",str);
        id data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"%@", data);
        [self.xmppStream sendElement:mess];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
    
}

#pragma mark -- XMPPStreamDelegate


#pragma mark - Message
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"%s--%@",__FUNCTION__, message);
    //XEP--0136 已经用coreData实现了数据的接收和保存
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"iq:%@",iq);
    // 以下两个判断其实只需要有一个就够了
    NSString *elementID = iq.elementID;
    if (![elementID isEqualToString:@"getMyRooms"]) {
        return YES;
    }
    
    NSArray *results = [iq elementsForXmlns:@"http://jabber.org/protocol/disco#items"];
    if (results.count < 1) {
        return YES;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (DDXMLElement *element in iq.children) {
        if ([element.name isEqualToString:@"query"]) {
            for (DDXMLElement *item in element.children) {
                if ([item.name isEqualToString:@"item"]) {
                    [array addObject:item];          //array  就是你的群列表
                    
                }
            }
        }
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_GET_GROUPS object:array];
    
    return YES;
}

/**
 收到消息的回执  发送消息成功回调
 */
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    NSLog(@"消息：%@；发送成功", message);
}

////收到消息
//- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
//    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
//    NSString *messageBody = [[message elementForName:@"body"] stringValue];
////    NSString *msg = [[message elementForName:@"body"] stringValue];
////    NSString *from = [[message attributeForName:@"from"] stringValue];
////    NSString *to = [[message attributeForName:@"to"] stringValue];
//    
//    XMPPElement *delay = (XMPPElement *)[message elementsForName:@"delay"];
//    if(delay){  //如果有这个值 表示是一个离线消息
//        //获得时间戳
//        NSString *timeString = [[(XMPPElement *)[message elementForName:@"delay"] attributeForName:@"stamp"] stringValue];
//        //创建日期格式构造器
//        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
//        //按照T 把字符串分割成数组
//        NSArray *arr = [timeString componentsSeparatedByString:@"T"];
//        //获得日期字符串
//        NSString *dateStr = [arr objectAtIndex:0];
//        //获得时间字符串
//        NSString *timeStr = [[[arr objectAtIndex:1] componentsSeparatedByString:@"."] objectAtIndex:0];
//        //构建一个日期对象 这个对象的时区是0
//        NSDate *localDate = [formatter dateFromString:[NSString stringWithFormat:@"%@T%@+0000",dateStr,timeStr]];
//        NSLog(@"%@",localDate);
//    }
//    NSLog(@"收到消息：%@", messageBody);
//}
//
///**
// 收到消息的回执  发送消息成功回调
// */
//- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
//    NSLog(@"消息：%@；发送成功", message);
//}
//
//- (NSArray <XMPPMessageArchiving_Message_CoreDataObject *>*)getCoreDataHisMessage:(NSString *)jid {
//    
//    NSManagedObjectContext *context = [XMPPManager instence].messageContext;
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    //这里面要填的是XMPPARChiver的coreData实例类型
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    
//    //对取到的数据进行过滤,传入过滤条件.
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND bareJidStr == %@", myJID ,jid];
//    [fetchRequest setPredicate:predicate];
//    
//    //设置排序的关键字
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
//                                                                   ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
//    
//    NSError *error = nil;
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    for (XMPPMessageArchiving_Message_CoreDataObject *msg in fetchedObjects) {
//        //1是自己发的  0：对方发给自己的
//        NSLog(@"%@:%@",@(msg.isOutgoing), msg.body);
//    }
//    
//    return fetchedObjects;
//}


@end
