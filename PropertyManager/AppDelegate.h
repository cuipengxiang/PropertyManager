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

@property (nonatomic) double lat;
@property (nonatomic) double lon;
@property (nonatomic, strong) NSString *address;

@property (nonatomic, strong) MainViewController *mainController;
@property (nonatomic, strong) NSDate *lastUpdateDate;
@property (nonatomic, strong) NSTimer *time;
@property (nonatomic) BOOL runningInBackGround;

@end
