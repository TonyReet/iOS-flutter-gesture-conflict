flutter和native混合开发的项目，很多需要共用一套文件，以减小包大小，比如共用图片，字体资源等。图片资源的共用方案很多，但是flutter和native共用字体方案资料比较少。

## iOS实现共用字体
共用资源的方案的话，主要从两方面解决。
#### 1、资源在native，通过某种方式将资源从native传给flutter使用。
这种方案一直没有想到处理的办法，如果知道怎么处理的同学请告知下，谢谢。

#### 2、资源在flutter，通过某种方式将资源从flutter传给native使用。
iOS加载字体有2种方式
a:在工程里面添加字体文件 xxx.otf,yyy.otf,然后在Info.plist添加字段"Fonts provided by application"，并且添加对应的字体，如图:
![123.png]()

b:可以通过动态注册字体的方法加载字体

具体实现:
```
+ (void) loadCustomFont:(NSString*)fontFileName{
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:fontFileName ofType:nil];
    if (!fontPath) {
        NSLog(@"Failed to load font: no fontPath %@", fontFileName);
        return;
    }
    NSData *inData = [NSData dataWithContentsOfFile:fontPath];
    CFErrorRef error;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)inData);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }
    CFRelease(font);
    CFRelease(provider);
}
```

如代码所示，只需要确定font文件的路径即可，问题是怎么获取font文件的路径呢?
经过查找，方法也简单，只需要使用lookupKeyForAsset即可获取到font的文件地址
```
[FlutterDartProject lookupKeyForAsset:@"xxxx"];
```
lookupKeyForAsset的参数是pubspec.yaml配置的font文件地址，加入我们配置的地址是"fonts/iconfont.ttf"

```
  fonts:
     - family: iconfont
       fonts:
         - asset: fonts/iconfont.ttf
```
那么lookupKeyForAsset就是

```
[FlutterDartProject lookupKeyForAsset:@"fonts/iconfont.ttf"];
```

## Android实现共用字体
android比较简单
```
val assetManager = FlutterMain.getLookupKeyForAsset()
val fontKey = flutterView.getLookupKeyForAsset("fonts/iconfont.ttf")
val myTypeface = Typeface.createFromAsset(assetManager, fontKey)
```

如果iOS加载字体的时候报错:
```
Could not register the CGFont '<CGFont (0xxxxxxxxx): YYYYYYY>
```
可以使用FontCreator(Win)或者FontForge(Mac)修改字体信息[/md]