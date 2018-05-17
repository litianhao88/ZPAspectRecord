//
//  ZPARRecordOutput.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/23.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZPARRecordOutput <NSObject>

@property (nonatomic , copy , readonly) NSString *moduleName;
/// 当前模型转字典 目的是为了上传曝光埋点数据 所以只转换指定字段 子类重写必须要调用父类方法
/// 主参数map
- (NSDictionary *)ZPAR_basicDictDataForExposeUpload;
/// props扩展参数
- (NSDictionary *)ZPAR_propsDictDataForExposeUpload;


@end
