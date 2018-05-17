//
//  ZPARNetContext.h
//  zhaopin
//
//  Created by lth on 2018/5/3.
//  Copyright © 2018年 zhaopin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 网络接口埋点上报 数据传递的上下文
@interface ZPARNetContext : NSObject

/// 补充参数
@property (nonatomic , strong) NSDictionary *extParamsDict;

/// 选中的数据的索引值
@property (nonatomic , assign) NSInteger selectedPos;

/// 当前是哪个模块
@property (nonatomic , copy ) NSString *moduleName;

/// 是否数据上报的开关
@property (nonatomic , assign) BOOL recordOn;

+ (instancetype)contextWithExtParamsDict:(NSDictionary *)extParamsDict;

@end
