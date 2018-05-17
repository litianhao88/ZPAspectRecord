//
//  ZPARNetRecorded.h
//  zhaopin
//
//  Created by lth on 2018/4/27.
//  Copyright © 2018年 zhaopin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPARRecordContext.h"
#import "ZPARRecordContextManager.h"
#import "ZPARNetContext.h"
//typedef NS_ENUM(NSInteger , ZPARNetRecordType)
//{
//    ZPARNetRecordTypeNone = 0,
//    /// 单次投递
//    ZPARNetRecordTypeDeliveryResume = 1,
//    /// 批量投递
//    ZPARNetRecordTypeBDeliveryResume = 2,
//    /// 首页推荐获取成功
//    ZPARNetRecordTypeRecommendList = 3,
//    /// 搜索职位列表获取成功
//    ZPARNetRecordTypeSearchList = 4,
//    /// 职位详情 加载成功
//    ZPARNetRecordTypeDetailLoaded = 5
//};

///便捷添加 收集框架预设的property 实例变量
#define ZPAR_convinent_synthesize_ZPARNetRecorded ZPAR_convinent_synthesize(ZPAR_requestContext)\
ZPAR_convinent_synthesize(ZPAR_netContext)

typedef void(^ZPAR_handle_APIRecord_BlockType) (ZPARRecordContext * pageContext,ZPARNetContext *netContext, NSString *requestUrl , NSDictionary *requestParams , NSDictionary *responseDict);

@protocol ZPARNetRecorded <NSObject>

/// 这个方法被hook了 实现者一定不要提供具体实现  
//@property (nonatomic , copy , readonly) ZPAR_handle_APIRecord_BlockType ZPAR_handle_APIRecord;
/// 请求发送时的上下文 用于请求返回后 数据采集
@property (nonatomic , weak) ZPARRecordContext *ZPAR_requestContext;

@property (nonatomic , strong) ZPARNetContext *ZPAR_netContext;
/// 开闭日志收集开关
- (void)ZPAR_switchRecord:(BOOL)recordOn;

@end
