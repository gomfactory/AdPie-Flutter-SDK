import 'package:flutter/material.dart';
import 'package:adpie_sdk/adpie_sdk.dart';
import 'dart:io' show Platform;

class AdPieBanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AdPieBanner();
  }
}

class _AdPieBanner extends State<AdPieBanner> {

  String slotId = Platform.isAndroid ? "57342e0d7174ea39844cac13" : "57342fdd7174ea39844cac15";

  @override
  void initState() {
    super.initState();
    AdPieSdk.setAdViewListener(AdViewListener(
        onAdLoaded: (){
          print("AdPieSample AdView - onAdLoaded");
        },
        onAdFailedToLoad: (int errorCode) {
          print("AdPieSample AdView - onAdFailedToLoad : $errorCode");
        },
        onAdClicked: (){
          print("AdPieSample AdView - onAdClicked");
        }));

    AdPieSdk.setAdViewPosition(slotId, AdPieCommon.position_bottom_center);
    AdPieSdk.loadAdView(slotId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Ad'),
      ),
      body: Container(),
    );
  }

  @override
  void dispose() {
    super.dispose();

    AdPieSdk.destroyAdView(slotId);
  }
}