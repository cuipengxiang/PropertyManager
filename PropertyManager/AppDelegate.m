//
//  AppDelegate.m
//  PropertyManager
//
//  Created by Roc on 14-8-16.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "AppDelegate.h"
#import "SVProgressHUD.h"

@implementation AppDelegate
{
    UIBackgroundTaskIdentifier bgTask;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    MainViewController *mainController = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = mainController;
    
    [BPush setupChannel:launchOptions]; // 必须
    
    [BPush setDelegate:self]; // 必须。参数对象必须实现onMethod: response:方法，本示例中为self
    
    // [BPush setAccessToken:@"3.ad0c16fa2c6aa378f450f54adb08039.2592000.1367133742.282335-602025"];  // 可选。api key绑定时不需要，也可在其它时机调用
    
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert
     | UIRemoteNotificationTypeBadge
     | UIRemoteNotificationTypeSound];
    
    //定位服务初始化
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:10.0];
    [self.locationManager startUpdatingLocation];
    self.runningInBackGround = NO;
    if (IS_iOS7) {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    }
    //[NSTimer scheduledTimerWithTimeInterval:1800 target:self selector:@selector(startToGetLocation) userInfo:nil repeats:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    self.runningInBackGround = YES;
    /*
    self.locationManager stopUpdatingLocation];
    UIApplication *app = [UIApplication sharedApplication];
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    //self.time = [NSTimer scheduledTimerWithTimeInterval:150 target:self selector:@selector(checkTimeForOneHour) userInfo:nil repeats:YES];
    NSLog(@"backgroundTimeRemaining: %.0f", [[UIApplication sharedApplication] backgroundTimeRemaining]);
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // 程序进入前台，转化为高精确定位
    //[self.locationManager stopMonitoringSignificantLocationChanges];
    //[self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [BPush registerDeviceToken:deviceToken]; // 必须
    
    [BPush bindChannel]; // 必须。可以在其它时机调用，只有在该方法返回（通过onMethod:response:回调）绑定成功时，app才能接收到Push消息。一个app绑定成功至少一次即可（如果access token变更请重新绑定）。
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [BPush handleNotification:userInfo]; // 可选
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"收到推送：%@",userInfo]];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"performFetchWithCompletionHandler");
    [self.locationManager startUpdatingLocation];
}

// 必须，如果正确调用了setDelegate，在bindChannel之后，结果在这个回调中返回。
// 若绑定失败，请进行重新绑定，确保至少绑定成功一次
- (void) onMethod:(NSString*)method response:(NSDictionary*)data
{
    if ([BPushRequestMethod_Bind isEqualToString:method])
    {
        NSDictionary* res = [[NSDictionary alloc] initWithDictionary:data];
        
        NSString *appid = [res valueForKey:BPushRequestAppIdKey];
        NSString *userid = [res valueForKey:BPushRequestUserIdKey];
        NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
        
        [[NSUserDefaults standardUserDefaults] setObject:channelid forKey:@"channelid"];
        [[NSUserDefaults standardUserDefaults] setObject:userid forKey:@"deviceid"];
        
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"百度推送绑定成功，channelid：%@，userid：%@", channelid, userid]];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    CLLocationCoordinate2D coor = currentLocation.coordinate;
    CLGeocoder *geo = [[CLGeocoder alloc] init];
    [geo reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *place = [placemarks lastObject];
        NSArray *addressArray = [[place addressDictionary] objectForKey:@"FormattedAddressLines"];
        NSString *string = [addressArray objectAtIndex:0];
        /*
        if (self.address) {
            [self.address appendString:string];
        } else {
            self.address = [[NSMutableString alloc] initWithString:string];
        }
         */
        self.address = string;
        
        self.lat = coor.latitude;
        self.lon = coor.longitude;
        NSLog(@"当前位置：%@", self.address);
        //NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/location.txt"];
        //NSData *data = [self.address dataUsingEncoding:NSUTF8StringEncoding];
        //[data writeToFile:filePath atomically:YES];
        [self sendLocationInfoToServer];
    }];
    if (self.runningInBackGround&&IS_iOS7) {
        [manager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"无法获得定位信息");
}

- (void)sendLocationInfoToServer
{
    if (self.lastUpdateDate) {
        NSTimeInterval timeInterval = [self.lastUpdateDate timeIntervalSinceNow];
        timeInterval = -timeInterval;
        long temp = 0;
        if((temp = timeInterval/60) < 60){
            return;
        }
    }
    NSLog(@"发送定位信息");
    Util *util = [[Util alloc] initWithAddress:self.address lat:self.lat lon:self.lon channelid:[[NSUserDefaults standardUserDefaults] objectForKey:@"channelid"] deviceid:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceid"]];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]) {
        util.userid = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    }
    NSURL *url = [NSURL URLWithString:@"http://219.146.138.106:8888/ourally/android/AndroidServlet"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setTag:3000];
    [request setPostValue:@"commBaseServiceAction" forKey:@"service"];
    [request setPostValue:@"com.ht.mobile.android.comm.web.action.CommBaseServiceAction" forKey:@"classname"];
    [request setPostValue:@"updateMemberGPSService" forKey:@"method"];
    [request setPostValue:@"com.ht.mobile.android.entity" forKey:@"entityPageName"];
    [request setPostValue:[util locationToXMLString:self.address lat:self.lat lon:self.lon time:[Util stringFromDate:[NSDate date] hasTime:YES]] forKey:@"data"];
    [request buildPostBody];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *result_code = [Util xmlDataToResultCode:request.responseData];
    if ([result_code isEqualToString:@"0001"]) {
        self.lastUpdateDate = [NSDate date];
        NSLog(@"成功");
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    
}

@end
