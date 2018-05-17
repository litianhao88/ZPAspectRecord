//
//  ZPARStaticDataProvider.m
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/23.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "ZPARStaticDataProviderIMP.h"
#import "ZPARMarcos.h"

@interface ZPARStaticDataProviderIMP()

@property (nonatomic , weak) NSObject *dataProvider;

@end

@implementation ZPARStaticDataProviderIMP

+ (instancetype)defaultDataProvider
{
    static ZPARStaticDataProviderIMP *instance ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/// 配置一个真正的数据提供者  由外部调用发进行输入
+ (void)configStaticDataWithDataProvider:(NSObject*)dataProvider;
{
    [[self defaultDataProvider] setDataProvider:dataProvider];
}

// kvc 数据转接到 实际的数据提供者
- (id)valueForUndefinedKey:(NSString *)key
{
    return [self.dataProvider valueForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    [self.dataProvider setValue:value forUndefinedKey:key];
}

@end
