//
//  OrientationModule.m
//  DemoProject
//
//  Created by RaoJia on 2016/12/11.
//  Copyright © 2016年 LeCloud. All rights reserved.
//

#import "OrientationModule.h"


@implementation OrientationModule
@synthesize bridge = _bridge;

static UIInterfaceOrientationMask _orientation = UIInterfaceOrientationMaskAllButUpsideDown;
+ (void)setOrientation: (UIInterfaceOrientationMask)orientation {
  _orientation = orientation;
}
+ (UIInterfaceOrientationMask)getOrientation {
  return _orientation;
}

- (instancetype)init
{
  if ((self = [super init])) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
  }
  return self;
  
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"onOrientationDidChange"];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
 
  if(orientation != UIDeviceOrientationPortrait
     && orientation != UIDeviceOrientationPortraitUpsideDown
     && orientation != UIDeviceOrientationLandscapeLeft
     && orientation != UIDeviceOrientationLandscapeRight) return;
  
  int orientationInt = [self getOrientationInt:orientation];
  NSString* orientationStr = [self getOrientationStr:orientation];
  
  [self sendEventWithName:@"onOrientationDidChange"
                     body:@{@"orientation": [NSNumber numberWithInt:orientationInt],
                            @"orientationStr": orientationStr}];
  
#if DEBUG
  NSLog(@"设备转屏事件——— orientation：%d 描述: %@", orientationInt, orientationStr);
#endif
  
}

- (NSString *)getOrientationStr: (UIDeviceOrientation)orientation {
  NSString *orientationStr;
  switch (orientation) {
    case UIDeviceOrientationPortrait:
      orientationStr = @"PORTRAIT";
      break;
      
    case UIDeviceOrientationLandscapeLeft:
      orientationStr = @"LANDSCAPE-LEFT";
      break;
      
    case UIDeviceOrientationLandscapeRight:
      orientationStr = @"LANDSCAPE-RIGHT";
      break;
      
    case UIDeviceOrientationPortraitUpsideDown:
      orientationStr = @"PORTRAITUPSIDEDOWN";
      break;
      
    default:
      orientationStr = @"UNKNOWN";
      break;
  }
  return orientationStr;
}


- (int)getOrientationInt: (UIDeviceOrientation)orientation {
  int orientationInt;
  switch (orientation) {
    case UIDeviceOrientationPortrait:
      orientationInt = 1;
      break;
      
    case UIDeviceOrientationLandscapeLeft:
      orientationInt = 0;
      break;
      
    case UIDeviceOrientationLandscapeRight:
      orientationInt = 8;
      break;
      
    case UIDeviceOrientationPortraitUpsideDown:
      orientationInt = 9;
      break;
    default:
      orientationInt = 1;
      
  }
  return orientationInt;
}


RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(getOrientation:(RCTResponseSenderBlock)callback)
{
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getOrientationStr:orientation];
  callback(@[[NSNull null], orientationStr]);
}


RCT_EXPORT_METHOD(setOrientation:(int)requestedOrientation)
{
#if DEBUG
  NSLog(@"外部控制——— 设置方向 orientation: %d", requestedOrientation);
#endif
  switch (requestedOrientation) {
    case 1:
      [OrientationModule setOrientation:UIInterfaceOrientationMaskPortrait];
      [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
      }];
      break;
      
    case 0:
      [OrientationModule setOrientation:UIInterfaceOrientationMaskLandscapeLeft];
      [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
      }];
      break;
      
    case 8:
      [OrientationModule setOrientation:UIInterfaceOrientationMaskLandscapeRight];
      [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        // this seems counter intuitive
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
      }];
      break;
      
    case 9:
      [OrientationModule setOrientation:UIInterfaceOrientationMaskPortraitUpsideDown];
      [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationMaskPortraitUpsideDown] forKey:@"orientation"];
      }];
      break;
      
    default:
      [OrientationModule setOrientation:UIInterfaceOrientationMaskAllButUpsideDown];
      //  AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
      //  delegate.orientation = 3;
      break;
  }
}

- (NSDictionary *)constantsToExport
{
  
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getOrientationStr:orientation];
  
  return @{@"initialOrientation": orientationStr};
}


@end
