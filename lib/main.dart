import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFF050810)),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _startApp = StartAppSdk();
  StartAppBannerAd? _bannerAd;
  StartAppInterstitialAd? _interstitialAd;

  int _seconds = 5;
  bool _timerRunning = false;
  bool _timerDone = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    StartAppSdk.init("202871798");
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    _startApp.loadBannerAd(
      StartAppBannerType.BANNER,
      onAdLoaded: (ad) => setState(() => _bannerAd = ad),
      onAdNotLoaded: (e) => print(e),
    );
  }

  void _loadInterstitialAd() {
    _startApp.loadInterstitialAd(
      onAdLoaded: (ad) => setState(() => _interstitialAd = ad),
      onAdNotLoaded: (e) => print(e),
    );
  }

  void _startTimer() {
    setState(() { _timerRunning = true; _timerDone = false; _seconds = 5; });
    _interstitialAd?.show();
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        if (_seconds > 1) { _seconds--; }
        else { _seconds = 0; _timerRunning = false; _timerDone = true; t.cancel(); _loadInterstitialAd(); }
      });
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('QUICK ACCESS', style: TextStyle(color: Colors.cyan, fontSize: 14, letterSpacing: 4, fontWeight: FontWeight.bold)),
                  SizedBox(height: 40),
                  if (_timerRunning || _timerDone)
                    Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.cyan, width: 4),
                        boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.3), blurRadius: 20)],
                      ),
                      child: Center(child: Text(_timerDone ? '✓' : '$_seconds', style: TextStyle(color: Colors.cyan, fontSize: 48, fontWeight: FontWeight.bold))),
                    ),
                  SizedBox(height: 30),
                  if (!_timerRunning && !_timerDone)
                    ElevatedButton(
                      onPressed: _startTimer,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.black, padding: EdgeInsets.symmetric(horizontal: 50, vertical: 18), shape: StadiumBorder()),
                      child: Text('▶  START', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 3)),
                    ),
                  if (_timerDone)
                    ElevatedButton(
                      onPressed: () => setState(() { _timerDone = false; _seconds = 5; }),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 50, vertical: 18), shape: StadiumBorder()),
                      child: Text('CONTINUE →', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 3)),
                    ),
                ],
              ),
            ),
          ),
          if (_bannerAd != null) StartAppBanner(_bannerAd!),
        ],
      ),