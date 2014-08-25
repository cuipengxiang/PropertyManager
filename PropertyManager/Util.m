//
//  Util.m
//  PropertyManager
//
//  Created by Roc on 14-8-21.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "Util.h"
#import "TFHpple.h"

@implementation Util

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

+ (NSMutableArray *)dataToXMLString:(NSArray *)datas companyID:(NSString *)companyID inputID:(NSString *)inputID
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableString *xmlString = [NSMutableString stringWithString:@""];
    NSMutableString *filenames = [NSMutableString stringWithString:@""];
    [xmlString appendString:@"<root>"];
    [xmlString appendString:@"<Serializable_Value_Object>"];
    [xmlString appendString:@"<address><![CDATA[山东省 烟台市 莱山区 G18荣乌高速 靠近烟台北方星空自控科技有限公司]]></address>"];
    [xmlString appendString:@"<latitude>37.423774</latitude>"];
    [xmlString appendString:@"<longitude>121.5378</longitude>"];
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

+ (NSString *)dataToXMLString:(NSData *)data fileName:(NSString *)filename
{
    NSMutableString *xmlString = [NSMutableString stringWithString:@""];
    [xmlString appendString:@"<root>"];
    [xmlString appendString:@"<Serializable_Value_Object>"];
    [xmlString appendString:@"<address><![CDATA[山东省 烟台市 莱山区 G18荣乌高速 靠近烟台北方星空自控科技有限公司]]></address>"];
    [xmlString appendString:@"<latitude>37.423774</latitude>"];
    [xmlString appendString:@"<longitude>121.5378</longitude>"];
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

@end
