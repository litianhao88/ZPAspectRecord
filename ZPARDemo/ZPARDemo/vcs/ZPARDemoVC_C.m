//
//  ZPARDemoVC_C.m
//  ZPARDemo
//
//  Created by lth on 2018/5/17.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "ZPARDemoVC_C.h"
#import "ZPARDemoModel.h"
#import "ZPARMainProjectConfiger.h"
@interface ZPARDemoVC_C ()
@end

@implementation ZPARDemoVC_C

ZPAR_convinent_synthesize_recordContextDataProvider
ZPAR_convinent_synthesize_ZPARUIRecorded
ZPAR_convinent_getter_refdesc_current
ZPAR_convinent_getter_pageIsList(return YES;)
ZPAR_convinent_getter_pagecode(return 30000;)
ZPAR_convinent_getter_currentRefObjc


- (id<ZPARModelRecorded,ZPARRecordDataProvider>)ZPAR_modelForRecorded
{
    ZPARDemoModel *model = [[ZPARDemoModel alloc] init];
    
    model.Number = @"JSDOASJDOASODNOASMDOASMDSD";
    return model;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSStringFromClass(self.class);
    self.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
    self.ZPAR_recordPageAction = YES ;
}



@end
