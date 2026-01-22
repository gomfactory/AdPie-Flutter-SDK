import 'package:flutter/material.dart';
import 'package:adpie_sdk/adpie_sdk.dart';
import 'dart:io' show Platform;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

import 'banner_ad.dart';
import 'interstitial_ad.dart';
import 'rewarded_ad.dart';

// Constants
const String _androidMediaId = "57342d1b7174ea39844cac10";
const String _iosMediaId = "57342d787174ea39844cac11";

String get _mediaId => Platform.isAndroid ? _androidMediaId : _iosMediaId;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeSdk();
  runApp(const MyApp());
}

Future<void> _initializeSdk() async {
  if (Platform.isIOS) {
    // Request tracking transparency on iOS
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("UUID: $uuid");
  }

  AdPieSdk.initialize(_mediaId);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdPie Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'AdPie Sample Page'),
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
  final List<String> _adTypes = <String>[
    'Banner Ad',
    'Interstitial Ad',
    'Rewarded Ad'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.separated(
        itemCount: _adTypes.length,
        separatorBuilder: (context, index) => const Divider(thickness: 0),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_adTypes[index], textAlign: TextAlign.center),
            onTap: () => _navigateToAdPage(context, index),
          );
        },
      ),
    );
  }

  void _navigateToAdPage(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = AdPieBanner();
        break;
      case 1:
        page = AdPieInterstitialAd();
        break;
      case 2:
        page = AdPieRewardedAd();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
