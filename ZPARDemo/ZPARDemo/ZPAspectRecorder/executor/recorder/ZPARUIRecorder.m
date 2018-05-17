//
//  ZPARUIRecorder.m
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/20.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "ZPARUIRecorder.h"

#import "ZPARMarcos.h"
#import <objc/runtime.h>
#import "ZPARModelRecorded.h"
#import "UIView+ZPARRecorderSupport.h"
#import "ZPARRecordGather.h"
#import "ZPARRecord.h"
#import "UIViewController+ZPARRecordSupport.h"
#import "ZPARecorderBaseFuncImp.h"
#import "ZPARStaticDataProviderIMP.h"
#import "ZPARRecordContextManager.h"
#import "ZPARConfiger.h"
#import "NSObject+ZPARModuleNameSupport.h"
/// 防止重复添加observe 或者 没有正确移除observe
/// 用一个model做container 弱引用被观察者
@interface ZPARUIObserverInfo : NSObject

@property (nonatomic , weak) id observerObjc;

+ (instancetype)infoWithObjc:(id)objc;

@end

@implementation ZPARUIObserverInfo
+ (instancetype)infoWithObjc:(id)objc
{
    ZPARUIObserverInfo *info = [[self alloc] init];
    info.observerObjc = objc;
    return info;
}
@end

@interface ZPARUIRecorder()

///  开关某个scrollView 的滑动监听
+ (void)observeScrollViewOffsetDidChange:(UIScrollView *)scrollView startOrStop:(BOOL)startOrStop;
/// 所有被本对象观察的对象及其keypath  key : keypath  value : ZPARUIObserverInfo
@property (nonatomic , strong) NSMutableDictionary *observerMap;

@end

@implementation ZPARUIRecorder

+ (instancetype)shareInstance
{
    static ZPARUIRecorder *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(applicationDidEnterBackgroundNotificationDeal) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(applicationWillEnterForegroundNotificationDeal) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(applicationWillTerminateNotificationDeal) name:UIApplicationWillTerminateNotification object:nil];

    });
    return instance;
}

/// app进入后台 上报指定页面的page out
- (void)applicationDidEnterBackgroundNotificationDeal
{
    [self uplogCurrentPageEvent:ZPARUIRecordModePageOut];
}
/// 用户主动kill app 上报指定页面的page out
- (void)applicationWillTerminateNotificationDeal
{
    [self uplogCurrentPageEvent:ZPARUIRecordModePageOut];
}

/// app回到前台 上报指定页面的page in
- (void)applicationWillEnterForegroundNotificationDeal
{
    [self uplogCurrentPageEvent:ZPARUIRecordModePageIn];
}

/// 处理页面生命周期
+ (void)handleUIRecordWithRecordedEntity:(NSObject<ZPARUIRecorded>*)recordedEntity recordMode:(ZPARUIRecordMode)recordMode
{
    [[self shareInstance] handleUIRecordWithRecordedEntity:recordedEntity
                                                recordMode:recordMode];
}
/// 上报指定模式的page event
- (void)uplogCurrentPageEvent:(ZPARUIRecordMode)recorMode
{
    // 总开关 关闭 不做任何处理
    if (![ZPARConfiger ZPAR_recordOnForModuleName:kZPARConfigerBaseModuleName]) {
        return ;
    }
    
    UIViewController *currentPage = (UIViewController *)[[ZPARRecordContextManager currentContext] ZPAR_currentRefObjc];
    if ([currentPage isKindOfClass:[UIViewController class]] &&
        currentPage.ZPAR_recordPageAction == YES &&
        [currentPage conformsToProtocol:@protocol(ZPARUIRecorded)])
    {
        [self handleUIRecordWithRecordedEntity:(NSObject<ZPARUIRecorded>*)currentPage
                                    recordMode:recorMode];
    }
}

/// 处理页面生命周期
- (void)handleUIRecordWithRecordedEntity:(NSObject<ZPARUIRecorded>*)recordedEntity recordMode:(ZPARUIRecordMode)recordMode
{
    NSString *moduleName = nil ;
    moduleName = [recordedEntity moduleName_location];
    if (moduleName == nil) {
        return ;
    }
    // 总开关 关闭 不做任何处理
    if (![ZPARConfiger ZPAR_recordOnForModuleName:kZPARConfigerBaseModuleName]) {
        return ;
    }
    
    if (![recordedEntity conformsToProtocol:@protocol(ZPARUIRecorded)] ||
        !ZPARUI_checkRecordModeValidity(recordMode)||
        recordMode == ZPARUIRecordModeNone)
    {
        ZPARLog(@"ZPARUIRecorder handleUIRecordWithRecordedEntity failed reason : input params invalid");
        return ;
    }
    
    /// 处理pageIn 事件
    if (ZPARUI_recordModeContain(recordMode, ZPARUIRecordModePageIn))
    {
        id<ZPARModelRecorded,ZPARRecordDataProvider> modelToRecord = nil ;
        if ([recordedEntity respondsToSelector:@selector(ZPAR_modelForRecorded)])
        {
            modelToRecord = [recordedEntity ZPAR_modelForRecorded];
        }
        ZPARRecord *record = [ZPARRecord modelWithRecordDataProvider:modelToRecord
                                                       recordContext:recordedEntity.recordContext
                                                          moduleName:moduleName
                                                               evtid:ZPAR_evtid_pagein];
        [ZPARRecordGather enqueueRecord:record];

    }
    
    /// 处理pageOut 事件
    if (ZPARUI_recordModeContain(recordMode, ZPARUIRecordModePageOut))
    {
        if ([recordedEntity respondsToSelector:@selector(ZPAR_modelForRecorded)])
        {
            id<ZPARModelRecorded,ZPARRecordDataProvider> modelToRecord = nil ;
            if ([recordedEntity respondsToSelector:@selector(ZPAR_modelForRecorded)])
            {
                modelToRecord = [recordedEntity ZPAR_modelForRecorded];
            }
            ZPARRecord *record = [ZPARRecord modelWithRecordDataProvider:modelToRecord
                                                           recordContext:recordedEntity.recordContext
                                                              moduleName:moduleName
                                                                   evtid:ZPAR_evtid_pageout];
            [ZPARRecordGather enqueueRecord:record];
        }
    }    
}

///  开关某个scrollView 的滑动监听
+ (void)observeScrollViewOffsetDidChange:(UIScrollView *)scrollView startOrStop:(BOOL)startOrStop
{
    if (scrollView == nil) {
        return ;
    }
    ZPARUIRecorder *recorder = [ZPARUIRecorder shareInstance];
    NSString *observerKeypath = @"contentOffset";
    
    NSMutableArray<ZPARUIObserverInfo *> *arrM = recorder.observerMap[observerKeypath];
    if (arrM == nil)
    {
        arrM = [NSMutableArray array];
        recorder.observerMap[observerKeypath] = arrM;
    }
    __block ZPARUIObserverInfo *containerInfo = nil;
    [arrM enumerateObjectsUsingBlock:^(ZPARUIObserverInfo * _Nonnull observerInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        if (scrollView == observerInfo.observerObjc) {
            containerInfo = observerInfo ;
            *stop = YES ;
        }
    }];
    
    if (startOrStop && containerInfo == nil)
    {
            [scrollView addObserver:recorder forKeyPath:observerKeypath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
            [arrM addObject:[ZPARUIObserverInfo infoWithObjc:scrollView]];
    }else if (containerInfo != nil)
    {
            [scrollView removeObserver:recorder forKeyPath:observerKeypath];
            [arrM removeObject:containerInfo];
    }
}

- (ZPARUIRecordMode)recorModeOfView:(UIView *)view
{
    NSInteger viewPtr = ZPAR_IntegerPtrForObj(view);
    if (!view) {
        return  ZPARUIRecordModeNone;
    }
    return [self.recordObjectMap[@(viewPtr)] integerValue];
}


- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context
{
    
    // 总开关 关闭 不做任何处理
    if (![ZPARConfiger ZPAR_recordOnForModuleName:kZPARConfigerBaseModuleName]) {
        return ;
    }
    
    if ([object isKindOfClass:[UITableView class]] && [keyPath isEqualToString:@"contentOffset"])
    {
        [self handleRecordTableview:(UITableView *)object];
    }
    
    
    /*
    /// 需求的view 都是tableview  这个功能暂时不用
    /// 非滚动视图 通过监听frame来判断展示/隐藏
     
    if ([keyPath isEqualToString:@"frame"] && [object isKindOfClass:[UIView class]])
    {
        id<ZPARUIRecorded> uiRecordedEntity = (id<ZPARUIRecorded>)view ;
        //   如果view设置了ZPAR_ignoreRecord为yes  代表调用方不希望这个view 被监听 就直接跳过
        if ([uiRecordedEntity respondsToSelector:@selector(ZPAR_ignoreRecord)] &&
            uiRecordedEntity.ZPAR_ignoreRecord) {
        }else
        {
            if ([uiRecordedEntity respondsToSelector:@selector(ZPAR_modelForRecorded)])
            {
                id<ZPARModelRecorded,ZPARDataProvider> modelToRecord = [uiRecordedEntity ZPAR_modelForRecorded];
                // 没有被record过  展示面积又大于1/2  就执行record逻辑
                if (!modelToRecord.ZPAR_hasRecordOn && view.ZPAR_area_ratio_displayOnWindow > 0.5) {
                    if (modelToRecord.ZPAR_dataDisplayedOnWindowCall) {
                        modelToRecord.ZPAR_dataDisplayedOnWindowCall(modelToRecord, YES);
                    }
                    modelToRecord.ZPAR_hasRecordOn = YES;
                }
                /// 被record过  面积小于0.1  执行取消record逻辑
                if ( modelToRecord.ZPAR_hasRecordOn && view.ZPAR_area_ratio_displayOnWindow <= 0.1) {
                    modelToRecord.ZPAR_hasRecordOn = NO;
                }
            }
        }
    }
     */
    
}

/// 处理tableview的 record逻辑
- (void)handleRecordTableview:(UITableView *)tableView
{
    if (![tableView isKindOfClass:[UITableView class]])
    {
        return ;
    }
    
    // 记录tableview 滚动到指定区域的事件
    // 用ZPARRecordContext取数据
    // 只记录在屏幕中的视图
    
    if (tableView.window )
    {
        ZPARRecordContext *context = [ZPARRecordContextManager currentContext];
        /// 这个事件只触发一次 , 这里用一个bool做判定
        if (context && context.hasToBottom == NO)
        {
            // 判断section合法性
            if (context.ZPAR_bottomSection > kZPARRecordContextSectionNone &&
                [tableView numberOfSections] > context.ZPAR_bottomSection)
            {
                // 取出指定section在tableview中的frame
                CGRect frame = [tableView rectForSection:context.ZPAR_bottomSection];
                // section的frame 转换到与tableView.superview相同的坐标系中 , 用于比较
                frame = [tableView convertRect:frame toView:tableView.superview];
//                NSLog(@"bottom frame %@" , NSStringFromCGRect(frame));
                //  section的最大Y轴坐标 比 tableView 的高度小  说明指定section已经全部滑出屏幕
                if (CGRectGetMaxY(frame) <= tableView.bounds.size.height)
                {
                    context.hasToBottom = YES ;
                    // 记录bottom事件
                    if ( [context.ZPAR_currentRefObjc respondsToSelector:@selector(ZPAR_modelForRecorded)])
                    {
                        id<ZPARModelRecorded,ZPARRecordDataProvider> modelToRecord = [(id<ZPARUIRecorded>)context.ZPAR_currentRefObjc ZPAR_modelForRecorded];
                        
                        ZPARRecord *record = [ZPARRecord modelWithRecordDataProvider:modelToRecord
                                                                       recordContext:nil
                                                                          moduleName:context.moduleName
                                                                               evtid:ZPAR_evtid_pvtobottom];
                        
                        [ZPARRecordGather enqueueRecord:record];

                    }
                }
            }
        }
    }
    
    
    /// 取出tableview中 所有可见cell 根据需求 做record
    /// 用view的recorded接口取数据
    NSArray<UITableViewCell *> *cells = [tableView visibleCells];
    [cells enumerateObjectsUsingBlock:^(UITableViewCell * _Nonnull cellView, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSObject<ZPARUIRecorded>* uiRecordedEntity = (NSObject<ZPARUIRecorded>*)cellView ;
        //   如果view设置了ZPAR_ignoreRecord为yes  代表调用方不希望这个view 被监听 就直接跳过
        if ([uiRecordedEntity respondsToSelector:@selector(ZPAR_ignoreRecord)] &&
            uiRecordedEntity.ZPAR_ignoreRecord) {
            return  ;
        }
        if ([uiRecordedEntity respondsToSelector:@selector(ZPAR_modelForRecorded)])
        {
            id<ZPARModelRecorded,ZPARRecordDataProvider> modelToRecord = [uiRecordedEntity ZPAR_modelForRecorded];
            // 没有被record过  展示面积又大于1/2  就执行record逻辑
            NSString *moduleName = nil ;
            moduleName = uiRecordedEntity.moduleName_location;
 
            if (moduleName.length )
            {
                if (!modelToRecord.ZPAR_hasRecordOn && cellView.ZPAR_area_ratio_displayOnWindow > 0.5) {
                    // 上报 模型展示到了屏幕上
                    ZPAR_safeNotifyDataDisplayState(modelToRecord, YES,moduleName);
                    modelToRecord.ZPAR_hasRecordOn = YES;
                }
            }

            /// 被record过  面积小于0.1  执行取消record逻辑
            if ( modelToRecord.ZPAR_hasRecordOn && cellView.ZPAR_area_ratio_displayOnWindow <= 0.1) {
                modelToRecord.ZPAR_hasRecordOn = NO;
            }
        }
    }];
}


/// inputMode 合并到 originMode 中 会进行非法检测 如果非法 就返回originMode
ZPARUIRecordMode ZPARUI_mergeRecordMode(ZPARUIRecordMode originMode , ZPARUIRecordMode inputMode)
{
    //判断inputMode是否合法
    if (!ZPARUI_checkRecordModeValidity(inputMode)) {
        return originMode;
    }
    
    return originMode | inputMode ;
}


- (NSMutableDictionary *)observerMap
{
    if (!_observerMap)
    {
        _observerMap = [NSMutableDictionary dictionary];
    }
    return _observerMap;
}


/// 判断inputMode 是否是一个合法的mode
BOOL ZPARUI_checkRecordModeValidity(ZPARUIRecordMode inputMode)
{
    return ZPARUI_recordModeContain(ZPARUIRecordModeAll, inputMode);
}

/// 判断originMode 是否包含了 inputMode 如果inputMode中包含了originMode没有的mode 就返回NO
BOOL ZPARUI_recordModeContain(ZPARUIRecordMode originMode , ZPARUIRecordMode inputMode)
{
    // 两个mode取交集不为空 并且 originMode的补集与inputMode没有交集  就是originMode全包含inputMode
    return (originMode&inputMode) && !((~originMode)&inputMode);
}

/// 从originMode 中 移除 inputMode
ZPARUIRecordMode ZPARUI_removeMode(ZPARUIRecordMode originMode , ZPARUIRecordMode inputMode)
{
    // originMode 和 inputMode的补集求交集
    return (originMode & (~inputMode)) ;
}


/// 枚举转string  方便调试
NSString *ZPARUI_nameOfRecordMode(ZPARUIRecordMode inputMode)
{
    if (inputMode == ZPARUIRecordModeAll) {
        return @"ZPARUIRecordModeAll";
    }
    
    if (inputMode == ZPARUIRecordModeNone) {
        return @"ZPARUIRecordModeNone";
    }
    
    NSMutableString *string = [NSMutableString string];
    if (inputMode & ZPARUIRecordModePageIn)
    {
        [string appendString:@"ZPARUIRecordModePageIn"];
    }
    
    if (inputMode & ZPARUIRecordModePageOut)
    {
        if (string.length > 0)
        {
            [string appendString:@" | "];
        }
        [string appendString:@"ZPARUIRecordModePageOut"];
    }
    if (inputMode & ZPARUIRecordModeListOffset) {
        if (string.length > 0) {
            [string appendString:@" | "];
        }
        [string appendString:@"ZPARUIRecordModeListOffset"];
    }
    return string.copy;
}

// 进行检索获取Key
+ (BOOL)observerKeyPath:(NSString *)key objc:(NSObject *)obj
{
    id info = obj.observationInfo;
    NSArray *array = [info valueForKey:@"_observances"];
    for (id objc in array)
    {
        id Properties = [objc valueForKeyPath:@"_property"];
        NSString *keyPath = [Properties valueForKeyPath:@"_keyPath"];
        if ([key isEqualToString:keyPath] && [objc valueForKey:@"_observer"] == [ZPARUIRecorder shareInstance]) {
            return YES;
        }
    }
    return NO;
}

@end


@implementation UIScrollView (ZPARUIRecordSupport)

- (void)setZPAR_recordOffsetOn:(BOOL)ZPAR_recordOffsetOn
{
    if (self.ZPAR_recordOffsetOn == ZPAR_recordOffsetOn)
    {
        return ;
    }
    [ZPARUIRecorder observeScrollViewOffsetDidChange:self startOrStop:ZPAR_recordOffsetOn];
    objc_setAssociatedObject(self, @selector(ZPAR_recordOffsetOn), @(ZPAR_recordOffsetOn), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)ZPAR_recordOffsetOn
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end

