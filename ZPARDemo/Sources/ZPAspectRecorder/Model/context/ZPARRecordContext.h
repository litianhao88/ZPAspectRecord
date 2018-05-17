//
//  ZPARRecorderContext.h
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/24.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPARRecordContextDataProvider.h"

FOUNDATION_EXTERN NSInteger kZPARRecordContextSectionNone;

@interface ZPARRecordContext : NSObject<ZPARRecordContextDataProvider>

/// srccode：来源曝光列表位置编码，搜索结果列表=501901/首页推荐列表=502001
@property (nonatomic , copy) NSString *srccode;

///refdesc：上一页面的完整类名或url
@property (nonatomic , copy) NSString *refdesc;

///ref：搜索结果页=5019/首页推荐页=5020
@property (nonatomic , copy) NSString *ref;
/// 上一页 的context
@property (nonatomic , weak  ) ZPARRecordContext *preContext;
/// context 的所有者对象
@property (nonatomic , weak , readonly) id<ZPARRecordContextDataProvider> ZPAR_currentRefObjc;


/// 当前页面是详情页 会有detailJdno
@property (nonatomic , copy) NSString *detailJdno;

@property (nonatomic , assign) NSTimeInterval pageInTime;
@property (nonatomic , assign) NSTimeInterval pageOutTime;

@property (nonatomic , assign , readonly) NSTimeInterval timeonpage;

/// 当前是哪个模块
@property (nonatomic , copy ) NSString *moduleName;

/// 如果是需要上报底部事件的页面 这个字段记录是否已经上报过
@property (nonatomic , assign) BOOL hasToBottom;

+ (instancetype)contextWithProvider:(id<ZPARRecordContextDataProvider>)provider;
- (instancetype)initWithProvider:(id<ZPARRecordContextDataProvider>)provider;
- (instancetype)init NS_UNAVAILABLE;

/// 当push入栈时 栈管理会掉这个方法 传入栈顶context 配置当前context的一些依赖于上一个contex的信息
- (void)configPropertyWithPreContext:(ZPARRecordContext *)preContext;


@end
