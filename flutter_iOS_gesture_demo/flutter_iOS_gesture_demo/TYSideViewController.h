//
//  TYSideViewController.h
//  flutter_iOS_gesture_demo
//
//  Created by TonyReet on 2019/7/6.
//  Copyright © 2019 TonyReet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TYSideState) {
    TYSideStateNone,
    TYSideStateBegan,
    TYSideStateUpdate,
    TYSideStateEnded,
};

typedef void(^RootViewMoveBlock)(UIView *rootView,CGRect orginFrame,CGFloat xoffset);

@interface TYSideViewController : UIViewController
@property (assign, nonatomic) BOOL needSwipeShowMenu;//是否开启手势滑动出菜单

@property (strong, nonatomic) UIViewController *rootViewController;
@property (strong, nonatomic) UIViewController *leftViewController;

@property (assign, nonatomic) CGFloat leftViewShowWidth;//左侧栏的展示大小
@property (assign, nonatomic) NSTimeInterval animationDuration;//动画时长
@property (assign, nonatomic) BOOL showBoundsShadow;//是否显示边框阴影
@property (copy, nonatomic) RootViewMoveBlock rootViewMoveBlock;//可在此block中重做动画效果
- (void)setRootViewMoveBlock:(RootViewMoveBlock)rootViewMoveBlock;

- (void)showLeftViewController:(BOOL)animated;//展示左边栏

- (void)hideSideViewController:(BOOL)animated;//恢复正常位置

- (void)willShowLeftViewController;

- (void)pan:(UIPanGestureRecognizer*)pan;

- (instancetype)initWithContentViewController:(UIViewController *)contentVC leftViewController:(UIViewController *)leftVC;
@end

@interface UIViewController (DASideViewController)

- (TYSideViewController *)sideViewController;

@end






