//
//  AppDelegate.h
//  XMPPDemo
//
//  Created by xieqilin on 2018/6/5.
//  Copyright © 2018年 xieqilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XMPPFramework/XMPPFramework.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, XMPPStreamDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

