//
//  XMPPManagerDelegate.h
//  XMPPDemo
//
//  Created by xieqilin on 2018/6/7.
//  Copyright © 2018年 xieqilin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XMPPManagerDelegate <NSObject>

@optional
- (void)getFriendList:(NSArray *)list;

@end
