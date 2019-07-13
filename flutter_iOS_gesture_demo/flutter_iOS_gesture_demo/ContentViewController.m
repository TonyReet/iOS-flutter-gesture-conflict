//
//  ContentViewController.m
//  flutter_iOS_gesture_demo
//
//  Created by TonyReet on 2019/7/6.
//  Copyright © 2019 TonyReet. All rights reserved.
//

#import "ContentViewController.h"
#import "AppDelegate.h"

@interface ContentViewController ()

@property (nonatomic, strong) FlutterViewController *flutterViewController;

/// 活动通道
@property (nonatomic, strong) FlutterMethodChannel *scrollMethodChannel;

@end


@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor greenColor];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.flutterViewController = [[FlutterViewController alloc] initWithEngine:appDelegate.flutterEngine nibName:nil bundle:nil];
    
    self.flutterViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.flutterViewController.view];
    
    FlutterMethodChannel *scrollMethodChannel = [FlutterMethodChannel methodChannelWithName:@"scrollMethodChannel" binaryMessenger:self.flutterViewController];
    
    self.scrollMethodChannel = scrollMethodChannel;
    
    __weak typeof(self) weakSelf = self;
    [self.scrollMethodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        [weakSelf flutterInvokeNativeMethod:call result:result];
    }];
}

#pragma mark - flutter调用native
- (void)flutterInvokeNativeMethod:(FlutterMethodCall * _Nonnull )call result:(FlutterResult  _Nonnull )result{

    if (!call.arguments)return;
    
    NSLog(@"测试%@",call.arguments);
    CGFloat offsetX = [call.arguments[@"offsetX"] floatValue];
    CGFloat velocityX = [call.arguments[@"velocityX"] floatValue];

    /// 开始滑动
    if ([call.method isEqualToString:@"scrollBeganKey"]){

        if (self.scrollGestureBlock){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.scrollGestureBlock(0, velocityX, TYSideStateBegan);
            });
        }
    }
    
    /// 滑动更新
    if ([call.method isEqualToString:@"scrollUpdateKey"]){
        
        if (self.scrollGestureBlock){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.scrollGestureBlock(offsetX + self.currentViewOffsetX, velocityX, TYSideStateUpdate);
            });
        }

    }
    
    /// 结束滑动
    if ([call.method isEqualToString:@"scrollEndKey"]){
        if (self.scrollGestureBlock){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.scrollGestureBlock(self.currentViewOffsetX, velocityX, TYSideStateEnded);
            });
        }
    }
}
@end
