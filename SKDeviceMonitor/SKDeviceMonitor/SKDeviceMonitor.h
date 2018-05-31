//
//  SKDeviceMonitor.h
//  SKDeviceMonitor
//
//  Created by Sakya on 2018/5/31.
//  Copyright © 2018年 Sakya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKDeviceMonitor : NSObject
+ (SKDeviceMonitor *)shareInstance;

- (NSArray *)getInterfaceBytes;
// 获取当前设备可用内存(单位：MB）
+ (double)appAvailableMemory;
// 获取当前任务所占用的内存（单位：MB）
+ (double)appCurrentUsingMemory;
// 总磁盘容量
+ (float)appTotalDiskSize;
// 可用磁盘容量
+ (float)appAvailableDiskSize;
// 总内存
+ (long long)appTotalMemorySize;
+ (NSString *)stringChangeWithbites:(float)bites;
@end
