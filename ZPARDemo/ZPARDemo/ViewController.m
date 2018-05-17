//
//  ViewController.m
//  ZPARDemo
//
//  Created by lth on 2018/5/17.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "ViewController.h"
#import "ZPARDemoVC_A.h"
#import "ZPARMainProjectConfiger.h"
#import "ZPARDemoModel.h"

@interface ViewController ()

@end

@implementation ViewController
ZPAR_convinent_synthesize_recordContextDataProvider
ZPAR_convinent_synthesize_ZPARUIRecorded

ZPAR_convinent_getter_refdesc_current
ZPAR_convinent_getter_pageIsList(return YES;)
ZPAR_convinent_getter_pagecode(return 80000;)
ZPAR_convinent_getter_currentRefObjc

- (id<ZPARModelRecorded,ZPARRecordDataProvider>)ZPAR_modelForRecorded
{
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/2.0 - 15, self.view.bounds.size.width, 30)];
    [self.view addSubview:lbl];
    lbl.text = @"touch to start";
    [self.view addSubview:lbl];
    lbl.textAlignment = NSTextAlignmentCenter;

    self.ZPAR_actionid =  @"8181818181818";

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[ZPARDemoVC_A new]];
    [self presentViewController:nav animated:YES completion:nil];
}
@end
