//
//  Util.m
//  PropertyManager
//
//  Created by Roc on 14-8-21.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "Util.h"
#import "TFHpple.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

//extern NSString *CTSettingCopyMyPhoneNumber();

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
    [xmlString appendString:@"<device_id>4</device_id>"];
    [xmlString appendString:@"<serial_object>"];
    for(int i = 0;i < datas.count; i++) {
        NSData *data = [datas objectAtIndex:i];
        NSString *base64String = [data base64EncodedString];
        NSString *name = [NSString stringWithFormat:@"%@/%@/%d.jpg", companyID, [Util stringFromDateForFileName:[NSDate date]], [self getRandomNumber:0 to:500000000] + [self getRandomNumber:0 to:500000000]];
        [filenames appendString:name];
        if (i < datas.count - 1) {
            [filenames appendString:@","];
        }
        [xmlString appendString:@"<Haitao_Upload_File>"];
        [xmlString appendString:@"<serial_version_u_i_d>1</serial_version_u_i_d>"];
        [xmlString appendString:@"<file_size><![CDATA[]]></file_size>"];
        [xmlString appendString:@"<file_type><![CDATA[]]></file_type>"];
        [xmlString appendString:[NSString stringWithFormat:@"<file_str><![CDATA[%@]]></file_str>", base64String]];
        [xmlString appendString:[NSString stringWithFormat:@"<name><![CDATA[%@]]></name>", name]];
        [xmlString appendString:@"<id>0</id>"];
        [xmlString appendString:@"</Haitao_Upload_File>"];
    }
    [xmlString appendString:@"</serial_object>"];
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
    [xmlString appendString:@"<device_id>4</device_id>"];
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
    if([fileManager removeItemAtPath:mp3FilePath error:nil]) {
        
    }
    if ([fileManager removeItemAtPath:cafFilePath error:nil]) {
        
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

+ (NSDictionary *)xmlDataToPushMessage:(NSData *)data
{
    return nil;
}

- (NSString *)locationToXMLString:(NSString *)location lat:(double)lat lon:(double)lon time:(NSString *)time
{
    NSMutableString *xmlString = [NSMutableString stringWithString:@""];
    [xmlString appendString:@"<root>"];
    [xmlString appendString:@"<Serializable_Value_Object>"];
    [xmlString appendString:[NSString stringWithFormat:@"<address><![CDATA[%@]]></address>", location]];
    [xmlString appendString:[NSString stringWithFormat:@"<latitude>%f</latitude>", lat]];
    [xmlString appendString:[NSString stringWithFormat:@"<longitude>%f</longitude>", lon]];
    [xmlString appendString:@"<device_id>4</device_id>"];
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

- (NSString *)deviceInfoToXMLString
{
    NSMutableString *xmlString = [NSMutableString stringWithString:@""];
    UIDevice *device = [[UIDevice alloc] init];
    [xmlString appendString:@"<root>"];
    [xmlString appendString:@"<Serializable_Value_Object>"];
    [xmlString appendString:[NSString stringWithFormat:@"<address><![CDATA[%@]]></address>", self.address]];
    [xmlString appendString:[NSString stringWithFormat:@"<latitude>%f</latitude>", self.lat]];
    [xmlString appendString:[NSString stringWithFormat:@"<longitude>%f</longitude>", self.lon]];
    [xmlString appendString:@"<device_id>4</device_id>"];
    [xmlString appendString:@"<serial_object>"];
    [xmlString appendString:@"<Base_Phone_Parameter>"];
    [xmlString appendString:@"<board><![CDATA[]]></board>"];
    [xmlString appendString:@"<brand><![CDATA[]]></brand>"];
    [xmlString appendString:@"<cpu_abi><![CDATA[]]></cpu_abi>"];
    [xmlString appendString:@"<display><![CDATA[]]></display>"];
    [xmlString appendString:@"<fingerprint><![CDATA[]]></fingerprint>"];
    [xmlString appendString:@"<host><![CDATA[]]></host>"];
    [xmlString appendString:@"<manufacturer><![CDATA[]]></manufacturer>"];
    [xmlString appendString:@"<id><![CDATA[]]></id>"];
    [xmlString appendString:@"<model><![CDATA[]]></model>"];
    
    [xmlString appendString:[NSString stringWithFormat:@"<sdk><![CDATA[%@ %@]]></sdk>", device.systemName, device.systemVersion]];
    [xmlString appendString:[NSString stringWithFormat:@"<network_operator><![CDATA[%@%@]]></network_operator>", [[self getCarrierInfo] mobileCountryCode], [[self getCarrierInfo] mobileNetworkCode]]];
    [xmlString appendString:[NSString stringWithFormat:@"<network_operator_name><![CDATA[%@]]></network_operator_name>", [[self getCarrierInfo] carrierName]]];
    [xmlString appendString:@"<phone_device_id><![CDATA[]]></phone_device_id>"];
    [xmlString appendString:@"<phone_id><![CDATA[]]></phone_id>"];
    [xmlString appendString:@"<imsi><![CDATA[]]></imsi>"];
    [xmlString appendString:@"<line_num><![CDATA[]]></line_num>"];
    [xmlString appendString:[NSString stringWithFormat:@"<device><![CDATA[%@]]></device>", device.platformString]];
    if (self.channelid) {
        [xmlString appendString:[NSString stringWithFormat:@"<channel_id><![CDATA[%@]]></channel_id>", self.channelid]];
    } else {
        [xmlString appendString:@"<channel_id><![CDATA[]]></channel_id>"];
    }
    if (self.userid) {
        [xmlString appendString:[NSString stringWithFormat:@"<user_id><![CDATA[%@]]></user_id>", self.userid]];
    } else {
        [xmlString appendString:@"<user_id><![CDATA[]]></user_id>"];
    }
    if (self.deviceid) {
        [xmlString appendString:[NSString stringWithFormat:@"<device_id><![CDATA[%@]]></device_id>", self.deviceid]];
    } else {
        [xmlString appendString:@"<device_id><![CDATA[]]></device_id>"];
    }
    [xmlString appendString:@"</Base_Phone_Parameter>"];
    [xmlString appendString:@"</serial_object>"];
    [xmlString appendString:@"</Serializable_Value_Object>"];
    [xmlString appendString:@"</root>"];
    return xmlString;
}

- (int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1))); //+1,result is [from to]; else is [from, to)!!!!!!!
}

- (CTCarrier *)getCarrierInfo
{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    return carrier;
}

/*
+ (NSString *)myNumber{
    return CTSettingCopyMyPhoneNumber();
}
 */

+ (NSArray *)runningProcesses {
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;
    
    size_t size;
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    
    do {
        size += size / 10;
        newprocess = realloc(process, size);
        if (!newprocess){
            if (process){
                free(process);
            }
            return nil;
        }
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
    } while (st == -1 && errno == ENOMEM);
    
    if (st == 0){
        if (size % sizeof(struct kinfo_proc) == 0){
            int nprocess = size / sizeof(struct kinfo_proc);
            if (nprocess){
                NSMutableArray * array = [[NSMutableArray alloc] init];
                for (int i = nprocess - 1; i >= 0; i--){
                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];

                    NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, nil]
                                                                        forKeys:[NSArray arrayWithObjects:@"ProcessID", @"ProcessName", nil]];

                    if ([sysProcess containsObject:processName]) {
                        
                    } else {
                        [array addObject:dict];
                    }
                    
                }
                free(process);
                return array;
            }
        }
    }
    
    return nil;
}

- (NSString *)appListToXMLString:(NSArray *)array
{
    NSMutableString *xmlString = [NSMutableString stringWithString:@""];
    [xmlString appendString:@"<root>"];
    [xmlString appendString:@"<Serializable_Value_Object>"];
    [xmlString appendString:@"<serial_version_u_i_d>1</serial_version_u_i_d>"];
    [xmlString appendString:[NSString stringWithFormat:@"<address><![CDATA[%@]]></address>", self.address]];
    [xmlString appendString:[NSString stringWithFormat:@"<latitude>%f</latitude>", self.lat]];
    [xmlString appendString:[NSString stringWithFormat:@"<longitude>%f</longitude>", self.lon]];
    [xmlString appendString:@"<device_id>4</device_id>"];
    [xmlString appendString:@"<serial_object>"];
    for(int i = 0;i < array.count; i++) {
        NSDictionary *dictionary = [array objectAtIndex:i];
        [xmlString appendString:@"<Base_Member_Data_Log>"];
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
        [xmlString appendString:@"<end_time>2000-01-01 09:31:57</end_time>"];
        [xmlString appendString:@"<member_id><![CDATA[]]></member_id>"];
        [xmlString appendString:[NSString stringWithFormat:@"<package_name><![CDATA[%@]]></package_name>", [dictionary objectForKey:@"ProcessName"]]];
        [xmlString appendString:[NSString stringWithFormat:@"<soft_name><![CDATA[%@]]></soft_name>", [dictionary objectForKey:@"ProcessName"]]];
        [xmlString appendString:@"<start_time>2000-01-01 09:31:57</start_time>"];
        [xmlString appendString:@"<user_name><![CDATA[]]></user_name>"];
        [xmlString appendString:@"<user_num><![CDATA[]]></user_num>"];
        [xmlString appendString:@"<uuid><![CDATA[]]></uuid>"];
        [xmlString appendString:@"<id><![CDATA[]]></id>"];
        [xmlString appendString:@"</Base_Member_Data_Log>"];
    }
    [xmlString appendString:@"</serial_object>"];
    [xmlString appendString:@"</Serializable_Value_Object>"];
    [xmlString appendString:@"</root>"];
    return xmlString;
}

@end
