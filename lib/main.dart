import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Network Alert Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status  error: ${e}');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      if(_connectionStatus == ConnectivityResult.mobile && result == ConnectivityResult.wifi){
        mobileToWifi();
      }else if(_connectionStatus == ConnectivityResult.wifi && result == ConnectivityResult.mobile){
        wifiToMobile();
      }
      _connectionStatus = result;
    });
    switch(result) {
      case ConnectivityResult.wifi: networkTest();
      break;
      case ConnectivityResult.mobile: networkTest();
      break;
      case ConnectivityResult.none: networkOutage();
      break;
    }
  }
  /*******인터넷 속도 측정*****/
  void networkTest() async{
    var r = await fetchPost().timeout(const Duration(seconds: 2));
    if(r.statusCode != 200){
      networkDelay();
    }
  }

  Future<http.Response> fetchPost() {
    Uri url = Uri.parse('data를 받아오는곳');
    return http.get(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('네트워크 상태 : ${_connectionStatus.toString()}'),
            ElevatedButton(onPressed: (){networkOutage();},
                child: const Text('네트워크 끊김')),
            ElevatedButton(onPressed: (){networkDelay();},
                child: const Text('네트워크 지연')),
            ElevatedButton(onPressed: (){mobileToWifi();},
                child: const Text('모바일 --> 와이파이')),
            ElevatedButton(onPressed: (){wifiToMobile();},
                child: const Text('와이파이 --> 모바일')),
          ],
        ),
      ),
    );
  }
  ///Alert
  void networkDelay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SizedBox(
            height: 200,
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:  [
                const Text('네트워크 지연'),
                const Text('네트워크 환경이 불안정합니다.'),
                ElevatedButton(onPressed: ()=> Navigator.pop(context),
                    child: const Text('확인'))
              ],
            ),
          ),
        );
      },
    );
  }
  ///Alert
  void networkOutage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SizedBox(
            height: 200,
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:  [
                const Text('네트워크 끊김'),
                const Text('네트워크를 찾을수 없습니다.'),
                ElevatedButton(onPressed: ()=> Navigator.pop(context),
                    child: const Text('확인'))
              ],
            ),
          ),
        );
      },
    );
  }

  void mobileToWifi() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50))
          ),
          content:  Text('네트워크가 와이파이로 변경되었습니다.'),
          duration:  Duration(seconds: 3),
        )
    );
  }
  void wifiToMobile() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('네트워크가 모바일 데이터로 변경되었습니다.'),
          duration: Duration(seconds: 3),
        )
    );
  }
}
