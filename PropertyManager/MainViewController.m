//
//  MainViewController.m
//  PropertyManager
//
//  Created by Roc on 14-8-16.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "MainViewController.h"
#import "ActionSheetDatePicker.h"
#import "Util.h"
#import "SVProgressHUD.h"
#import "lame.h"
#import "BDKNotifyHUD.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.refreshTime = 30;
        /*
        UILocalNotification *notification=[[UILocalNotification alloc] init];
        if (notification!=nil) {
            NSDate *now = [NSDate date];
            //从现在开始，10秒以后通知
            notification.fireDate=[now dateByAddingTimeInterval:10];
            //使用本地时区
            notification.timeZone=[NSTimeZone defaultTimeZone];
            notification.alertBody=@"顶部提示内容，通知时间到啦";
            //通知提示音 使用默认的
            notification.soundName= UILocalNotificationDefaultSoundName;
            notification.alertAction=NSLocalizedString(@"你锁屏啦，通知时间到啦", nil);
            //这个通知到时间时，你的应用程序右上角显示的数字。
            notification.applicationIconBadgeNumber = 1;
            //add key  给这个通知增加key 便于半路取消。nfkey这个key是我自己随便起的。
            // 假如你的通知不会在还没到时间的时候手动取消 那下面的两行代码你可以不用写了。
            NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"nfkey",nil];
            [notification setUserInfo:dict];
            //启动这个通知
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            //这句真的特别特别重要。如果不加这一句，通知到时间了，发现顶部通知栏提示的地方有了，然后你通过通知栏进去，然后你发现通知栏里边还有这个提示
            //除非你手动清除，这当然不是我们希望的。加上这一句就好了。网上很多代码都没有，就比较郁闷了。
        }
         */
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化网络不通时显示的badnetView
    UIImageView *cryImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CRY"]];
    [cryImage setFrame:CGRectMake((self.view.frame.size.width-60.0f)/2, 140.0f, 60.0f, 60.0f)];
    UILabel *badnetLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-150.0f)/2, 220.0f, 150.0f, 60.0f)];
    [badnetLabel setText:@"噢噢~~加载失败。请检查网络或重新加载。"];
    [badnetLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [badnetLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [badnetLabel setNumberOfLines:0];
    UIButton *badnetButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width-94.0f)/2, 290.0f, 94.0f, 29.0f)];
    [badnetButton setTitle:@"重新加载" forState:UIControlStateNormal];
    [[badnetButton titleLabel] setFont:[UIFont systemFontOfSize:16.0f]];
    [badnetButton addTarget:self action:@selector(badnetTryAgain) forControlEvents:UIControlEventTouchUpInside];
    [badnetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [badnetButton setBackgroundImage:[UIImage imageNamed:@"start_btn_bg"] forState:UIControlStateNormal];
    self.badnetView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    [self.badnetView setBackgroundColor:[UIColor whiteColor]];
    [self.badnetView addSubview:cryImage];
    [self.badnetView addSubview:badnetButton];
    [self.badnetView addSubview:badnetLabel];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tapReceivedNotificationHandler:)
                                                 name:kMPNotificationViewTapReceivedNotification
                                               object:nil];
    
    self.mainWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, IS_iOS7? 20.0:0.0, App_Width, IS_iOS7? self.view.frame.size.height - 20.0:self.view.frame.size.height)];
    [self.mainWebView setDelegate:self];
    [self.view addSubview:self.mainWebView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
    
    self.imagesShowedInSheet = [[NSMutableArray alloc] init];
    [self.imagesShowedInSheet addObject:[UIImage imageNamed:@"addPic.jpg"]];
    self.imagesSelected = [[NSMutableArray alloc] init];
    self.imagesDataToUpLoad = [[NSMutableArray alloc] init];
    
    NSString *urlString=[NSString stringWithFormat:@"%@app/property/sys/index.jsp", PUBLIC_ADDRESS];
	NSURL *url=[NSURL URLWithString:urlString];
	NSURLRequest *request=[NSURLRequest requestWithURL:url];
    self.currentUrlRequest = request;
	[self.mainWebView loadRequest:request];
}

- (void)tapReceivedNotificationHandler:(NSNotification *)notice
{
    MPNotificationView *notificationView = (MPNotificationView *)notice.object;
    if ([notificationView isKindOfClass:[MPNotificationView class]])
    {
        
    }
}

- (void)badnetTryAgain
{
    [self.badnetView removeFromSuperview];
    [self.mainWebView loadRequest:self.currentUrlRequest];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSString *errorKey = [[error userInfo] objectForKey:@"NSErrorFailingURLStringKey"];
    if (![[errorKey substringToIndex:11] isEqualToString:@"sharesdk://"]) {
        [SVProgressHUD dismissWithError:@"加载页面失败" afterDelay:2.0];
        [self.view addSubview:self.badnetView];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD showWithStatus:@"正在加载页面,请稍后..."];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = [[request URL] absoluteString];
    NSArray *urlComps = [urlString componentsSeparatedByString:@"://"];
    
    if([urlComps count] && [[urlComps objectAtIndex:0] isEqualToString:@"objc"])
    {
        NSArray *arrFucnameAndParameter = [(NSString*)[urlComps objectAtIndex:1] componentsSeparatedByString:@"_"];
        NSString *funcStr = [arrFucnameAndParameter objectAtIndex:0];
        NSArray *params;
        if (arrFucnameAndParameter.count > 1) {
            params = [[arrFucnameAndParameter objectAtIndex:1] componentsSeparatedByString:@"/"];
        }
        
        if ([funcStr isEqualToString:@"getDateTime"]) {
            [self showDatePicker:YES];
            self.timeInputID = [params objectAtIndex:0];
            self.hasTime = YES;
        }
        if ([funcStr isEqualToString:@"getDateNoTime"]) {
            [self showDatePicker:NO];
            self.timeInputID = [params objectAtIndex:0];
            self.hasTime = NO;
        }
        if ([funcStr isEqualToString:@"addPic"]) {
            self.imageCompanyID = [params objectAtIndex:0];
            self.imageInputID = [params objectAtIndex:1];
            [self showPicAlertView];
        }
        if ([funcStr isEqualToString:@"addPic4DDXD"]) {
            self.imageCompanyID = [params objectAtIndex:0];
            self.imageInputID = [params objectAtIndex:1];
            [self showPic4DDXDAlertView];
        }
        if ([funcStr isEqualToString:@"showVoid"]) {
            self.voiceCompanyID = [params objectAtIndex:0];
            self.voiceInputID = [params objectAtIndex:1];
            [self showVoiceAlertView];
        }
        if ([funcStr isEqualToString:@"SendUserId"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[params objectAtIndex:0] forKey:@"userid"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSString *jsFunction = [NSString stringWithFormat:@"upUserChannelId('%@','%@','%@')", [[NSUserDefaults standardUserDefaults] objectForKey:@"channelid"], [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceid"], @"4"];
            [self.mainWebView stringByEvaluatingJavaScriptFromString:jsFunction];
            [self sendDeviceInfo];
            //[self sendAppList];
        }
        if ([funcStr isEqualToString:@"locate"]) {
            NSString *jsFunction = [NSString stringWithFormat:@"getLocation('%f','%f')", self.lat, self.lon];
            [self.mainWebView stringByEvaluatingJavaScriptFromString:jsFunction];
        }
        if ([funcStr isEqualToString:@"getUserChannelId"]) {
            NSString *jsFunction = [NSString stringWithFormat:@"setUserChannelId('%@','%@')", [[NSUserDefaults standardUserDefaults] objectForKey:@"channelid"], [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceid"]];
            [self.mainWebView stringByEvaluatingJavaScriptFromString:jsFunction];
        }
        if ([funcStr isEqualToString:@"isFirstIn"]) {
            int first = 1;
            NSString *isFirst = [[NSUserDefaults standardUserDefaults] objectForKey:@"isfirst"];
            if (isFirst&&[isFirst isEqualToString:@"0"]) {
                first = 0;
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"isfirst"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            NSString *jsFunction = [NSString stringWithFormat:@"isUsed('%d','%@')", first, [NSString stringWithFormat:@"property%@", [[[UIDevice currentDevice] identifierForVendor] UUIDString]]];
            [self.mainWebView stringByEvaluatingJavaScriptFromString:jsFunction];
        }
        if ([funcStr isEqualToString:@"getImeiId"]) {
            NSString *jsFunction = [NSString stringWithFormat:@"setImeiId('%@')", [NSString stringWithFormat:@"property%@", [[[UIDevice currentDevice] identifierForVendor] UUIDString]]];
            [self.mainWebView stringByEvaluatingJavaScriptFromString:jsFunction];
        }
        if ([funcStr isEqualToString:@"setRefreshTime"]) {
            self.refreshTime = [[params objectAtIndex:0] integerValue];
        }
        
        return NO;   
    } else {
        self.currentUrlRequest = request;
    }
    return YES;
}

- (void)showDatePicker:(BOOL)time
{
    ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:(time? UIDatePickerModeDateAndTime:UIDatePickerModeDate) selectedDate:[NSDate date] target:self action:@selector(dateWasSelected:) origin:self.view];
    [actionSheetPicker addCustomButtonWithTitle:@"今天" value:[NSDate date]];
    actionSheetPicker.hideCancel = YES;
    [actionSheetPicker showActionSheetPicker];
}

- (void)dateWasSelected:(NSDate *)selectedDate {
    NSString *jsFunction = [NSString stringWithFormat:@"setDateTime('%@','%@')", [Util stringFromDate:selectedDate hasTime:self.hasTime], self.timeInputID];
    [self.mainWebView stringByEvaluatingJavaScriptFromString:jsFunction];
}

- (void)showPicAlertView
{
    LXActivity *lxActivity = [[LXActivity alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitle:@"上传" ShareButtonTitles:nil withShareButtonImagesName:self.imagesShowedInSheet];
    lxActivity.maxCount = 5;
    [lxActivity showInView:self.view];
}

- (void)showPic4DDXDAlertView
{
    LXActivity *lxActivity = [[LXActivity alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitle:@"上传" ShareButtonTitles:nil withShareButtonImagesName:self.imagesShowedInSheet];
    lxActivity.maxCount = 6;
    [lxActivity showInView:self.view];
}

- (void)showVoiceAlertView
{
    LXVoiceActivity *lxActivity = [[LXVoiceActivity alloc] initWithTitle:nil delegate:self];
    [lxActivity showInView:self.view];
    self.hasRecorded = NO;
    [Util deleteOldVoiceFile];
}

- (void)keyboardWillShow:(id)sender
{
    //[self performSelector:@selector(removeBar) withObject:nil afterDelay:0];
}

- (void)removeBar {
    // Locate non-UIWindow.
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if (![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    // Locate UIWebFormView
    for (UIView *possibleFormView in [keyboardWindow subviews]) {
        if ([[possibleFormView description] hasPrefix:@"<UIPeripheralHostView"]) {
            for (UIView* peripheralView in [possibleFormView subviews]) {
                
                // hides the backdrop (iOS 7)
                if ([[peripheralView description] hasPrefix:@"<UIKBInputBackdropView"]) {
                    //skip the keyboard background....hide only the toolbar background
                    if ([peripheralView frame].origin.y == 0){
                        [[peripheralView layer] setOpacity:0.0];
                    }
                }
                
                // hides the accessory bar
                if ([[peripheralView description] hasPrefix:@"<UIWebFormAccessory"]) {
                    // remove the extra scroll space for the form accessory bar
                    UIScrollView *webScroll;
                    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
                        webScroll = [self.mainWebView scrollView];
                    } else {
                        webScroll = [[self.mainWebView subviews] lastObject];
                    }
                    CGRect newFrame = webScroll.frame;
                    newFrame.size.height += peripheralView.frame.size.height;
                    webScroll.frame = newFrame;
                    
                    // remove the form accessory bar
                    [peripheralView removeFromSuperview];
                }
                // hides the thin grey line used to adorn the bar (iOS 6)
                if ([[peripheralView description] hasPrefix:@"<UIImageView"]) {
                    [[peripheralView layer] setOpacity:0.0];
                }
            }
        }
    }
}

- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [self.imagesShowedInSheet removeAllObjects];
    [self.imagesSelected removeAllObjects];
    for (int i = 0; i < assets.count; i++) {
        ALAsset *alAsset = assets[i];
        
        UIImage *img = [UIImage imageWithCGImage:alAsset.defaultRepresentation.fullResolutionImage
                                           scale:alAsset.defaultRepresentation.scale
                                     orientation:(UIImageOrientation)alAsset.defaultRepresentation.orientation];
        [self.imagesShowedInSheet addObject:img];
        [self.imagesSelected addObject:alAsset];
    }
    
    if (self.imagesShowedInSheet.count < picker.maximumNumberOfSelectionPhoto) {
        [self.imagesShowedInSheet addObject:[UIImage imageNamed:@"addPic.jpg"]];
    }
    
    if (picker.maximumNumberOfSelectionPhoto == 5) {
        [self showPicAlertView];
    } else if (picker.maximumNumberOfSelectionPhoto == 6) {
        [self showPic4DDXDAlertView];
    }
}

- (void)didClickOnImageIndex:(NSInteger *)imageIndex onActivity:(LXActivity *)activity
{
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.maximumNumberOfSelectionVideo = 0;
    picker.maximumNumberOfSelectionPhoto = activity.maxCount;
    picker.imagesHasSelected = self.imagesSelected;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (void)didClickOnOtherButton:(LXActivity *)activity
{
    if ((self.imagesSelected)&&(self.imagesSelected.count > 0)) {
        [self.imagesDataToUpLoad removeAllObjects];
        for (int i = 0; i < self.imagesSelected.count; i++) {
            ALAsset *alAsset = [self.imagesSelected objectAtIndex:i];
            UIImage *img = [UIImage imageWithCGImage:alAsset.defaultRepresentation.fullResolutionImage
                                               scale:alAsset.defaultRepresentation.scale
                                         orientation:(UIImageOrientation)alAsset.defaultRepresentation.orientation];
            UIImage *newimage = [self imageCompressForWidth:img targetWidth:640.0];
            NSData *imageData = UIImageJPEGRepresentation(newimage, 0.1);
            [self.imagesDataToUpLoad addObject:imageData];
        }
        NSString *xmlString;
        NSString *filenames;
        if (self.imagesDataToUpLoad.count > 0) {
            Util *util = [[Util alloc] initWithAddress:self.address lat:self.lat lon:self.lon channelid:[[NSUserDefaults standardUserDefaults] objectForKey:@"channelid"] deviceid:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceid"]];
            NSArray *array = [util dataToXMLString:self.imagesDataToUpLoad companyID:self.imageCompanyID inputID:self.imageInputID];
            xmlString = [array objectAtIndex:0];
            filenames = [array objectAtIndex:1];
        }
        if (activity.maxCount == 6) {
            if (xmlString) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@android/AndroidServlet", PUBLIC_ADDRESS_PIC6]];
                NSMutableDictionary *contain = [[NSMutableDictionary alloc] init];
                [contain setObject:filenames forKey:@"filenames"];
                
                ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
                [request setDelegate:self];
                [request setTag:1000];
                request.contain = contain;
                [request setPostValue:@"uploadFileAction" forKey:@"service"];
                [request setPostValue:@"com.ht.utils.upload.UploadFileAction" forKey:@"classname"];
                [request setPostValue:@"uploadFilePic" forKey:@"method"];
                [request setPostValue:@"com.ht.utils.android.entity" forKey:@"entityPageName"];
                [request setPostValue:xmlString forKey:@"data"];
                [request buildPostBody];
                [request startAsynchronous];
                
                [SVProgressHUD showWithStatus:@"正在上传,请稍后..."];
                
                [activity tappedCancel];
            }
        } else if (activity.maxCount == 5) {
            if (xmlString) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@android/AndroidServlet", PUBLIC_ADDRESS]];
                NSMutableDictionary *contain = [[NSMutableDictionary alloc] init];
                [contain setObject:filenames forKey:@"filenames"];
            
                ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
                [request setDelegate:self];
                [request setTag:1000];
                request.contain = contain;
                [request setPostValue:@"uploadFileAction" forKey:@"service"];
                [request setPostValue:@"com.ht.ourally.common.action.UploadFileAction" forKey:@"classname"];
                [request setPostValue:@"uploadFilePic" forKey:@"method"];
                [request setPostValue:@"com.ht.mobile.android.entity" forKey:@"entityPageName"];
                [request setPostValue:xmlString forKey:@"data"];
                [request buildPostBody];
                [request startAsynchronous];
            
                [SVProgressHUD showWithStatus:@"正在上传,请稍后..."];
            
                [activity tappedCancel];
            }
        }
        [self.imagesSelected removeAllObjects];
        [self.imagesShowedInSheet removeAllObjects];
        [self.imagesShowedInSheet addObject:[UIImage imageNamed:@"addPic.jpg"]];
    }
}

- (void)didClickOnCancelButton
{
    [self.imagesSelected removeAllObjects];
    [self.imagesShowedInSheet removeAllObjects];
    [self.imagesShowedInSheet addObject:[UIImage imageNamed:@"addPic.jpg"]];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.tag == 1000) {
        NSData *responseData = [request responseData];
        NSString *resultCode = [Util xmlDataToResultCode:responseData];
        if ([resultCode isEqualToString:@"0001"]) {
            [SVProgressHUD dismissWithSuccess:@"上传成功"];
            NSString *filenames = [request.contain objectForKey:@"filenames"];
            NSString *jsFunction = [NSString stringWithFormat:@"showPic('%@', '%@')", filenames, self.imageInputID];
            [self.mainWebView stringByEvaluatingJavaScriptFromString:jsFunction];
            [self.imagesSelected removeAllObjects];
        } else {
            [SVProgressHUD dismissWithError:@"上传失败"];
        }
    } else if (request.tag == 2000) {
        NSData *responseData = [request responseData];
        NSString *resultCode = [Util xmlDataToResultCode:responseData];
        NSString *filename = [Util xmlDataToFilename:responseData];
        NSString *resultMessage = [Util xmlDataToMessage:responseData];
        if ([resultCode isEqualToString:@"0001"]) {
            [SVProgressHUD dismissWithSuccess:@"上传成功"];
            NSString *jsFunction = [NSString stringWithFormat:@"showVoid('%@', '%@', '%@')", filename, resultMessage, self.voiceInputID];
            [self.mainWebView stringByEvaluatingJavaScriptFromString:jsFunction];
        } else {
            [SVProgressHUD dismissWithError:@"上传失败"];
        }
    } else if (request.tag == 4000) {
        NSData *responseData = [request responseData];
        NSString *resultCode = [Util xmlDataToResultCode:responseData];
        if ([resultCode isEqualToString:@"0001"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"phoneInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            
        }
    } else if (request.tag == 5000) {
        NSData *responseData = [request responseData];
        NSString *resultCode = [Util xmlDataToResultCode:responseData];
        if ([resultCode isEqualToString:@"0001"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"appList"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismissWithError:@"上传失败"];
}

- (void)recordStart
{
    self.voice = [[LCVoice alloc] init];
    [self.voice startRecordWithPath:[NSString stringWithFormat:@"%@/Documents/MySound.caf", NSHomeDirectory()]];
}

- (void)recordEnd
{
    [self.voice stopRecordWithCompletionBlock:^{
        if (self.voice.recordTime > 0.0f) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"\n录音完成!\n录音时长:%f", self.voice.recordTime] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
            self.hasRecorded = YES;
        }
    }];
}

- (void)recordCancel
{
    [self.voice cancelled];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"取消录音" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)didClickOnSendButton:(LXVoiceActivity *)activity
{
    if (self.hasRecorded) {
        [SVProgressHUD showWithStatus:@"正在上传,请稍后..."];
        [activity tappedCancel];
        [NSThread detachNewThreadSelector:@selector(toMp3) toTarget:self withObject:nil];
    }
}

- (void)toMp3
{
    NSString *cafFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MySound.caf"];
    
    NSString *mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MySound.mp3"];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"Mp3 Exception：%@",[exception description]);
    }
    @finally {
        [self performSelectorOnMainThread:@selector(convertMp3Finish)
                               withObject:nil
                            waitUntilDone:YES];
    }
}

- (void)convertMp3Finish
{
    NSString *mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MySound.mp3"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:mp3FilePath];
    
    Util *util = [[Util alloc] initWithAddress:self.address lat:self.lat lon:self.lon channelid:[[NSUserDefaults standardUserDefaults] objectForKey:@"channelid"] deviceid:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceid"]];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]) {
        util.userid = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    }
    NSString *xmlString = [util dataToXMLString:data fileName:self.voiceCompanyID];
    
    if (xmlString) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@android/AndroidServlet", PUBLIC_ADDRESS]];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setDelegate:self];
        [request setTag:2000];
        [request setPostValue:@"uploadFileAction" forKey:@"service"];
        [request setPostValue:@"com.ht.ourally.common.action.UploadFileAction" forKey:@"classname"];
        [request setPostValue:@"uploadFileVoid" forKey:@"method"];
        [request setPostValue:@"com.ht.mobile.android.entity" forKey:@"entityPageName"];
        [request setPostValue:xmlString forKey:@"data"];
        [request buildPostBody];
        [request startAsynchronous];
    }
}

- (void)sendDeviceInfo
{
    NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneInfo"];
    if ((phone)&&([phone isEqualToString:@"1"])) {
        return;
    }
    Util *util = [[Util alloc] initWithAddress:self.address lat:self.lat lon:self.lon channelid:[[NSUserDefaults standardUserDefaults] objectForKey:@"channelid"] deviceid:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceid"]];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]) {
        util.userid = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    }
    if ((!util.userid)&&(!util.channelid)&&(!util.deviceid)) {
        return;
    }
    NSString *xmlString = [util deviceInfoToXMLString];
    
    if (xmlString) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@android/AndroidServlet", PUBLIC_ADDRESS]];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setDelegate:self];
        [request setTag:4000];
        [request setPostValue:@"commBaseServiceAction" forKey:@"service"];
        [request setPostValue:@"com.ht.mobile.android.comm.web.action.CommBaseServiceAction" forKey:@"classname"];
        [request setPostValue:@"updatePhoneParameterService" forKey:@"method"];
        [request setPostValue:@"com.ht.mobile.android.entity" forKey:@"entityPageName"];
        [request setPostValue:xmlString forKey:@"data"];
        [request buildPostBody];
        [request startAsynchronous];
    }
}

- (void)sendAppList
{
    NSArray *array = [Util runningProcesses];
    NSString * xmlString;
    if (array.count > 0) {
        Util *util = [[Util alloc] initWithAddress:self.address lat:self.lat lon:self.lon channelid:[[NSUserDefaults standardUserDefaults] objectForKey:@"channelid"] deviceid:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceid"]];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]) {
            util.userid = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
        }
        xmlString = [util appListToXMLString:array];
    }
    if (xmlString) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@android/AndroidServlet", PUBLIC_ADDRESS]];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setDelegate:self];
        [request setTag:5000];
        [request setPostValue:@"commBaseServiceAction" forKey:@"service"];
        [request setPostValue:@"com.ht.mobile.android.comm.web.action.CommBaseServiceAction" forKey:@"classname"];
        [request setPostValue:@"upLoadMemberDataLog" forKey:@"method"];
        [request setPostValue:@"com.ht.mobile.android.entity" forKey:@"entityPageName"];
        [request setPostValue:xmlString forKey:@"data"];
        [request buildPostBody];
        [request startAsynchronous];
    }
    
}

//依照宽度，等比例压缩图片
- (UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}


//对图片尺寸进行压缩--
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showNotify:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新消息" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
    } else {
        [self showUserMessageView];
    }
}

- (void)showUserMessageView
{
    NSString *urlString = [NSString stringWithFormat:@"%@app/property/message/getMessageList.do?userId=%@", PUBLIC_ADDRESS,[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]];
    NSURL *url=[NSURL URLWithString:urlString];
	NSURLRequest *request=[NSURLRequest requestWithURL:url];
	[self.mainWebView loadRequest:request];
}

@end
