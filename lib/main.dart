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

  bool _adsInitialized = false;
  bool _interstitialReady = false;
  bool _bannerLoaded = false;

  int _seconds = 5;
  bool _timerRunning = false;
  bool _timerDone = false;
  Timer? _timer;

  // Debug messages list
  List<String> _debugLogs = [];

  void _log(String message) {
    print(message);
    setState(() {
      _debugLogs.insert(0, '${TimeOfDay.now().format(context)} — $message');
      if (_debugLogs.length > 6) _debugLogs.removeLast();
    });
  }

  @override
  void initState() {
    super.initState();
    _initUnityAds();
  }

  void _initUnityAds() {
    _log('⏳ Unity Ads init ho raha hai...');
    UnityAds.init(
      gameId: gameId,
      testMode: true,
      onComplete: () {
        setState(() => _adsInitialized = true);
        _log('✅ Unity Ads init complete!');
        _loadInterstitial();
        _loadBanner();
      },
      onFailed: (error, message) {
        _log('❌ Init FAIL: $message');
      },
    );
  }

  void _loadInterstitial() {
    _log('⏳ Interstitial load ho raha hai...');
    UnityAds.load(
      placementId: interstitialId,
      onComplete: (id) {
        setState(() => _interstitialReady = true);
        _log('✅ Interstitial ready!');
      },
      onFailed: (id, error, message) {
        setState(() => _interstitialReady = false);
        _log('❌ Interstitial FAIL: $message');
      },
    );
  }

  void _loadBanner() {
    _log('⏳ Banner load ho raha hai...');
    UnityAds.load(
      placementId: bannerId,
      onComplete: (id) {
        setState(() => _bannerLoaded = true);
        _log('✅ Banner ready!');
      },
      onFailed: (id, error, message) {
        _log('❌ Banner FAIL: $message');
      },
    );
  }

  void _startTimer() {
    setState(() {
      _timerRunning = true;
      _timerDone = false;
      _seconds = 5;
    });

    if (_interstitialReady) {
      _log('▶ Interstitial show ho raha hai...');
      UnityAds.showVideoAd(
        placementId: interstitialId,
        onComplete: (id) {
          _log('✅ Ad dekha gaya!');
          _loadInterstitial();
        },
        onFailed: (id, error, message) {
          _log('❌ Ad show FAIL: $message');
          _loadInterstitial();
        },
        onStart: (id) => _log('▶ Ad start hua!'),
        onClick: (id) => _log('👆 Ad click hua!'),
        onSkipped: (id) {
          _log('⏭ Ad skip kiya!');
          _loadInterstitial();
        },
      );
    } else {
      _log('⚠️ Interstitial abhi ready nahi — pehle load hone do');
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
          // Banner Ad
          if (_bannerLoaded)
            UnityBannerAd(
              placementId: bannerId,
              onLoad: (id) => _log('✅ Banner display hua!'),
              onClick: (id) => _log('👆 Banner click!'),
              onFailed: (id, error, message) => _log('❌ Banner display FAIL: $message'),
            ),

          // Main Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('SOLX',
                      style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 28,
                          letterSpacing: 8,
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

          // 🔍 Debug Panel
          Container(
            width: double.infinity,
            color: Colors.black87,
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('🔍 DEBUG', style: TextStyle(color: Colors.yellow, fontSize: 11, fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    _statusDot('SDK', _adsInitialized),
                    SizedBox(width: 6),
                    _statusDot('Interstitial', _interstitialReady),
                    SizedBox(width: 6),
                    _statusDot('Banner', _bannerLoaded),
                  ],
                ),
                SizedBox(height: 6),
                ..._debugLogs.map((log) => Text(
                  log,
                  style: TextStyle(
                    color: log.contains('❌') ? Colors.redAccent :
                           log.contains('✅') ? Colors.greenAccent :
                           log.contains('⚠️') ? Colors.orange :
                           Colors.white70,
                    fontSize: 10,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusDot(String label, bool active) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: active ? Colors.greenAccent : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 3),
        Text(label, style: TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }
}
