//
//  TYSideViewController.h
//  flutterself.iOSself.gestureself.demo
//
//  Created by TonyReet on 2019/7/6.
//  Copyright © 2019 TonyReet. All rights reserved.
//

#import "TYSideViewController.h"
#import "ContentViewController.h"

#define  kScreenWidth ([[UIScreen mainScreen]bounds].size.width)
#define  kScreenHeight ([[UIScreen mainScreen]bounds].size.height)

@interface TYSideViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *baseView;//目前是self.baseView

@property (nonatomic, strong) UIView *currentView;//其实就是rootViewController.view


@property (nonatomic, strong) UIView *leftView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, assign) CGPoint startPanPoint;

@property (nonatomic, assign) CGPoint lastPanPoint;

@property (nonatomic, strong) UIButton *coverButton;

@property (nonatomic, strong) UIView *shawdowView;

@property (nonatomic, assign) BOOL panMovingLeft;

@end

@implementation TYSideViewController

-(instancetype)initWithContentViewController:(UIViewController *)contentVC leftViewController:(UIViewController *)leftVC {
    if (self = [super init]) {
        
        self.rootViewController = contentVC;
        self.leftViewController = leftVC;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseView = self.view;
    [self.baseView setBackgroundColor:[UIColor whiteColor]];
    
    self.animationDuration = 0.35;
    self.showBoundsShadow = YES;
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self.panGestureRecognizer setDelegate:self];
    
    self.panMovingLeft = NO;
    self.lastPanPoint = CGPointZero;
    
    self.coverButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.coverButton.backgroundColor = [UIColor blackColor];
    [self.coverButton addTarget:self action:@selector(hideSideViewController) forControlEvents:UIControlEventTouchUpInside];
    self.shawdowView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, kScreenHeight)];

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, 10, kScreenHeight);
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.08].CGColor,(id)[UIColor blackColor].CGColor,nil];
    gradient.startPoint = CGPointMake(0, 0.5);
    gradient.endPoint = CGPointMake(1, 0.5);
    gradient.rasterizationScale = [UIScreen mainScreen].scale;
    gradient.shouldRasterize = YES;
    [self.shawdowView.layer addSublayer:gradient];
    self.needSwipeShowMenu = YES;
    
    if ([self.rootViewController isKindOfClass:[ContentViewController class]]){
        ContentViewController *vc = (ContentViewController *)self.rootViewController;

        __weak typeof(self) weakSelf = self;
        vc.scrollGestureBlock = ^(CGFloat offsetX, CGFloat velocityX, TYSideState state) {
            [weakSelf panWithX:offsetX velocityX:velocityX state:state];
        };
    }
}




- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.rootViewController) {
        NSAssert(false, @"you must set rootViewController!!");
    }
    if (self.currentView!=self.rootViewController.view) {
        [self.currentView removeFromSuperview];
        self.currentView=self.rootViewController.view;
        [self.baseView addSubview:self.currentView];
        self.currentView.frame=self.baseView.bounds;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRootViewController:(UIViewController *)rootViewController{
    if (_rootViewController!=rootViewController) {
        if (_rootViewController) {
            [_rootViewController removeFromParentViewController];
        }
        _rootViewController = rootViewController;
        if (_rootViewController) {
            [self addChildViewController:_rootViewController];
        }
    }
}
-(void)setLeftViewController:(UIViewController *)leftViewController{
    if (_leftViewController != leftViewController) {
        if (_leftViewController) {
            [_leftViewController removeFromParentViewController];
        }
        _leftViewController = leftViewController;
        if (_leftViewController) {
            [self addChildViewController:_leftViewController];
        }
    }
}

- (void)setNeedSwipeShowMenu:(BOOL)needSwipeShowMenu{
    _needSwipeShowMenu = needSwipeShowMenu;
    if (_needSwipeShowMenu) {
        [self.baseView addGestureRecognizer:self.panGestureRecognizer];
    }else{
        [self.baseView removeGestureRecognizer:self.panGestureRecognizer];
    }
}

#pragma mark  ShowOrHideTheView
- (void)willShowLeftViewController{
    
    if (!self.leftViewController || self.leftViewController.view.superview) {
        return;
    }
//    self.leftViewController.view.frame=self.baseView.bounds;
    [self.currentView addSubview:self.coverButton];
    [self.currentView addSubview:self.shawdowView];
    self.coverButton.alpha = 0;
    self.leftViewController.view.frame = CGRectMake(-self.leftViewShowWidth *2.0/3, 0, kScreenWidth, kScreenHeight);
    [self.baseView insertSubview:self.leftViewController.view belowSubview:self.currentView];
    
}

- (void)showLeftViewController:(BOOL)animated{
    if (!self.leftViewController) {
        return;
    }
    [self willShowLeftViewController];
    NSTimeInterval animatedTime=0;
    if (animated) {
        animatedTime = ABS(self.leftViewShowWidth - self.currentView.frame.origin.x) / self.leftViewShowWidth * self.animationDuration;
    }
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:animatedTime animations:^{
        [self layoutCurrentViewWithOffset:self.leftViewShowWidth];
        
    }completion:^(BOOL finished) {
        
    }];
}

- (void)hideSideViewController:(BOOL)animated{
    if (!self.shawdowView.superview) {
        return;
    }
    
    NSTimeInterval animatedTime = 0;
    if (animated) {
        animatedTime = ABS(self.currentView.frame.origin.x / self.leftViewShowWidth) * self.animationDuration;
    }
    [self.shawdowView removeFromSuperview];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:animatedTime animations:^{
        self.coverButton.alpha = 0;
        [self layoutCurrentViewWithOffset:0];
    } completion:^(BOOL finished) {
        [self.coverButton removeFromSuperview];
        [self.leftViewController.view removeFromSuperview];
        //        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }];
    
    
}
- (void)hideSideViewController{
    [self hideSideViewController:true];
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // Check for horizontal pan gesture
    if (gestureRecognizer == self.panGestureRecognizer) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint translation = [panGesture translationInView:self.baseView];
        if ([panGesture velocityInView:self.baseView].x < 600 && ABS(translation.x)/ABS(translation.y)>1) {

            return YES;
        }

        return NO;
    }

    return YES;
}

- (void)pan:(UIPanGestureRecognizer*)pan{
    CGPoint velocity = [pan velocityInView:self.baseView];
    
    if (self.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self panWithX:0 velocityX:velocity.x state:TYSideStateBegan];
        return;
    }

    CGPoint currentPostion = [pan translationInView:self.baseView];
    CGFloat xoffset = self.startPanPoint.x + currentPostion.x;
    
    TYSideState state = TYSideStateNone;
    state = self.panGestureRecognizer.state == UIGestureRecognizerStateEnded ? TYSideStateEnded : TYSideStateUpdate;
    [self panWithX:xoffset velocityX:velocity.x state:state];
}

- (void)panWithX:(CGFloat )offsetX velocityX:(CGFloat)velocityX state:(TYSideState )state{
    if (state == TYSideStateBegan) {
        self.startPanPoint = self.currentView.frame.origin;
    
        if(velocityX > 0){
            if (self.currentView.frame.origin.x >= 0 && self.leftViewController && !self.leftViewController.view.superview) {
                NSLog(@"willShowLeftViewController");
                [self willShowLeftViewController];
            }
        }
        NSLog(@"开始滑动:%@,vX:%@",@(offsetX),@(velocityX));
        return;
    }
    
    NSLog(@"更新滑动:%@,vX:%@",@(offsetX),@(velocityX));
    if (offsetX > 0) {//向右滑
        if (self.leftViewController && self.leftViewController.view.superview) {
            offsetX = offsetX > self.leftViewShowWidth?self.leftViewShowWidth:offsetX;
        }else{
            offsetX = 0;
        }
    }else {
        offsetX = 0;
    }
    
    NSLog(@"滑动offsetX:%@,self.currentView.frame.origin.x:%@",@(offsetX),@(self.currentView.frame.origin.x));
    if (offsetX != self.currentView.frame.origin.x) {
        [self layoutCurrentViewWithOffset:offsetX];
    }
    
    
    if (state == TYSideStateEnded) {
        NSLog(@"结束滑动:%@,vX:%@,self.currentView.frame.origin.x:%@",@(offsetX),@(velocityX),@(self.currentView.frame.origin.x));
        if(self.currentView.frame.origin.x>100)
        {
            [self.currentView addSubview:self.coverButton];
        }
        
        if (self.currentView.frame.origin.x!=0 && self.currentView.frame.origin.x!=self.leftViewShowWidth) {
            [self.currentView addSubview:self.coverButton];
            
            if (self.panMovingLeft && self.currentView.frame.origin.x>100) {
                [self showLeftViewController:true];
            }else{
                [self hideSideViewController];
            }
        }else if (self.currentView.frame.origin.x==0) {
            if (self.coverButton.superview) {
                [self hideSideViewController];
            }
        }
        self.lastPanPoint = CGPointZero;
    }else{
        if (velocityX > 0) {
            self.panMovingLeft = true;
        }else if(velocityX < 0){
            self.panMovingLeft = false;
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    // 若为FlutterView（即点击了flutter），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"FlutterView"]) {
        NSLog(@"手势来了:NO");
        return NO;
    }

    NSLog(@"手势来了:YES");
    return  YES;
}

//重写此方法可以改变动画效果,PS.self.currentView就是RootViewController.view
- (void)layoutCurrentViewWithOffset:(CGFloat)xoffset{
    if (self.showBoundsShadow) {
        self.currentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.currentView.bounds].CGPath;
    }
    if (self.rootViewMoveBlock) {//如果有自定义动画，使用自定义的效果
        self.rootViewMoveBlock(self.currentView,self.baseView.bounds,xoffset);
        return;
    }
    ///*平移的动画
    self.coverButton.alpha = xoffset/self.leftViewShowWidth/2 < 0.35 ? xoffset/self.leftViewShowWidth/2 : 0.35 ;
     [self.currentView setFrame:CGRectMake(xoffset, self.baseView.bounds.origin.y, self.baseView.frame.size.width, self.baseView.frame.size.height)];
    self.leftViewController.view.frame = CGRectMake(-self.leftViewShowWidth * 2.0/3.0 + xoffset *2.0/3, self.baseView.bounds.origin.y, self.baseView.frame.size.width, self.baseView.frame.size.height);
    
    if ([self.rootViewController isKindOfClass:[ContentViewController class]]){
        ContentViewController *vc = (ContentViewController *)self.rootViewController;

        vc.currentViewOffsetX = xoffset;
    }
    
     return;
}

@end

@implementation UIViewController (DASideViewController)

- (TYSideViewController *)sideViewController {
    UIViewController *parent = self;
    Class sideClass = [TYSideViewController class];
    while ( nil != (parent = [parent parentViewController]) && ![parent isKindOfClass:sideClass] ) {}
    return (id)parent;
}

@end



