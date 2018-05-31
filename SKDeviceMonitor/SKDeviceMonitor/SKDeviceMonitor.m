//
//  SKDeviceMonitor.m
//  SKDeviceMonitor
//
//  Created by Sakya on 2018/5/31.
//  Copyright © 2018年 Sakya. All rights reserved.
//

#import "SKDeviceMonitor.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#include <sys/param.h>
#include <sys/mount.h>


@interface SKDeviceMonitor ()
@property (nonatomic, assign) long WWAN_sent;
@property (nonatomic, assign) long WWAN_received;
@property (nonatomic, assign) long WIFI_sent;
@property (nonatomic, assign) long WIFI_received;
@end
@implementation SKDeviceMonitor

+ (SKDeviceMonitor *)shareInstance {
    static SKDeviceMonitor *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[SKDeviceMonitor alloc] init];
    });
    return obj;
}
// 上行、下行流量
- (NSArray *)getInterfaceBytes {
    BOOL success;
    struct ifaddrs *addrs;
    struct ifaddrs *cursor;
    struct if_data *networkStatisc;
    long WiFiSent = 0;
    long WiFiReceived = 0;
    long WWANSent = 0;
    long WWANReceived = 0;
    NSString *name=[[NSString alloc]init];
    success = getifaddrs(&addrs) == 0;
    if (success)  {
        cursor = addrs;
        while (cursor != NULL)  {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
            //NSLog(@"ifa_name %s == %@\n", cursor->ifa_name,name);
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK) {
                if ([name hasPrefix:@"en"]) {
                    networkStatisc = (struct if_data *) cursor->ifa_data;
                    WiFiSent+=networkStatisc->ifi_obytes;
                    WiFiReceived+=networkStatisc->ifi_ibytes;
                }
                if ([name hasPrefix:@"pdp_ip"])  {
                    networkStatisc = (struct if_data *) cursor->ifa_data;
                    WWANSent+=networkStatisc->ifi_obytes;
                    WWANReceived+=networkStatisc->ifi_ibytes;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    
    NSArray *interfaceBytes =  [NSArray arrayWithObjects:
                                [NSNumber numberWithInt:(int)(WiFiSent - _WIFI_sent)],
                                [NSNumber numberWithInt:(int)(WiFiReceived - _WIFI_received)],
                                [NSNumber numberWithInt:(int)(WWANSent - _WWAN_sent)],
                                [NSNumber numberWithInt:(int)(WWANReceived - _WWAN_received)],
                                nil];
    _WIFI_sent = WiFiSent;
    _WIFI_received = WiFiReceived;
    _WWAN_sent = WWANSent;
    _WWAN_received = WWANReceived;
    //    NSLog(@"上一次%ld,%ld,%ld,%ld",self.WIFI_sent,self.WIFI_received,self.WWAN_sent,self.WWAN_received);
    //    NSLog(@"本次%ld,%ld,%ld,%ld",WiFiSent,WiFiReceived,WWANSent,WWANReceived);
    
    return interfaceBytes;
}

+ (NSString *)stringChangeWithbites:(float)bites {
    NSString *valueString;
    
    if (bites/1024> 1) {
        valueString = [NSString stringWithFormat:@"%.0f KB/s", bites/1024];
    } else if (bites/(1024 * 1024) > 1) {
        valueString = [NSString stringWithFormat:@"%.0f M/s", bites/(1024 * 1024)];
    } else {
        valueString = [NSString stringWithFormat:@"%.0f B/s", bites];
    }
    return valueString;
}
// 获取当前设备可用内存(单位：MB）
+ (double)appAvailableMemory {
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}
// 获取当前任务所占用的内存（单位：MB）
+ (double)appCurrentUsingMemory {
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
}
// 总磁盘容量
+ (float)appTotalDiskSize {
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks);
    }
    return freeSpace / 1024.0 / 1024.0;
}
// 可用磁盘容量
+ (float)appAvailableDiskSize {
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return freeSpace / 1024.0 / 1024.0;;
}

// 总内存
+ (long long)appTotalMemorySize {
    return [NSProcessInfo processInfo].physicalMemory;
}

@end
