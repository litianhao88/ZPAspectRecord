//
//  NSString+ZPARSupport.m
//  ZPARDemo
//
//  Created by lth on 2018/5/17.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "NSString+ZPARSupport.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (ZPARSupport)

- (NSString *)ZPAR_MD5String
{
    const char* character = [self UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(character, (CC_LONG)strlen(character), result);
    
    NSMutableString *md5String = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [md5String appendFormat:@"%02x",result[i]];
    }
    
    return md5String;
}

@end
