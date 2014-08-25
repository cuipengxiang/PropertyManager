//
//  LXVoiceActivity.h
//  PropertyManager
//
//  Created by Roc on 14-8-23.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LXVoiceActivity;
@protocol LXVoiceActivityDelegate <NSObject>

@optional

- (void)recordStart;
- (void)recordEnd;
- (void)recordCancel;
- (void)didClickOnSendButton:(LXVoiceActivity *)activity;

@end


@interface LXVoiceActivity : UIView

- (id)initWithTitle:(NSString *)title delegate:(id<LXVoiceActivityDelegate>)delegate;
- (void)showInView:(UIView *)view;
- (void)tappedCancel;

@end
