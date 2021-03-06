//
//  RCTLePayModule.m
//  LECValleyUIKit
//
//  Created by RaoJia on 2017/6/6.
//  Copyright © 2017年 LeCloud. All rights reserved.
//

#import "Social.h"

#import "RCTLePayModule.h"

#import "LepaySDK.h"
#import "RCTLePayViewController.h"

@interface RCTLePayModule()<RCTLePayViewControllerDelegate>

@end

static NSString *gAppID = @"";
static NSString *gSecret = @"";

@implementation RCTLePayModule


@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (NSDictionary *)constantsToExport
{
    return @{};
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _autoRegisterAPI];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleOpenURL:)
                                                     name:@"RCTOpenURLNotification"
                                                   object:nil];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)_autoRegisterAPI
{
    if (gAppID.length > 0 ) {
        return;
    }
    
    NSArray *list = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleURLTypes"];
    for (NSDictionary *item in list) {
        NSString *name = item[@"CFBundleURLName"];
        if ([name isEqualToString:@"wx_appid"]) {
            NSArray *schemes = item[@"CFBundleURLSchemes"];
            if (schemes.count > 0){
                gAppID = schemes[0];
                if(![gAppID isEqualToString:@""] && ![gSecret isEqualToString:@""]) break;
            }
        }
    }
}



- (void)handleOpenURL:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    NSString *url = userInfo[@"url"];
    [LepaySDK handleOpenURL:[NSURL URLWithString:url]];
}


#pragma mark 创建viewController
- (RCTLePayViewController*)createPayViewController {
    RCTLePayViewController* payController   = [[RCTLePayViewController alloc] init];
    payController.viewControllerDelegate    = self;
    
    payController.view.contentMode          = UIViewContentModeScaleAspectFit;
    
    return payController;
}

#pragma mark 获取当前屏幕显示的VC
- (UIViewController *)getCurrentViewController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {// 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

RCT_EXPORT_METHOD(doPay:(NSDictionary *)data
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    if (gAppID.length == 0 ) {
        reject(CODE_NOT_REGISTERED, NOT_REGISTERED,nil);
        return;
    }
    
    if (data==nil || [data isKindOfClass:[NSNull class]] || [data count]==0) {
        reject(CODE_INVALID_ARGUMENT,INVALID_ARGUMENT,nil);
        return;
    }
    
    NSMutableDictionary * leTradeInfo = [NSMutableDictionary dictionaryWithCapacity:[data count]];
    for (NSString *key in data) {
        
        if ([key isEqualToString:@"mProductUrls"] || [key isEqualToString:@"mpid"]||
            [key isEqualToString:@"mdeptid"] || [key isEqualToString:@"letv_user_id"])
            continue;
//        NSLog(@"key: %@ value: %@", key, data[key]);
        
        if (data[key] == nil || data[key] == [NSNull null])	{
            [leTradeInfo setValue:@"" forKey:key];
            
        }else if ([data[key] isKindOfClass:[NSString class]]){
            [leTradeInfo setValue:data[key] forKey:key];
            
        }else if ([data[key] isKindOfClass:[NSNumber class]]){
            [leTradeInfo setValue:[data[key] stringValue] forKey:key];
            
        }else{
            [leTradeInfo setValue:data[key] forKey:key];
        }
    }
    
    UIViewController *viewController = [self getCurrentViewController];
    
    [LepaySDK createPayViewController:viewController
                          LeTradeInfo:leTradeInfo
                           fromScheme:gAppID
                             callback:^(LepayResultStatus result, NSString *message) {
                                 
                                 NSLog(@"key: %ld value: %@", (long)result, message);
                                 if (result == LepayResultDefault) {
                                     //默认
                                 }else if (result == LepayResultSuccess) {
                                     //支付成功
                                 }else if (result == LepayResultFail) {
                                     //支付失败
                                 }else if (result == LepayResultProcess) {
                                     //支付结果确认中
                                 }else if (result == LepayResultCancel) {
                                     //支付取消
                                 }else if (result == LepayResultIsPaid) {
                                     //重复支付
                                 }
                                 resolve(message);
                             }];
}


#pragma mark - RCTLePushViewControllerDelegate

- (void)payViewControllerWillDismiss:(UIViewController *)viewController
{
    NSLog(@"previewViewControllerWillDismiss消息");
}

- (void)payViewControllerDidDismiss:(UIViewController *)viewController
{
    NSLog(@"previewViewControllerDidDismiss消息");
}

RCT_EXPORT_METHOD(doPay1:(NSDictionary *)data
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    NSMutableDictionary * leTradeInfo = [NSMutableDictionary dictionary];
    [leTradeInfo setValue:@"27" forKey:@"merchant_business_id"];
    [leTradeInfo setValue:@"143620070" forKey:@"user_id"];
    [leTradeInfo setValue:@"Union" forKey:@"user_name"];
    [leTradeInfo setValue:@"http://trade.letv.com/" forKey:@"notify_url"];
    [leTradeInfo setValue:@"http://trade.letv.com/" forKey:@"call_back_url"];
    [leTradeInfo setValue:@"1311313131" forKey:@"merchant_no"];
    [leTradeInfo setValue:@"272225789"forKey:@"out_trade_no"];
    [leTradeInfo setValue:@"0.01" forKey:@"price"];
    [leTradeInfo setValue:@"CNY" forKey:@"currency"];
    [leTradeInfo setValue:@"60" forKey:@"pay_expire"];
    [leTradeInfo setValue:@"8888" forKey:@"product_id"];
    [leTradeInfo setValue:@"LeTV" forKey:@"product_name"];
    [leTradeInfo setValue:@"TV60" forKey:@"product_desc"];
    //    [leTradeInfo setValue:[self deviceIPAdress] forKey:@"ip”]; //ip地址
    // 以下参数传固定值可以了了
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    [leTradeInfo setValue:currentDateStr forKey:@"timestamp"];
    [leTradeInfo setValue:@"1" forKey:@"key_index"];
    [leTradeInfo setValue:@"UTF-8" forKey:@"input_charset"];
    [leTradeInfo setValue:@"MD5" forKey:@"sign_type"];
    [leTradeInfo setValue:@"2.0" forKey:@"version"];// 支付SDK版本号
    [leTradeInfo setValue:@"lepay.app.api.show.cashier" forKey:@"service"];
    
    //连续包⽉，⽀付宝代扣（⾮必填，不传，就不展示）
    //    [leTradeInfo setValue:@(self.isContinuousmonth) forKey:@"isContinuousmonth"]; //是否是连续包⽉月⽀支付⽅方式 1-是 0-否
    [leTradeInfo setValue:@"http://trade.letv.com/" forKey:@"renew_url"];//如果isContinuousmonth = 1需要传renew_url
    //产品详情传参格式 数组⾥里里可穿多个产品，product_url 产品图⽚片，product_count，该产品购买数量量
    //[{"product_count":"5","product_url":"http:\/\/f.hiphotos.baidu.com\/image\/pic\/item\/91ef76c6a7efce1b687b6bc2ad51f3deb48f6562.jpg"}]
    NSArray *productUrsArray = @[@{@"product_url":@"http://f.hiphotos.baidu.com/image/pic/item/91ef76c6a7efce1b687b6bc2ad51f3deb48f6562.jpg",@"product_count":@"5"}];
    NSData *productUrsJsonData = [NSJSONSerialization dataWithJSONObject:productUrsArray
                                                                 options:NSJSONWritingPrettyPrinted
                                                                   error:nil];
    NSString *productUrsStr = [[NSString alloc] initWithData:productUrsJsonData encoding:NSUTF8StringEncoding];
    productUrsStr =[productUrsStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    productUrsStr =[productUrsStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [leTradeInfo setValue:productUrsStr forKey:@"product_urls"];
    [leTradeInfo setValue:@"为安全保证，需商户服务器器进⾏行行签名，签名秘钥不不暴暴露露给客户端" forKey:@"sign"];
    //微信AppId wx******
    [LepaySDK createPayViewController:self
                          LeTradeInfo:leTradeInfo
                           fromScheme:@"wx**************"
                             callback:^(LepayResultStatus result, NSString *message) {
                                 
                             }];
}

@end
