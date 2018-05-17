//
//  ZPARDemoVC_A.m
//  ZPARDemo
//
//  Created by lth on 2018/5/17.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "ZPARDemoVC_A.h"
#import "ZPARMainProjectConfiger.h"
#import "ZPARDemoVC_B.h"
#import "ZPARDemoModel.h"
#import "ZPARMateDataRecorder.h"

@interface ZPARDemoVC_A ()
@property (nonatomic , strong) ZPARDemoModel *model ;
@end

@implementation ZPARDemoVC_A

ZPAR_convinent_synthesize_recordContextDataProvider
ZPAR_convinent_getter_refdesc_current
ZPAR_convinent_getter_pageIsList(return YES;)
ZPAR_convinent_getter_pagecode(return 30000;)
ZPAR_convinent_getter_currentRefObjc
ZPAR_convinent_synthesize_ZPARUIRecorded
//- (NSString *)ZPAR_moduleName
//{
//    return [ZPARMainProjectConfiger moduleName];
//}


- (id<ZPARModelRecorded,ZPARRecordDataProvider>)ZPAR_modelForRecorded
{
    return self.model;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ZPARDemoModel *model = [[ZPARDemoModel alloc] init];
    
    model.Number = @"JSDOASJDOASODNOASMDOASMDSD";
    
    self.model = model;
    
    self.title = NSStringFromClass(self.class);
    self.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
    self.ZPAR_recordPageAction = YES ;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if(![ZPARMateDataRecorder hasRecordedModeOfModel:self.model])
        {
            ZPAR_safeNotifyDataDisplayState(self.model, YES, self.model.moduleName_location);
            [ZPARMateDataRecorder addHasRecordedMode:ZPARDataRecordModeDisplayOnWindow toModel:self.model];
        }else
        {
            [ZPARMateDataRecorder resetRecordedModeToModel:self.model];
        }
    }];
}

- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.navigationController pushViewController:[ZPARDemoVC_B new] animated:YES];
}

@end
