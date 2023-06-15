import 'package:flutter/material.dart';
import 'package:adpie_sdk/adpie_sdk.dart';
import 'dart:io' show Platform;

class AdPieRewardedAd extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AdPieRewardedAd();
  }
}

class _AdPieRewardedAd extends State<AdPieRewardedAd> {

  String slotId = Platform.isAndroid ? "58f99962affeaa4201970fa6" : "61de726d65a17f71c7896827";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewarded Ad'),
      ),
      body: Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  AdPieSdk.setRewardedAdListener(RewardedAdListener(
                    onAdLoaded: (){
                      print("AdPieSample RewardedAd - onAdLoaded");
                    }, onAdFailedToLoad: (int errorCode){
                      print("AdPieSample RewardedAd - onAdFailedToLoad : $errorCode");
                    }, onAdShown: (){
                      print("AdPieSample RewardedAd - onAdShown");
                    }, onAdClicked: (){
                      print("AdPieSample RewardedAd - onAdClicked");
                    }, onAdRewarded: (){
                      print("AdPieSample RewardedAd - onAdRewarded");
                    }, onAdDismissed: (){
                      print("AdPieSample RewardedAd - onAdDismissed");
                  }));
                  AdPieSdk.loadRewardedAd(slotId);
                },
                child: const Text('Load'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  bool isLoaded = (await AdPieSdk.isRewardedAdLoaded(slotId))!;
                  if (isLoaded) {
                    AdPieSdk.showRewardedAd(slotId);
                  }
                },
                child: const Text('Show'),
              ),
            ],
          )
      ),
    );
  }
}