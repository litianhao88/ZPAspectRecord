//
//  NSObject+ZPARModuleNameSupport.h
//  ZPARDemo
//
//  Created by lth on 2018/5/17.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ZPARModuleNameSupport)

/// 当前对象使用者的模块
@property (nonatomic , copy) NSString *moduleName_using;
/// 当前对象的类文件所在模块
@property (nonatomic , copy) NSString *moduleName_location;


@end
