//
//  AppDelegate.h
//  PropertyManager
//
//  Created by Roc on 14-8-16.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPush.h"
#import <CoreLocation/CoreLocation.h>
#import "Util.h"
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, BPushDelegate, CLLocationManagerDelegate, ASIHTTPRequestDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
// 判断程序是否在后台
@property (nonatomic, unsafe_unretained) BOOL executingInBackground;
@property (nonatomic) double lat;
@property (nonatomic) double lon;
@property (nonatomic, strong) NSString *address;

@property (nonatomic, strong) MainViewController *mainController;


@end
