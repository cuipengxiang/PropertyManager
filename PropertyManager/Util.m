//
//  Util.m
//  PropertyManager
//
//  Created by Roc on 14-8-21.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (NSDate*)dateFromString:(NSString*)string
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSDate *date=[formatter dateFromString:string];
    return date;
}

+ (NSString*)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
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

+ (NSString *)dataToXMLString:(NSArray *)datas
{
    NSMutableString *xmlString = [NSMutableString stringWithString:@""];
    [xmlString appendString:@"<root>"];
    [xmlString appendString:@"<Serializable_Value_Object>"];
    [xmlString appendString:@"<address><![CDATA[山东省 烟台市 莱山区 G18荣乌高速 靠近烟台北方星空自控科技有限公司]]></address>"];
    [xmlString appendString:@"<latitude>37.423774</latitude>"];
    [xmlString appendString:@"<longitude>121.5378</longitude>"];
    [xmlString appendString:@"<device_id>1</device_id>"];
    for(NSData *data in datas) {
        NSString *base64String = [data base64EncodedString];
        NSString *name = [NSString stringWithFormat:@"company%@udid%d", [Util stringFromDateForFileName:[NSDate date]], 1];
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
    
    return xmlString;
}



@end
