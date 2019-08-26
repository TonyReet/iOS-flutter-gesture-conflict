

#### 文件目录
flutter_iOS_gesture_demo：iOS项目目录
flutter_ios_gesture_demo_module：flutter项目目录

在iOS项目执行pod install 即可运行混合工程，查看手势问题

## 具体问题
iOS和flutter都有手势处理，但是在某些情况下可能产生手势冲突，比如iOS有一个抽屉手势，而flutter有一个水平的滑动手势，这个时候就会产生冲突的问题，具体问题看下面情况。

- iOS抽屉手势
![原生抽屉](https://upload-images.jianshu.io/upload_images/4442351-5c485581324099bb.gif?imageMogr2/auto-orient/strip)

### 1、需求场景
绿色部分为放置flutter的控制器(ContentViewController)，当在屏幕左侧滑动的时候，会划出iOS的抽屉控制器(LeftTableViewController)，并且此抽屉手势也是iOS控制。
iOS抽屉手势的代码网上很多，此处是从项目里面抽出来的，就不再赘述，[代码地址](https://github.com/TonyReet/iOS-flutter-gesture-conflict/blob/master/flutter_iOS_gesture_demo/flutter_iOS_gesture_demo/TYSideViewController.m)


### 2、flutter页面
假设我们flutter页面是有横向滑动的view，需要集成到iOS里面去，如下图:
![flutter页面](https://upload-images.jianshu.io/upload_images/4442351-683f4eaf10222ebf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

flutter页面主要代码:
```
Column(children: <Widget>[
          Container(
              child: ListView.separated(
                itemCount: 10,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    width: 5,
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                      child: Container(
                    margin: EdgeInsets.all(5),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('测试标题:${index}',
                            style: TextStyle(fontSize: 19, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Container(
                          width: 22,
                          height: 2,
                          color: Colors.white,
                        ),
                        Text(
                          '测试内容:${index}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        )
                      ],
                    ),
                    width: 180,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: RandomColor().rColor),
                  ));
                },
              ),
              height: 180),
          Expanded(
              child:Container()
          )
        ]
```

- 最上方是一个横向滑动的listView，我们先明确一个需求，当我们在listView上面滑动的时候，只触发listView的左右滑动效果，当我们不在listView上面滑动的时候，才触发iOS的抽屉手势。

-那么将flutter集成到iOS以后，当我横向滑动listView的时候，是触发listView滑动，还是会触发iOS的抽屉手势呢？

### 3、集成效果
我们将flutter页面集成到iOS项目中，集成方法网上有很多，这里使用[google官方方案]([https://github.com/flutter/flutter/wiki/Add-Flutter-to-existing-apps](https://github.com/flutter/flutter/wiki/Add-Flutter-to-existing-apps)
)

在ContentViewController添加代码：
```
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.flutterViewController = [[FlutterViewController alloc] initWithEngine:appDelegate.flutterEngine nibName:nil bundle:nil];
    
    self.flutterViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.flutterViewController.view];
```

看一下效果:
![首次集成flutter.gif](https://upload-images.jianshu.io/upload_images/4442351-ec2f3e711504ae64.gif?imageMogr2/auto-orient/strip)

我们可以看到，在listView上面从左向右滑动时，大概率会触发iOS的抽屉手势，这和我们的需求不符。
相信大家都知道原因了，这就是iOS的手势优先级高于flutter手势的优先级，所以会触发iOS的抽屉手势。

### 4、解决手势问题
知道原因，解决起来也方便了。这里提供一个方案，当我们的手势在flutter的页面上操作时，由flutter自行判断是否需要触发抽屉的动作，那么在flutter端处理的思路就清晰了。当我们在listView上滑动时候，不需要iOS参与，当我们在flutter其他区域存在手势时，调用iOS原生的触发方法。

流程:
![流程图.png](https://upload-images.jianshu.io/upload_images/4442351-9ba8f96bdc8781d8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


我们判断手势是否在flutter页面上：
```
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    // 若为FlutterView（即点击了flutter），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"FlutterView"]) {
        // 当手势在flutter上，由flutter处理
        NSLog(@"flutterView");
        return NO;
    }

    NSLog(@"native View");
    return  YES;
}
```
iOS和flutter交互使用channel，代码如下:

iOS
```
    FlutterMethodChannel *scrollMethodChannel = [FlutterMethodChannel methodChannelWithName:@"scrollMethodChannel" binaryMessenger:self.flutterViewController];
    
    self.scrollMethodChannel = scrollMethodChannel;
    
    __weak typeof(self) weakSelf = self;
    [self.scrollMethodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        [weakSelf flutterInvokeNativeMethod:call result:result];
    }];
```

flutter

```
  static const MethodChannel _scrollMethodChannel =
      MethodChannel('scrollMethodChannel');

  static String _scrollBeganKey = 'scrollBeganKey';

  static String _scrollUpdateKey = 'scrollUpdateKey';

  static String _scrollEndKey = 'scrollEndKey';
```

flutter端，只需要把非listView的手势通知iOS就行，listView手势不需要处理。那么，只需要处理```Expanded里面的
Container```即可。

```
Column(children: <Widget>[
          Container(
              child: ListView.separated(...),// 将listView代码省略，主要提现container
              height: 180),
          Expanded(
              child: GestureDetector(
            onHorizontalDragStart: (detail) {
              Map<String, dynamic> resInfo = {
                "offsetX": detail.globalPosition.dx,
                "velocityX": detail.globalPosition.dx
              };

              _scrollMethodChannel.invokeMethod(_scrollBeganKey, resInfo);
            },
            onHorizontalDragEnd: (detail) {
              Map<String, dynamic> resInfo = {
                "offsetX": 0,
                "velocityX": detail.primaryVelocity
              };

              _scrollMethodChannel.invokeMethod(_scrollEndKey, resInfo);
            },
            onHorizontalDragUpdate: (detail) {
              Map<String, dynamic> resInfo = {
                "offsetX": detail.globalPosition.dx,
                "velocityX": detail.primaryDelta
              };

              _scrollMethodChannel.invokeMethod(_scrollUpdateKey, resInfo);
            },
            child: Container(color: Colors.yellow),
          ))
        ]
```
看代码其实比较简单，使用```GestureDetector 的onHorizontalDragxxx ```方法监听开始滑动，滑动ing，和滑动结束的动作，并且将嘴硬的坐标和滑动的速度信息等传递给iOS，iOS拿到数据后，进行view的移动处理即可。

iOS拿到数据后的处理方式:
```
// 定义的block:
@property (nonatomic, copy) void(^scrollGestureBlock)(CGFloat offsetX,CGFloat velocityX,TYSideState state);

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
                self.scrollGestureBlock(offsetX, velocityX, TYSideStateUpdate);
            });
        }

    }
    
    /// 结束滑动
    if ([call.method isEqualToString:@"scrollEndKey"]){
        if (self.scrollGestureBlock){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.scrollGestureBlock(0, velocityX, TYSideStateEnded);
            });
        }
    }
}
```

很开心的开始看效果，结果还是有问题，仔细看图，当触发抽屉滑动的时候，边缘有明显的抖动。
![flutter抖动.gif](https://upload-images.jianshu.io/upload_images/4442351-ecf2041cd3e4be7e.gif?imageMogr2/auto-orient/strip)

### 5、抖动处理
查看原因发现，当我们将滑动的消息发送到iOS以后，iOS会修改flutterView的x坐标，比如从0修改到10。但是flutter的手势此时一直没有中断，并且时从0开始计算偏移量，但是iOS修改x坐标以后，偏移量就会有10的误差，这个时候，就想到当iOS修改完x后，将x保存起来。在下次flutter消息到来的时候，加上此偏移量即可。

保存x偏移：
```
    if ([self.rootViewController isKindOfClass:[ContentViewController class]]){
        ContentViewController *vc = (ContentViewController *)self.rootViewController;

        vc.currentViewOffsetX = xoffset;
    }
```

使用x偏移:
```
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
```

效果:
![最后效果.gif](https://upload-images.jianshu.io/upload_images/4442351-ff71c56e1ebe8a1f.gif?imageMogr2/auto-orient/strip)

可以看到，当在ListView上面滑动的时候，listView左右滑动正常，并且没有误触iOS时候，当在flutter下方的非listView区域滑动时，能够触发iOS的抽屉手势，并且没有抖动。

[文章地址:https://www.jianshu.com/p/47729e23b3f3](https://www.jianshu.com/p/47729e23b3f3)
