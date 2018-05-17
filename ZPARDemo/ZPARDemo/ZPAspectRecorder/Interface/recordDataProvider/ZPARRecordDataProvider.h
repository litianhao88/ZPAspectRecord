//
//  ZPARRecordDataProvider.h
//  zhaopin
//
//  Created by lth on 2018/5/15.
//  Copyright © 2018年 zhaopin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZPARRecordDataProvider <NSObject>


/// 模块内recorder 通过这个方法 拿到外部需要上报的数据
- (id)ZPAR_valueForKey:(NSString *)key;

/// key值转换映射表 ZPAR_valueForKey 通过这个映射表 获取实现着对象中实际的属性名
- (NSDictionary *)ZPAR_keyMap;

@end
