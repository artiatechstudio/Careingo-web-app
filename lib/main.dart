import 'dart:async';
import 'package:flutter/material.dart';
import 'package:careingo/offline_screen/offline_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_database/firebase_database.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await MobileAds.instance.initialize();
    
    // Request permission for notifications
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Careingo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // For title and icons
          elevation: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/splash.png',
          width: 250,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WebViewController _controller;
  bool _isOffline = true;
  bool _isLoading = true;
  double _loadingProgress = 0.0;
  bool _isFirstConnectivityCheck = true;
  bool _isPremiumUser = false;
  StreamSubscription? _premiumSubscription;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    _checkConnectivity();

    _controller = WebViewController();

    if (!kIsWeb) {
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..addJavaScriptChannel(
          'CareingoApp',
          onMessageReceived: (JavaScriptMessage message) {
            _handleUidReceived(message.message);
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  _loadingProgress = progress / 100.0;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted) {
                setState(() {
                  _isOffline = true;
                  _isLoading = false;
                });
              }
            },
          ),
        );
    } else {
      // For Web, delegates are unsupported so we hide the loading screen manually
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _premiumSubscription?.cancel();
    super.dispose();
  }

  void _handleUidReceived(String uid) {
    if (uid.isEmpty) return;
    
    // Cancel existing subscription if any
    _premiumSubscription?.cancel();
    
    // Listen to the user's premium status in Realtime Database
    // Path assumed: users/UID/isPremium
    _premiumSubscription = FirebaseDatabase.instance
        .ref('users/$uid/isPremium')
        .onValue
        .listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      
      bool isPremium = false;
      if (data != null) {
        // Handle both integer (1/0) and boolean if needed
        if (data is bool) {
          isPremium = data;
        } else if (data is int) {
          isPremium = data == 1;
        } else if (data is String) {
          isPremium = data == "1" || data.toLowerCase() == "true";
        }
      }

      if (mounted) {
        setState(() {
          _isPremiumUser = isPremium;
        });
        
        if (isPremium) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تفعيل وضع البريميوم - تم إخفاء الإعلانات'),
              backgroundColor: Colors.blueAccent,
            ),
          );
        }
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final isNowOffline = result.contains(ConnectivityResult.none);

    if (_isFirstConnectivityCheck) {
      _isFirstConnectivityCheck = false;
      if (mounted) {
        setState(() {
          _isOffline = isNowOffline;
          if (!isNowOffline) {
            _isLoading = true;
          }
        });
      }
      if (!isNowOffline) {
        _controller.loadRequest(Uri.parse('https://careingo.onrender.com'));
      }
      return;
    }

    if (isNowOffline != _isOffline) {
      if (mounted) {
        setState(() {
          if (!isNowOffline) {
            _isOffline = false;
            _isLoading = true; // Start loading if we come back online
            _loadingProgress = 0.0;
            _controller.loadRequest(Uri.parse('https://careingo.onrender.com'));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('لقد عدت إلى الاتصال بالإنترنت!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          // We don't automatically set _isOffline = true when connection drops.
          // We keep the WebView active to show cached content.
          // onWebResourceError will trigger _isOffline = true if navigation fails.
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isOffline
            ? OfflineScreen(isPremium: _isPremiumUser)
            : Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: _loadingProgress,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
