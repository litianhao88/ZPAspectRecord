//
//  ZPARRecorderContext.m
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/24.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "ZPARRecordContext.h"
#import "ZPARMacTime.h"

NSInteger kZPARRecordContextSectionNone = -1 ;

@interface ZPARRecordContext()
/// 接口中要求只有getter 但是本类是最终的实体 需要有setter和实例变量
/// 当前context 所引用的 provider 有一些动态属性 需要实时回调获取
@property (nonatomic , weak , readwrite) id<ZPARRecordContextDataProvider> ZPAR_currentRefObjc;
/// 当前页面编码
@property (nonatomic , assign , readwrite) NSInteger ZPAR_pagecode;
///当前页面的完整类名或url
@property (nonatomic , copy, readwrite) NSString *ZPAR_refdesc_current;
/// 当前页面是否是列表页
@property (nonatomic , assign,readwrite) BOOL ZPAR_pageIsList;

@end

@implementation ZPARRecordContext

ZPAR_convinent_synthesize_recordContextDataProvider

+ (instancetype)contextWithProvider:(id<ZPARRecordContextDataProvider>)provider
{
    return [[self alloc] initWithProvider:provider];
}

- (instancetype)initWithProvider:(id<ZPARRecordContextDataProvider>)provider
{
    if (self = [super init])
    {
        self.ZPAR_currentRefObjc = provider.ZPAR_currentRefObjc;
        self.ZPAR_actionid = provider.ZPAR_actionid;
        self.ZPAR_refdesc_current = provider.ZPAR_refdesc_current;
        self.ZPAR_pagecode = provider.ZPAR_pagecode;
        self.ZPAR_pageIsList = provider.ZPAR_pageIsList;
        self.ZPAR_detailJdno = provider.ZPAR_detailJdno;
        if ([self.ZPAR_currentRefObjc isKindOfClass:[NSObject class]] &&
            [self.ZPAR_currentRefObjc respondsToSelector:@selector(ZPAR_actionid)])
        {
            [(NSObject *)self.ZPAR_currentRefObjc addObserver:self forKeyPath:@"ZPAR_actionid" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
        }
        self.ZPAR_selectPos = NSNotFound;
    }
    return self;
}

- (NSInteger)ZPAR_bottomSection
{
    /// 监测列表是否滚动到指定section时 用到的参照section  当前页面可能根据列表加载情况 变动这个值
    if ([self.ZPAR_currentRefObjc respondsToSelector:@selector(ZPAR_bottomSection)]) {
        return self.ZPAR_currentRefObjc.ZPAR_bottomSection;
    }
    return kZPARRecordContextSectionNone;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context
{
    if ([keyPath isEqualToString:@"ZPAR_actionid"] && object == self.ZPAR_currentRefObjc) {
        self.ZPAR_actionid = self.ZPAR_currentRefObjc.ZPAR_actionid;
    }
}

- (void)dealloc
{
    if ([self.ZPAR_currentRefObjc isKindOfClass:[NSObject class]] &&
        [self.ZPAR_currentRefObjc respondsToSelector:@selector(ZPAR_actionid)])
    {
        [(NSObject *)self.ZPAR_currentRefObjc removeObserver:self forKeyPath:@"ZPAR_actionid"];
    }
}

- (void)configPropertyWithPreContext:(ZPARRecordContext *)preContext
{
    self.preContext = preContext ;
    /// 入参是空 说明当前context是栈底context 配置一些默认值  暂时没有要配置的 如果有 写在括号里
    if (preContext == nil)
    {
        return ;
    }
    ///ref：搜索结果页=5019/首页推荐页=5020
    /// srccode：来源曝光列表位置编码，搜索结果列表=501901/首页推荐列表=502001
    ///refdesc：上一页面的完整类名或url

     /// 上一页是weex页面
    if (preContext.ZPAR_weexJumpInfo.count > 0)
    {
        /*
         vc.positionGUID = dic[@"guid"];
         vc.configSerialId = dic[@"configSerialId"];
         vc.moduleName = dic[@"moduleName"];
         NSString *number = dic[@"order"];
         */
        NSDictionary *jumpInfo = preContext.ZPAR_weexJumpInfo ;
        /// 上页面 actionid
        self.ZPAR_actionid = jumpInfo[@"guid"];
        /// 上页面pagecode
        NSInteger pageCode_pre = [jumpInfo[@"pagecode"] integerValue];
        if (pageCode_pre == 0) {
            pageCode_pre = 5020 ;
        }
        // 上页面选中的index
        NSInteger selectPos_pre = [jumpInfo[@"order"] integerValue];
        self.srccode = [NSString stringWithFormat:@"%zd%02zd",pageCode_pre , selectPos_pre];
        self.ref = [NSString stringWithFormat:@"%zd" , pageCode_pre];
    }else
    {
        /// 上一页是native页面
        if (preContext.ZPAR_pageIsList)
        {
            /// 上一页是列表  当前页 srccode 要拼接
            self.srccode = [NSString stringWithFormat:@"%04zd01",preContext.ZPAR_pagecode] ;
        }else
        {
            self.srccode = @"";
        }
        
        /// 上一页的pagecode
        self.ref =  [NSString stringWithFormat:@"%zd" , preContext.ZPAR_pagecode];
        
        if ([self.ZPAR_currentRefObjc isKindOfClass:[preContext.ZPAR_currentRefObjc class]]) {
            self.ZPAR_actionid = [NSUUID UUID].UUIDString;
        }else
        {
            if (preContext.ZPAR_currentRefObjc.ZPAR_actionid)
            {
                self.ZPAR_actionid = preContext.ZPAR_currentRefObjc.ZPAR_actionid ;
            }else if (preContext.ZPAR_actionid)
            {
                self.ZPAR_actionid = preContext.ZPAR_actionid ;
            }else
            {
                self.ZPAR_actionid = nil ;
            }
        }
    }
    self.refdesc = preContext.ZPAR_refdesc_current;
}

- (NSString *)ZPAR_actionid
{
    if ([self.ZPAR_currentRefObjc respondsToSelector:@selector(ZPAR_actionid)]) {
        if ([self.ZPAR_currentRefObjc ZPAR_actionid]) {
            return [self.ZPAR_currentRefObjc ZPAR_actionid];
        }
    }
    return _ZPAR_actionid;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ : pageCode : %zd , pageObject : %@ pageRef : %@ ,------------\n %@ prePageContext\n--------------",self.class , self.ZPAR_pagecode , self.ZPAR_currentRefObjc , self.ZPAR_refdesc_current , self.preContext];
}

- (NSTimeInterval)timeonpage
{
    return [ZPARMacTime durationSecondTimeWithStart:_pageInTime endTime:_pageOutTime];
}

- (NSInteger)ZPAR_selectPos
{
    // 上个页面是weex页面
    if (_preContext.ZPAR_weexJumpInfo.count > 0)
    {
        if (_preContext.ZPAR_weexJumpInfo[@"order"]) {
            return [_preContext.ZPAR_weexJumpInfo[@"order"] integerValue];
        }
    }
    return _ZPAR_selectPos;
}

- (id)valueForUndefinedKey:(NSString *)key{return nil;}
@end
