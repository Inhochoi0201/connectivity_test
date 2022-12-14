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
  /*******????????? ?????? ??????*****/
  void networkTest() async{
    var r = await fetchPost().timeout(const Duration(seconds: 2));
    if(r.statusCode != 200){
      networkDelay();
    }
  }

  Future<http.Response> fetchPost() {
    Uri url = Uri.parse('data??? ???????????????');
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
            Text('???????????? ?????? : ${_connectionStatus.toString()}'),
            ElevatedButton(onPressed: (){networkOutage();},
                child: const Text('???????????? ??????')),
            ElevatedButton(onPressed: (){networkDelay();},
                child: const Text('???????????? ??????')),
            ElevatedButton(onPressed: (){mobileToWifi();},
                child: const Text('????????? --> ????????????')),
            ElevatedButton(onPressed: (){wifiToMobile();},
                child: const Text('???????????? --> ?????????')),
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
                const Text('???????????? ??????'),
                const Text('???????????? ????????? ??????????????????.'),
                ElevatedButton(onPressed: ()=> Navigator.pop(context),
                    child: const Text('??????'))
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
                const Text('???????????? ??????'),
                const Text('??????????????? ????????? ????????????.'),
                ElevatedButton(onPressed: ()=> Navigator.pop(context),
                    child: const Text('??????'))
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
          content:  Text('??????????????? ??????????????? ?????????????????????.'),
          duration:  Duration(seconds: 3),
        )
    );
  }
  void wifiToMobile() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('??????????????? ????????? ???????????? ?????????????????????.'),
          duration: Duration(seconds: 3),
        )
    );
  }
}
