
import 'package:flutter/material.dart';
import 'package:myapp/offline_screen/offline_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carengo',
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
      home: const MyHomePage(),
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
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    _checkConnectivity();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Treat any web resource error as being offline
            if (mounted) {
              setState(() {
                _isOffline = true;
                _isLoading = false;
              });
            }
          },
        ),
      );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final isNowOffline = result.contains(ConnectivityResult.none);
    if (isNowOffline != _isOffline) {
      if (mounted) {
        setState(() {
          _isOffline = isNowOffline;
          if (!_isOffline) {
            _isLoading = true; // Start loading if we come back online
            _controller.loadRequest(Uri.parse('https://carengo.onrender.com'));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You are back online!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      }
    } else if (!_isOffline && _controller.platform.toString().isEmpty) {
        // This case handles the initial load when the app starts online.
        if (mounted) {
            setState(() {
                 _isLoading = true;
            });
            _controller.loadRequest(Uri.parse('https://carengo.onrender.com'));
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isOffline ? null : AppBar(title: const Text('Carengo')),
      body: _isOffline
          ? const OfflineScreen()
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OfflineScreen()),
          );
        },
        tooltip: 'Features & More',
        child: const Icon(Icons.apps),
      ),
    );
  }
}
