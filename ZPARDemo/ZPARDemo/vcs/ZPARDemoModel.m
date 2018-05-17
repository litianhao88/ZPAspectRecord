//
//  ZPARDemoModel.m
//  ZPARDemo
//
//  Created by lth on 2018/5/17.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "ZPARDemoModel.h"

@implementation ZPARDemoModel

#pragma mark - ZPAR Protocols IMP
// ZPAR相关接口属性的 便利合成器
ZPAR_convinent_synthesize_ZPARModelRecorded

- (id)ZPAR_valueForKey:(NSString *)key
{
    NSString *resKey = [self ZPAR_keyMap][key];
    if (resKey == nil) {
        resKey = key ;
    }
    
    if (resKey) {
        return [self valueForKey:resKey];
    }
    return [self valueForKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    if (![key hasPrefix:@"ZPAR_"]) {
        return [self valueForUndefinedKey:[NSString stringWithFormat:@"ZPAR_%@",key]];
    }
    return nil;
}

- (NSDictionary *)ZPAR_keyMap
{
    return @{@"jdno" : @"Number"};
}

ZPAR_provide_recordNotifyOnlyOnce(return YES;)

@end
