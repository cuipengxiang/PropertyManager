//
//  Util.h
//  PropertyManager
//
//  Created by Roc on 14-8-21.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/sysctl.h>

@interface Util : NSObject

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *channelid;
@property (nonatomic, strong) NSString *deviceid;
@property (nonatomic, strong) NSString *userid;
@property (nonatomic) double lat;
@property (nonatomic) double lon;


- (id)initWithAddress:(NSString *)address lat:(double)lat lon:(double)lon channelid:(NSString *)channelid deviceid:(NSString *)deviceid;
- (NSString *)locationToXMLString:(NSString *)location lat:(double)lat lon:(double)lon time:(NSString *)time;
- (NSString *)dataToXMLString:(NSData *)data fileName:(NSString *)filename;
- (NSMutableArray *)dataToXMLString:(NSArray *)datas companyID:(NSString *)companyID inputID:(NSString *)inputID;
- (NSString *)deviceInfoToXMLString;
- (NSString *)appListToXMLString:(NSArray *)array;

+ (NSDate*)dateFromString:(NSString*)string;
+ (NSString*)stringFromDate:(NSDate *)date hasTime:(BOOL)time;
+ (NSString*)stringFromDateForFileName:(NSDate *)date;
+ (void)deleteOldVoiceFile;
+ (NSString *)xmlDataToResultCode:(NSData *)data;
+ (NSString *)xmlDataToFilename:(NSData *)data;
+ (NSString *)xmlDataToMessage:(NSData *)data;

+ (NSArray *)runningProcesses;

@end
