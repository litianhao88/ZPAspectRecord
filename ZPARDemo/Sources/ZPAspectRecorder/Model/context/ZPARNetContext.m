//
//  ZPARNetContext.m
//  zhaopin
//
//  Created by lth on 2018/5/3.
//  Copyright © 2018年 zhaopin.com. All rights reserved.
//

#import "ZPARNetContext.h"

@interface ZPARNetContext()

@property (nonatomic , strong) NSMutableDictionary *tmpDict;

@end

@implementation ZPARNetContext

- (NSMutableDictionary *)tmpDict
{
    if (!_tmpDict) {
        _tmpDict = [NSMutableDictionary dictionary];
    }
    return _tmpDict;
}

+ (instancetype)contextWithExtParamsDict:(NSDictionary *)extParamsDict
{
    return [[self alloc] initWithExtParamsDict:extParamsDict];
}

- (instancetype)initWithExtParamsDict:(NSDictionary *)extParamsDict
{
    if (self = [super init])
    {
        self.extParamsDict = extParamsDict ;
        self.selectedPos = NSNotFound;
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if (value && key && [key conformsToProtocol:@protocol(NSCopying)]) {
        [self.tmpDict setObject:value forKey:key];
    }
}


- (id)valueForUndefinedKey:(NSString *)key{
    id resValue = [self.extParamsDict objectForKey:key];
    if (resValue == nil && ![key hasPrefix:@"ZPAR_"]) {
        resValue = self.extParamsDict[[NSString stringWithFormat:@"ZPAR_%@",key]];
    }
    
    if (resValue == nil) {
        resValue = _tmpDict[key];
    }
    if (resValue == nil && ![key hasPrefix:@"ZPAR_"]) {
        resValue = _tmpDict[[NSString stringWithFormat:@"ZPAR_%@",key]];
    }
    
    return resValue;
}



@end
