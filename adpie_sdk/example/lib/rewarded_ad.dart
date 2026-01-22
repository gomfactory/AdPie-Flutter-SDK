import 'package:flutter/material.dart';
import 'package:adpie_sdk/adpie_sdk.dart';
import 'dart:io' show Platform;

class AdPieRewardedAd extends StatefulWidget {
  const AdPieRewardedAd({super.key});

  @override
  State<StatefulWidget> createState() => _AdPieRewardedAdState();
}

class _AdPieRewardedAdState extends State<AdPieRewardedAd> {
  static const String _androidSlotId = "58f99962affeaa4201970fa6";
  static const String _iosSlotId = "61de726d65a17f71c7896827";

  String get _slotId => Platform.isAndroid ? _androidSlotId : _iosSlotId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewarded Ad'),
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
    AdPieSdk.setRewardedAdListener(RewardedAdListener(
      onAdLoaded: () => print("AdPieSample RewardedAd - onAdLoaded"),
      onAdFailedToLoad: (int errorCode) => print("AdPieSample RewardedAd - onAdFailedToLoad : $errorCode"),
      onAdShown: () => print("AdPieSample RewardedAd - onAdShown"),
      onAdClicked: () => print("AdPieSample RewardedAd - onAdClicked"),
      onAdRewarded: () => print("AdPieSample RewardedAd - onAdRewarded"),
      onAdDismissed: () => print("AdPieSample RewardedAd - onAdDismissed"),
      onAdFailedToShow: (int errorCode) => print("AdPieSample RewardedAd - onAdFailedToShow : $errorCode"),
    ));

    AdPieSdk.loadRewardedAd(_slotId);
  }

  Future<void> _showAd() async {
    bool? isLoaded = await AdPieSdk.isRewardedAdLoaded(_slotId);
    if (isLoaded == true) {
      AdPieSdk.showRewardedAd(_slotId);
    } else {
      print("AdPieSample RewardedAd - Ad is not loaded");
    }
  }

  @override
  void dispose() {
    AdPieSdk.destroyRewardedAd(_slotId);
    super.dispose();
  }
}