//
//  ZPARStaticDataProvider.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/23.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 全局静态参数 在这里转接到数据收集模块内  以后有全局静态参数的数据修饰处理的逻辑  可以写在这个类中
@interface ZPARStaticDataProviderIMP : NSObject

+ (instancetype)defaultDataProvider;

/// 配置一个真正的数据提供者  由外部调用发进行输入 因为需要调用一些NSObject的方法 所以这里约束必须是NSObject对象 而不只是id
+ (void)configStaticDataWithDataProvider:(NSObject*)dataProvider;

@end
