import 'package:flutter/material.dart';
import 'package:adpie_sdk/adpie_sdk.dart';
import 'dart:io' show Platform;

class AdPieInterstitialAd extends StatefulWidget {
  const AdPieInterstitialAd({super.key});

  @override
  State<StatefulWidget> createState() => _AdPieInterstitialAdState();
}

class _AdPieInterstitialAdState extends State<AdPieInterstitialAd> {

  static const String _androidSlotId = "57342e3d7174ea39844cac14";
  static const String _iosSlotId = "573430057174ea39844cac16";

  String get _slotId => Platform.isAndroid ? _androidSlotId : _iosSlotId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interstitial Ad'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _loadAd,
              child: const Text('Load'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAd,
              child: const Text('Show'),
            ),
          ],
        ),
      ),
    );
  }

  void _loadAd() {
    AdPieSdk.setInterstitialListener(InterstitialAdListener(
      onAdLoaded: () => print("AdPieSample InterstitialAd - onAdLoaded"),
      onAdFailedToLoad: (int errorCode) => print("AdPieSample InterstitialAd - onAdFailedToLoad : $errorCode"),
      onAdShown: () => print("AdPieSample InterstitialAd - onAdShown"),
      onAdClicked: () => print("AdPieSample InterstitialAd - onAdClicked"),
      onAdDismissed: () => print("AdPieSample InterstitialAd - onAdDismissed"),
      onAdFailedToShow: (int errorCode) => print("AdPieSample InterstitialAd - onAdFailedToShow : $errorCode"),
    ));

    AdPieSdk.loadInterstitial(_slotId);
  }

  Future<void> _showAd() async {
    bool? isLoaded = await AdPieSdk.isInterstitialLoaded(_slotId);
    if (isLoaded == true) {
      AdPieSdk.showInterstitial(_slotId);
    } else {
      print("AdPieSample InterstitialAd - Ad is not loaded");
    }
  }

  @override
  void dispose() {
    AdPieSdk.destroyInterstitial(_slotId);
    super.dispose();
  }
}