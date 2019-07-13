//
//  ContentViewController.h
//  flutter_iOS_gesture_demo
//
//  Created by TonyReet on 2019/7/6.
//  Copyright © 2019 TonyReet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYSideViewController.h"

@interface ContentViewController : UIViewController

@property (nonatomic, assign) CGFloat currentViewOffsetX;

@property (nonatomic, copy) void(^scrollGestureBlock)(CGFloat offsetX,CGFloat velocityX,TYSideState state);

@end

