//
//  Util.m
//  PropertyManager
//
//  Created by Roc on 14-8-21.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "Util.h"
#import "TFHpple.h"

extern NSString *CTSettingCopyMyPhoneNumber();

@implementation Util

- (id)initWithAddress:(NSString *)address lat:(double)lat lon:(double)lon channelid:(NSString *)channelid deviceid:(NSString *)deviceid
{
    self = [super init];
    if (self) {
        self.address = address;
        self.lat = lat;
        self.lon = lon;
        self.channelid = channelid;
        self.deviceid = deviceid;
    }
    return self;
}

+ (NSDate*)dateFromString:(NSString*)string
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSDate *date=[formatter dateFromString:string];
    return date;
}

+ (NSString*)stringFromDate:(NSDate *)date hasTime:(BOOL)time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (time) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    } else {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

+ (NSString*)stringFromDateForFileName:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

- (NSMutableArray *)dataToXMLString:(NSArray *)datas companyID:(NSString *)companyID inputID:(NSString *)inputID
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableString *xmlString = [NSMutableString stringWithString:@""];
    NSMutableString *filenames = [NSMutableString stringWithString:@""];
    [xmlString appendString:@"<root>"];
    [xmlString appendString:@"<Serializable_Value_Object>"];
    [xmlString appendString:[NSString stringWithFormat:@"<address><![CDATA[%@]]></address>", self.address]];
    [xmlString appendString:[NSString stringWithFormat:@"<latitude>%f</latitude>", self.lat]];
    [xmlString appendString:[NSString stringWithFormat:@"<longitude>%f</longitude>", self.lon]];
    [xmlString appendString:@"<device_id>1</device_id>"];
    for(int i = 0;i < datas.count; i++) {
        NSData *data = [datas objectAtIndex:i];
        NSString *base64String = [data base64EncodedString];
        NSString *name = [NSString stringWithFormat:@"%@/%@/%d.jpg", companyID, [Util stringFromDateForFileName:[NSDate date]], 123];
        [filenames appendString:name];
        if (i < datas.count - 1) {
            [filenames appendString:@","];
        }
        [xmlString appendString:@"<serial_object>"];
        [xmlString appendString:@"<Haitao_Upload_File>"];
        [xmlString appendString:@"<serial_version_u_i_d>1</serial_version_u_i_d>"];
        [xmlString appendString:@"<file_size><![CDATA[]]></file_size>"];
        [xmlString appendString:@"<file_type><![CDATA[]]></file_type>"];
        [xmlString appendString:[NSString stringWithFormat:@"<file_str><![CDATA[%@]]></file_str>", base64String]];
        [xmlString appendString:[NSString stringWithFormat:@"<name><![CDATA[%@]]></name>", name]];
        [xmlString appendString:@"<id>0</id>"];
        [xmlString appendString:@"</Haitao_Upload_File>"];
        [xmlString appendString:@"</serial_object>"];
    }
    [xmlString appendString:@"</Serializable_Value_Object>"];
    [xmlString appendString:@"</root>"];
    
    [array addObject:xmlString];
    [array addObject:filenames];
    return array;
}

- (NSString *)dataToXMLString:(NSData *)data fileName:(NSString *)filename
{
    NSMutableString *xmlString = [NSMutableString stringWithString:@""];
    [xmlString appendString:@"<root>"];
    [xmlString appendString:@"<Serializable_Value_Object>"];
    [xmlString appendString:[NSString stringWithFormat:@"<address><![CDATA[%@]]></address>", self.address]];
    [xmlString appendString:[NSString stringWithFormat:@"<latitude>%f</latitude>", self.lat]];
    [xmlString appendString:[NSString stringWithFormat:@"<longitude>%f</longitude>", self.lon]];
    [xmlString appendString:@"<device_id>1</device_id>"];
    NSString *base64String = [data base64EncodedString];
    [xmlString appendString:@"<serial_object>"];
    [xmlString appendString:@"<Haitao_Upload_File>"];
    [xmlString appendString:@"<serial_version_u_i_d>1</serial_version_u_i_d>"];
    [xmlString appendString:@"<file_size><![CDATA[]]></file_size>"];
    [xmlString appendString:@"<file_type><![CDATA[]]></file_type>"];
    [xmlString appendString:[NSString stringWithFormat:@"<file_str><![CDATA[%@]]></file_str>", base64String]];
    [xmlString appendString:[NSString stringWithFormat:@"<name><![CDATA[%@]]></name>", filename]];
    [xmlString appendString:@"<id>0</id>"];
    [xmlString appendString:@"</Haitao_Upload_File>"];
    [xmlString appendString:@"</serial_object>"];
    [xmlString appendString:@"</Serializable_Value_Object>"];
    [xmlString appendString:@"</root>"];
    return xmlString;
}

+ (void)deleteOldVoiceFile
{
    NSString *cafFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MySound.caf"];
    
    NSString *mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MySound.mp3"];
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:mp3FilePath error:nil])
    {
        NSLog(@"删除mp3");
    }
    if ([fileManager removeItemAtPath:cafFilePath error:nil]) {
        NSLog(@"删除caf");
    }
}

+ (NSString *)xmlDataToResultCode:(NSData *)data
{
    TFHpple *hpple = [[TFHpple alloc] initWithXMLData:data];
    NSArray *result_message = [hpple searchWithXPathQuery:@"//root/Serializable_Result_Object/result_code"];
    TFHppleElement *resultElement = [result_message objectAtIndex:0];
    NSString *resultString = [[resultElement.children objectAtIndex:0] content];
    return resultString;
}

+ (NSString *)xmlDataToMessage:(NSData *)data
{
    TFHpple *hpple = [[TFHpple alloc] initWithXMLData:data];
    NSArray *result_message = [hpple searchWithXPathQuery:@"//root/Serializable_Result_Object/result_message"];
    TFHppleElement *resultElement = [result_message objectAtIndex:0];
    NSString *resultString = [[resultElement.children objectAtIndex:0] content];
    return resultString;
}

+ (NSString *)xmlDataToFilename:(NSData *)data
{
    TFHpple *hpple = [[TFHpple alloc] initWithXMLData:data];
    NSArray *name = [hpple searchWithXPathQuery:@"//root/Serializable_Result_Object/serial_object/Haitao_Upload_File/name"];
    TFHppleElement *nameElement = [name objectAtIndex:0];
    NSString *nameString = [[nameElement.children objectAtIndex:0] content];
    return nameString;
}

+ (NSString *)myNumber{
    return CTSettingCopyMyPhoneNumber();
}

- (NSString *)locationToXMLString:(NSString *)location lat:(double)lat lon:(double)lon time:(NSString *)time
{
    NSMutableString *xmlString = [NSMutableString stringWithString:@""];
    [xmlString appendString:@"<root>"];
    [xmlString appendString:@"<Serializable_Value_Object>"];
    [xmlString appendString:[NSString stringWithFormat:@"<address><![CDATA[%@]]></address>", location]];
    [xmlString appendString:[NSString stringWithFormat:@"<latitude>%f</latitude>", lat]];
    [xmlString appendString:[NSString stringWithFormat:@"<longitude>%f</longitude>", lon]];
    [xmlString appendString:@"<device_id>1</device_id>"];
    [xmlString appendString:@"<serial_object>"];
    [xmlString appendString:@"<Base_G_P_S_Location>"];
    [xmlString appendString:[NSString stringWithFormat:@"<address><![CDATA[%@]]></address>", location]];
    if (self.channelid) {
        [xmlString appendString:[NSString stringWithFormat:@"<channel_id><![CDATA[%@]]></channel_id>", self.channelid]];
    } else {
        [xmlString appendString:@"<channel_id><![CDATA[]]></channel_id>"];
    }
    if (self.deviceid) {
        [xmlString appendString:[NSString stringWithFormat:@"<device_id><![CDATA[%@]]></device_id>", self.deviceid]];
    } else {
        [xmlString appendString:@"<device_id><![CDATA[]]></device_id>"];
    }
    [xmlString appendString:@"<id><![CDATA[]]></id>"];
    [xmlString appendString:@"<user_num><![CDATA[]]></user_num>"];
    if (self.userid) {
        [xmlString appendString:[NSString stringWithFormat:@"<user_id><![CDATA[%@]]></user_id>", self.userid]];
    } else {
        [xmlString appendString:@"<user_id><![CDATA[]]></user_id>"];
    }
    [xmlString appendString:[NSString stringWithFormat:@"<update_time>%@</update_time>", time]];
    [xmlString appendString:[NSString stringWithFormat:@"<lat>%f</lat>", lat]];
    [xmlString appendString:[NSString stringWithFormat:@"<lon>%f</lon>", lon]];
    [xmlString appendString:@"</Base_G_P_S_Location>"];
    [xmlString appendString:@"</serial_object>"];
    [xmlString appendString:@"</Serializable_Value_Object>"];
    [xmlString appendString:@"</root>"];
    return xmlString;
}

@end
