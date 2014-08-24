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

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    /*
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"file" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self.mainWebView loadHTMLString:htmlString baseURL:[NSURL URLWithString:filePath]];
    */
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = [[request URL] absoluteString];
    NSArray *urlComps = [urlString componentsSeparatedByString:@"://"];
    
    if([urlComps count] && [[urlComps objectAtIndex:0] isEqualToString:@"objc"])
    {
        NSArray *arrFucnameAndParameter = [(NSString*)[urlComps objectAtIndex:1] componentsSeparatedByString:@":"];
        NSString *funcStr = [arrFucnameAndParameter objectAtIndex:0];
        
        if ([funcStr isEqualToString:@"getDateTime"]) {
            [self showDatePicker:YES];
        }
        if ([funcStr isEqualToString:@"getDateNOTime"]) {
            [self showDatePicker:NO];
        }
        if ([funcStr isEqualToString:@"addPic"]) {
            [self showPicAlertView];
        }
        if ([funcStr isEqualToString:@"showVoid"]) {
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
    NSString *jsFunction = [NSString stringWithFormat:@"setDateTime('%@','checkDate')", [Util stringFromDate:selectedDate]];
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
        if (self.imagesDataToUpLoad.count > 0) {
            xmlString = [Util dataToXMLString:self.imagesDataToUpLoad];
        }
        if (xmlString) {
            NSLog(xmlString);
            NSURL *url = [NSURL URLWithString:@"http://219.146.138.106:8888/ourally/android/AndroidServlet"];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setDelegate:self];
            [request setPostValue:@"uploadFileAction" forKey:@"service"];
            [request setPostValue:@"com.ht.ourally.common.action.UploadFileAction" forKey:@"classname"];
            [request setPostValue:@"uploadFilePic" forKey:@"method"];
            [request setPostValue:@"com.ht.mobile.android.entity" forKey:@"entityPageName"];
            [request setPostValue:xmlString forKey:@"data"];
            [request buildPostBody];
            [request startAsynchronous];
            
            [activity tappedCancel];
        }
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    NSString *string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", string);
    //NSString *jsFunction = [NSString stringWithFormat:@"setDateTime('%@','checkDate')", [Util stringFromDate:selectedDate]];
    //[self.mainWebView stringByEvaluatingJavaScriptFromString:jsFunction];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%@", request.responseString);
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
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"\nrecord finish ! \npath:%@ \nduration:%f",self.voice.recordPath,self.voice.recordTime] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

- (void)recordCancel
{
    [self.voice cancelled];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"取消了" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
