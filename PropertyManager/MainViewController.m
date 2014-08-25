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

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mainWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, IS_iOS7? 20.0:0.0, App_Width, IS_iOS7? self.view.frame.size.height - 20.0:self.view.frame.size.height)];
    [self.mainWebView setDelegate:self];
    [self.view addSubview:self.mainWebView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
    
    self.imagesShowedInSheet = [[NSMutableArray alloc] init];
    [self.imagesShowedInSheet addObject:[UIImage imageNamed:@"addPic.jpg"]];
    self.imagesSelected = [[NSMutableArray alloc] init];
    self.imagesDataToUpLoad = [[NSMutableArray alloc] init];
    
    NSString *urlString=[NSString stringWithFormat:@"%@", @"http://219.146.138.106:8888/ourally/app/property/sys/sysLogin.do"];
	NSURL *url=[NSURL URLWithString:urlString];
	NSURLRequest *request=[NSURLRequest requestWithURL:url];
	[self.mainWebView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = [[request URL] absoluteString];
    NSArray *urlComps = [urlString componentsSeparatedByString:@"://"];
    
    if([urlComps count] && [[urlComps objectAtIndex:0] isEqualToString:@"objc"])
    {
        NSArray *arrFucnameAndParameter = [(NSString*)[urlComps objectAtIndex:1] componentsSeparatedByString:@":"];
        NSString *funcStr = [arrFucnameAndParameter objectAtIndex:0];
        NSArray *params;
        if (arrFucnameAndParameter.count > 1) {
            params = [[arrFucnameAndParameter objectAtIndex:1] componentsSeparatedByString:@","];
        }
        
        if ([funcStr isEqualToString:@"getDateTime"]) {
            [self showDatePicker:YES];
            self.timeInputID = [params objectAtIndex:0];
            self.hasTime = YES;
        }
        if ([funcStr isEqualToString:@"getDateNOTime"]) {
            [self showDatePicker:NO];
            self.timeInputID = [params objectAtIndex:0];
            self.hasTime = NO;
        }
        if ([funcStr isEqualToString:@"addPic"]) {
            self.imageCompanyID = [params objectAtIndex:0];
            self.imageInputID = [params objectAtIndex:1];
            [self showPicAlertView];
        }
        if ([funcStr isEqualToString:@"showVoid"]) {
            self.voiceCompanyID = [params objectAtIndex:0];
            self.voiceInputID = [params objectAtIndex:1];
            [self showVoiceAlertView];
        }
        
        return NO;   
    };   
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
    
    if (self.imagesShowedInSheet.count < 5) {
        [self.imagesShowedInSheet addObject:[UIImage imageNamed:@"addPic.jpg"]];
    }
    
    [self showPicAlertView];
}

- (void)didClickOnImageIndex:(NSInteger *)imageIndex
{
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.maximumNumberOfSelectionVideo = 0;
    picker.maximumNumberOfSelectionPhoto = 5;
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
            NSData *imageData = UIImageJPEGRepresentation(img, 0.5);
            [self.imagesDataToUpLoad addObject:imageData];
        }
        NSString *xmlString;
        NSString *filenames;
        if (self.imagesDataToUpLoad.count > 0) {
            NSArray *array = [Util dataToXMLString:self.imagesDataToUpLoad companyID:self.imageCompanyID inputID:self.imageInputID];
            xmlString = [array objectAtIndex:0];
            filenames = [array objectAtIndex:1];
        }
        if (xmlString) {
            NSURL *url = [NSURL URLWithString:@"http://219.146.138.106:8888/ourally/android/AndroidServlet"];
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
        } else {
            [SVProgressHUD dismissWithError:@"上传失败"];
        }
    } else if (request.tag == 2000) {
        NSData *responseData = [request responseData];
        NSString *resultCode = [Util xmlDataToResultCode:responseData];
        NSString *filename = [Util xmlDataToFilename:responseData];
        NSString *resultMessage = [Util xmlDataToMessage:responseData];
        if ([resultCode isEqualToString:@"0001"]) {
            [SVProgressHUD dismiss];
            NSString *jsFunction = [NSString stringWithFormat:@"showVoid('%@', '%@', '%@')", filename, resultMessage, self.voiceInputID];
            [self.mainWebView stringByEvaluatingJavaScriptFromString:jsFunction];
        } else {
            [SVProgressHUD dismiss];
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
        NSLog(@"%@",[exception description]);
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
    
    NSString *xmlString = [Util dataToXMLString:data fileName:self.voiceCompanyID];
    
    if (xmlString) {
        NSURL *url = [NSURL URLWithString:@"http://219.146.138.106:8888/ourally/android/AndroidServlet"];
        
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
