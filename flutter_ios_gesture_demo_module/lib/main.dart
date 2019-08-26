import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in a Flutter IDE). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const MethodChannel _scrollMethodChannel =
      MethodChannel('scrollMethodChannel');

  static String _scrollBeganKey = 'scrollBeganKey';

  static String _scrollUpdateKey = 'scrollUpdateKey';

  static String _scrollEndKey = 'scrollEndKey';

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Column(children: <Widget>[
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
                            style: TextStyle(
                                fontSize: 19,
                                color: Colors.white,
                                fontFamily: "HYYaKuHeiW"),
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
        ]));
  }
}

class RandomColor {
  Color rColor = Color(0xFF000000 + Random().nextInt(0x00FFFFFF));
}
