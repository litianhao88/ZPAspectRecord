//
//  ZPARDemoModel.h
//  ZPARDemo
//
//  Created by lth on 2018/5/17.
//  Copyright © 2018年 lth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPARRecordHeader.h"
@interface ZPARDemoModel : NSObject <ZPARModelRecorded , ZPARRecordDataProvider>

@property (nonatomic , copy) NSString *Number;

@end
