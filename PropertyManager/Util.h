//
//  Util.h
//  PropertyManager
//
//  Created by Roc on 14-8-21.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (NSDate*)dateFromString:(NSString*)string;
+ (NSString*)stringFromDate:(NSDate *)date hasTime:(BOOL)time;
+ (NSString*)stringFromDateForFileName:(NSDate *)date;
+ (NSMutableArray *)dataToXMLString:(NSArray *)datas companyID:(NSString *)companyID inputID:(NSString *)inputID;
+ (void)deleteOldVoiceFile;
+ (NSString *)dataToXMLString:(NSData *)data fileName:(NSString *)filename;
+ (NSString *)xmlDataToResultCode:(NSData *)data;
+ (NSString *)xmlDataToFilename:(NSData *)data;
+ (NSString *)xmlDataToMessage:(NSData *)data;

@end
