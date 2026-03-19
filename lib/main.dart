import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF050810),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  static const String gameId = '6070182';
  static const String interstitialId = 'Interstitial_Android';
  static const String bannerId = 'Banner_Android';

  bool _adsReady = false;
  bool _bannerLoaded = false;

  int _seconds = 5;
  bool _timerRunning = false;
  bool _timerDone = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initUnityAds();
  }

  void _initUnityAds() {
    UnityAds.init(
      gameId: gameId,
      testMode: false,
      onComplete: () {
        setState(() => _adsReady = true);
        _loadBanner();
      },
      onFailed: (error, message) => print('Init failed: $message'),
    );
  }

  void _loadBanner() {
    UnityAds.load(
      placementId: bannerId,
      onComplete: (id) => setState(() => _bannerLoaded = true),
      onFailed: (id, error, message) => print('Banner failed: $message'),
    );
  }

  void _startTimer() {
    setState(() {
      _timerRunning = true;
      _timerDone = false;
      _seconds = 5;
    });

    if (_adsReady) {
      UnityAds.showVideoAd(
        placementId: interstitialId,
        onComplete: (id) => print('Ad completed'),
        onFailed: (id, error, message) => print('Ad failed: $message'),
        onStart: (id) => print('Ad started'),
        onClick: (id) => print('Ad clicked'),
        onSkipped: (id) => print('Ad skipped'),
      );
    }

    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        if (_seconds > 1) {
          _seconds--;
        } else {
          _seconds = 0;
          _timerRunning = false;
          _timerDone = true;
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_bannerLoaded)
            UnityBannerAd(
              placementId: bannerId,
              onLoad: (id) => print('Banner loaded'),
              onClick: (id) => print('Banner clicked'),
              onFailed: (id, error, message) => print('Banner error'),
            ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('QUICK ACCESS',
                      style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 14,
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 40),
                  if (_timerRunning || _timerDone)
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.cyan, width: 4),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.cyan.withOpacity(0.3),
                              blurRadius: 20)
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _timerDone ? '✓' : '$_seconds',
                          style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 48,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  SizedBox(height: 30),
                  if (!_timerRunning && !_timerDone)
                    ElevatedButton(
                      onPressed: _startTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                        shape: StadiumBorder(),
                      ),
                      child: Text('▶  START',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3)),
                    ),
                  if (_timerDone)
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _timerDone = false;
                        _seconds = 5;
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                        shape: StadiumBorder(),
                      ),
                      child: Text('CONTINUE →',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
