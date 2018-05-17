//
//  ZPARRecordContextManager.m
//  THAspectLoggerDemo
//
//  Created by lth on 2018/4/24.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "ZPARRecordContextManager.h"
#import <pthread.h>
#import "ZPARRecordHeader.h"

@interface ZPARRecordContextManager()

@property (nonatomic , assign) NSInteger currentSelectTabbarItem;

@property (nonatomic , strong) NSMutableDictionary *pageContextMap;

@end

@implementation ZPARRecordContextManager

- (NSMutableDictionary *)pageContextMap
{
    if (!_pageContextMap) {
        _pageContextMap = [NSMutableDictionary dictionary];
    }
    return _pageContextMap;
}

+ (ZPARRecordContext *)currentContext
{
    ZPARRecordContextManager *contextManager = [self singleManager];
    return contextManager.pageContextMap[@(contextManager.currentSelectTabbarItem)];
}

/// 切换当前控制器context
+ (void)changeRecordContextWithRecordedEntity:(NSObject<ZPARUIRecorded> *)recordedEntity
{
    NSString *moduleName = nil ;
    moduleName = [recordedEntity moduleName_location];

    if ([recordedEntity respondsToSelector:@selector(recordContext)]) {
        ZPARRecordContextManager *contextManager = [self singleManager];
        NSInteger currentTabbarIndex = NSNotFound;
        ZPARRecordContext *currentContext = nil ;
        // 切换当前上下文
        UITabBarController *rootVC = (UITabBarController *)[[[UIApplication sharedApplication].delegate window] rootViewController];
        if ([rootVC isKindOfClass:[UITabBarController class]]) {
            currentTabbarIndex = rootVC.selectedIndex;
        }
        
        currentContext = contextManager.pageContextMap[@(currentTabbarIndex)];

        
        // 为当前实体配置上下文
        if ( recordedEntity.recordContext == nil && [recordedEntity conformsToProtocol:@protocol(ZPARRecordContextDataProvider)])
        {
            ZPARRecordContext *resContext = [ZPARRecordContext contextWithProvider:(id<ZPARRecordContextDataProvider>)recordedEntity];
            [resContext configPropertyWithPreContext:currentContext];
            [recordedEntity setRecordContext:resContext];
        }
//        NSLog(@"更换当前上下文 : %@:%zd<= origin , %@:%zd<= new" , contextManager.pageContextMap[@(contextManager.currentSelectTabbarItem)] , contextManager.currentSelectTabbarItem , recordedEntity.recordContext , currentTabbarIndex);

        // 更换当前上下文
        // 更换当前选中的tabbar索引
        contextManager.currentSelectTabbarItem = currentTabbarIndex;
        contextManager.pageContextMap[@(currentTabbarIndex)] = recordedEntity.recordContext;
        currentContext.moduleName = moduleName;
    }
}


+ (instancetype)singleManager
{
    static ZPARRecordContextManager *instance ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


//
//- (void)singleInit
//{
//    pthread_mutexattr_t attr;
//    pthread_mutexattr_init(&attr);
//    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
//    pthread_mutex_init(&_contextStackSafeLock, &attr);
//    pthread_mutexattr_destroy(&attr);
//}


@end
