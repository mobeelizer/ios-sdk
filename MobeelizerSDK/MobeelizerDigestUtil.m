// 
// MobeelizerDigestUtil.m
// 
// Copyright (C) 2012 Mobeelizer Ltd. All Rights Reserved.
//
// Mobeelizer SDK is free software; you can redistribute it and/or modify it 
// under the terms of the GNU Affero General Public License as published by 
// the Free Software Foundation; either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
// for more details.
//
// You should have received a copy of the GNU Affero General Public License 
// along with this program; if not, write to the Free Software Foundation, Inc., 
// 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
// 

#import <CommonCrypto/CommonDigest.h>
#import "MobeelizerDigestUtil.h"

@implementation MobeelizerDigestUtil

+ (NSString *) stringFromSHA256:(NSString *)string {
    
    if(string == nil || [string length] == 0) {
        return nil;
    }
    
    NSData *inputData = [string dataUsingEncoding:NSASCIIStringEncoding];
    uint8_t buffer[CC_SHA256_DIGEST_LENGTH]={0};
    
    CC_SHA256(inputData.bytes, inputData.length, buffer);
    
    NSData *outputData=[NSData dataWithBytes:buffer length:CC_SHA256_DIGEST_LENGTH];
    
    NSString *hash = [outputData description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    return [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
}

+ (NSString *)stringFromMD5:(NSString *)string {
    
    if(string == nil || [string length] == 0) {
        return nil;
    }
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

@end
