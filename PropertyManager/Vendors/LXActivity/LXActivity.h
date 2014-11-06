//
//  LXActivity.h
//  LXActivityDemo
//
//  Created by lixiang on 14-3-17.
//  Copyright (c) 2014年 lcolco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LXActivity;
@protocol LXActivityDelegate <NSObject>
- (void)didClickOnImageIndex:(NSInteger *)imageIndex onActivity:(LXActivity *)activity;
@optional
- (void)didClickOnCancelButton;
- (void)didClickOnOtherButton:(LXActivity *)activity;
@end

@interface LXActivity : UIView

- (id)initWithTitle:(NSString *)title delegate:(id<LXActivityDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle ShareButtonTitles:(NSArray *)shareButtonTitlesArray withShareButtonImagesName:(NSArray *)shareButtonImagesNameArray;
- (void)showInView:(UIView *)view;
- (void)tappedCancel;

@property (nonatomic) int maxCount;

@end
