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
//#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface MainViewController : UIViewController<UIWebViewDelegate, UzysAssetsPickerControllerDelegate, LXActivityDelegate, LXVoiceActivityDelegate, ASIHTTPRequestDelegate>

@property (nonatomic, strong) UIWebView *mainWebView;
@property (nonatomic, strong) NSMutableArray *imagesShowedInSheet;
@property (nonatomic, strong) LCVoice *voice;
@property (nonatomic, strong) NSMutableArray *imagesSelected;
@property (nonatomic, strong) NSMutableArray *imagesDataToUpLoad;
@property (nonatomic, strong) NSString *imageCompanyID;
@property (nonatomic, strong) NSString *imageInputID;

@end
