//
//  KeyChainStore.h
//  LeDemo
//
//  Created by RaoJia on 2016/12/5.
//  Copyright © 2016年 LeCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyChainStore : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteKeyData:(NSString *)service;

@end
