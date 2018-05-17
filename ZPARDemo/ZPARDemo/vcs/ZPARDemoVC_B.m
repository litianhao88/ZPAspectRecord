//
//  ZPARDemoVC_B.m
//  ZPARDemo
//
//  Created by lth on 2018/5/17.
//  Copyright © 2018年 lth. All rights reserved.
//

#import "ZPARDemoVC_B.h"
#import "ZPARDemoVC_C.h"

@interface ZPARDemoVC_B ()

@end

@implementation ZPARDemoVC_B

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSStringFromClass(self.class);
    self.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];

    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.navigationController pushViewController:[ZPARDemoVC_C new] animated:YES];
}

@end
