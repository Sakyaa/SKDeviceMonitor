//
//  ViewController.m
//  SKDeviceMonitor
//
//  Created by Sakya on 2018/5/31.
//  Copyright © 2018年 Sakya. All rights reserved.
//

#import "ViewController.h"
#import "SKDeviceMonitor.h"


@interface ViewController ()
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *textLabel1;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     // 空闲内存
     double availableMemory = [self availableMemory];
     // 已占用内存百分比
     double preMemory = availableMemory / ([self usedMemory] + availableMemory) * 100;
     // 可用磁盘容量
     double availableDiskSize = [self getAvailableDiskSize];
     // 总磁盘容量
     double totalDiskSize = [self getTotalDiskSize];
     // 可用磁盘百分比
     double preDisk = availableDiskSize / totalDiskSize * 100;
     */
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 70, 150, 40)];
    [self.view addSubview:_textLabel];
    _textLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(200, 70, 150, 40)];
    [self.view addSubview:_textLabel1];
    
    // 空闲内存
    double availableMemory = [SKDeviceMonitor appAvailableMemory];
    // 已占用内存百分比
    double preMemory = availableMemory / ([SKDeviceMonitor appCurrentUsingMemory] + availableMemory) * 100;
    
    // 可用磁盘容量
    double availableDiskSize = [SKDeviceMonitor appAvailableDiskSize];
    // 总磁盘容量
    double totalDiskSize = [SKDeviceMonitor appTotalDiskSize];
    // 可用磁盘百分比
    double preDisk = availableDiskSize / totalDiskSize * 100;
    
    
    UILabel *textLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(40, 150, 300, 40)];
    textLabel2.text = [NSString stringWithFormat:@"已占%%用内存百分比%f%%",preMemory];
    [self.view addSubview:textLabel2];
    UILabel *textLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(40, 220, 300, 40)];
    textLabel3.text = [NSString stringWithFormat:@"可用磁盘百分比%f%%",preDisk];
    
    [self.view addSubview:textLabel3];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshV) userInfo:nil repeats:YES];
    [timer fireDate];
    
}
- (void)refreshV {
    NSArray *dataArray = [[SKDeviceMonitor shareInstance] getInterfaceBytes];
    float wifiS_preSecond = [dataArray[0] floatValue];
    float wifiR_preSecond = [dataArray[1] floatValue];
    NSLog(@"上行%f,下行%f",wifiS_preSecond,wifiR_preSecond);
    NSLog(@"%@",dataArray);
    _textLabel.text = [SKDeviceMonitor stringChangeWithbites:wifiS_preSecond];
    _textLabel1.text = [SKDeviceMonitor stringChangeWithbites:wifiR_preSecond];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
