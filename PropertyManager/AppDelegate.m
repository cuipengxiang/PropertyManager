//
//  AppDelegate.m
//  PropertyManager
//
//  Created by Roc on 14-8-16.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "AppDelegate.h"

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
    self.mainController = mainController;
    self.window.rootViewController = mainController;
    
    [BPush setupChannel:launchOptions]; // 必须
    
    [BPush setDelegate:self]; // 必须。参数对象必须实现onMethod: response:方法，本示例中为self
    
    // [BPush setAccessToken:@"3.ad0c16fa2c6aa378f450f54adb08039.2592000.1367133742.282335-602025"];  // 可选。api key绑定时不需要，也可在其它时机调用
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings
                                                       settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                       categories:nil]];
    } else {
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeAlert
         | UIRemoteNotificationTypeBadge
         | UIRemoteNotificationTypeSound];
    }
    
    //定位服务初始化
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:10.0];
    [self.locationManager startUpdatingLocation];
    self.runningInBackGround = NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    }
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    //[NSTimer scheduledTimerWithTimeInterval:1800 target:self selector:@selector(startToGetLocation) userInfo:nil repeats:YES];
    
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [self.locationManager requestAlwaysAuthorization];
            }
            break;
        default:
            break;
    }
    
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
    self.backDate = [NSDate date];
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
    self.runningInBackGround = NO;
    [self.locationManager startUpdatingLocation];
    if (self.mainController&&self.mainController.refreshTime > 0) {
        self.returnDate = [NSDate date];
        NSTimeInterval interval;
        if (self.backDate) {
            interval = [self.returnDate timeIntervalSinceDate:self.backDate];
            self.backDate = nil;
        }
        if (interval > self.mainController.refreshTime*60) {
            NSLog(@"will enter foreground");
            NSString *urlString=[NSString stringWithFormat:@"%@app/property/sys/index.jsp", PUBLIC_ADDRESS];
            NSURL *url=[NSURL URLWithString:urlString];
            NSURLRequest *request=[NSURLRequest requestWithURL:url];
            [self.mainController.mainWebView loadRequest:request];
        }
    }
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

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //[self.mainController showNotify:[NSString stringWithFormat:@"收到新消息：%@", [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]];
    self.addingLocalNotification = NO;
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        NSLog(@"%@", userInfo);
        UILocalNotification *notification=[[UILocalNotification alloc] init];
        self.addingLocalNotification = YES;
        if (notification!=nil) {
            NSDate *now = [NSDate date];
            //从现在开始，1秒以后通知
            notification.fireDate=[now dateByAddingTimeInterval:0.1];
            //使用本地时区
            notification.timeZone=[NSTimeZone defaultTimeZone];
            notification.alertBody=[[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            //通知提示音 使用默认的
            notification.soundName= UILocalNotificationDefaultSoundName;
            //notification.alertAction=NSLocalizedString(@"你锁屏啦，通知时间到啦", nil);
            //这个通知到时间时，你的应用程序右上角显示的数字。
            //notification.applicationIconBadgeNumber = 1;
            //add key  给这个通知增加key 便于半路取消。nfkey这个key是我自己随便起的。
            // 假如你的通知不会在还没到时间的时候手动取消 那下面的两行代码你可以不用写了。
            NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:[userInfo objectForKey:@"aps"],@"aps",nil];
            [notification setUserInfo:dict];
            //启动这个通知
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            //这句真的特别特别重要。如果不加这一句，通知到时间了，发现顶部通知栏提示的地方有了，然后你通过通知栏进去，然后你发现通知栏里边还有这个提示
            //除非你手动清除，这当然不是我们希望的。加上这一句就好了。网上很多代码都没有，就比较郁闷了。
            
            /*
             [MPNotificationView notifyWithText:@"PropertyManager"
             detail:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
             image:[UIImage imageNamed:@"mopedDog.jpeg"]
             andDuration:3.0];
             */
        }
    } else {
        //[self.mainController showNotify:[NSString stringWithFormat:@"收到新消息：%@", [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]];
        [self.mainController showUserMessageView];
    }
    [BPush handleNotification:userInfo]; // 可选
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
        [[NSUserDefaults standardUserDefaults] synchronize];
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
        self.mainController.lat = coor.latitude;
        self.mainController.lon = coor.longitude;
        NSLog(@"当前位置：%@", self.address);
        //NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/location.txt"];
        //NSData *data = [self.address dataUsingEncoding:NSUTF8StringEncoding];
        //[data writeToFile:filePath atomically:YES];
        if (self.address&&self.address.length > 0) {
            //[self sendLocationInfoToServer];
        }
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
    if ((!util.userid)&&(!util.channelid)&&(!util.deviceid)) {
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@android/AndroidServlet", PUBLIC_ADDRESS]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setTag:3000];
    [request setPostValue:@"commBaseServiceAction" forKey:@"service"];
    [request setPostValue:@"com.ht.mobile.android.comm.web.action.CommBaseServiceAction" forKey:@"classname"];
    [request setPostValue:@"updateMemberGPSService" forKey:@"method"];
    [request setPostValue:@"com.ht.mobile.android.entity" forKey:@"entityPageName"];
    [request setPostValue:[util locationToXMLString:self.address lat:self.lat lon:self.lon time:[Util stringFromDate:[NSDate date] hasTime:YES]] forKey:@"data"];
    [request buildPostBody];
    //NSLog([[NSString alloc] initWithData:request.postBody encoding:NSUTF8StringEncoding]);
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

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary* dict = [notification userInfo];
    /*
     if (![[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
     [self.mainController showNotify:[NSString stringWithFormat:@"收到新消息：%@", [[dict objectForKey:@"aps"] objectForKey:@"alert"]]];
     }
     */
    if (self.addingLocalNotification) {
        [self.mainController showNotify:[NSString stringWithFormat:@"收到新消息：%@", [[dict objectForKey:@"aps"] objectForKey:@"alert"]]];
        self.addingLocalNotification = NO;
    } else {
        [self.mainController showUserMessageView];
    }
    //AudioServicesPlaySystemSound(1106);
    //[self.mainController showUserMessageView];
}

@end
