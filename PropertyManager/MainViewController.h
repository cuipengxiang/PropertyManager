//
//  MainViewController.h
//  PropertyManager
//
//  Created by Roc on 14-8-16.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UzysAssetsPickerController.h"
#import "LXActivity.h"
#import "LXVoiceActivity.h"
#import "LCVoice.h"
#import "MPNotificationView.h"

@interface MainViewController : UIViewController<UIWebViewDelegate, UzysAssetsPickerControllerDelegate, LXActivityDelegate, LXVoiceActivityDelegate, ASIHTTPRequestDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIWebView *mainWebView;
@property (nonatomic, strong) NSMutableArray *imagesShowedInSheet;
@property (nonatomic, strong) LCVoice *voice;
@property (nonatomic, strong) NSMutableArray *imagesSelected;
@property (nonatomic, strong) NSMutableArray *imagesDataToUpLoad;
@property (nonatomic, strong) NSString *imageCompanyID;
@property (nonatomic, strong) NSString *imageInputID;
@property (nonatomic, strong) NSString *timeInputID;
@property (nonatomic) BOOL hasTime;
@property (nonatomic) BOOL hasRecorded;
@property (nonatomic, strong) NSString *voiceCompanyID;
@property (nonatomic, strong) NSString *voiceInputID;

@property (nonatomic, strong) NSString *address;
@property (nonatomic) double lat;
@property (nonatomic) double lon;

@property (nonatomic, strong) UIView *badnetView;
@property (nonatomic, strong) NSURLRequest *currentUrlRequest;

@property (nonatomic ,assign) int refreshTime;

- (void)showNotify:(NSString *)message;
- (void)showUserMessageView;

@end
