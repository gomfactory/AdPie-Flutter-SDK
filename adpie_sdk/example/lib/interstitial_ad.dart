import 'package:flutter/material.dart';
import 'package:adpie_sdk/adpie_sdk.dart';

class AdPieInterstitialAd extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AdPieInterstitialAd();
  }
}

class _AdPieInterstitialAd extends State<AdPieInterstitialAd>{

  String slotId = "57342e3d7174ea39844cac14";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interstitial Ad'),
      ),
      body: Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  AdPieSdk.setInterstitialListener(InterstitialAdListener(
                      onAdLoaded: (){
                        print("AdPieSample InterstitialAd - onAdLoaded");
                      },
                      onAdFailedToLoad: (int errorCode){
                        print("AdPieSample InterstitialAd - onAdFailedToLoad : $errorCode");
                      },
                      onAdShown: (){
                        print("AdPieSample InterstitialAd - onAdShown");
                      },
                      onAdClicked: (){
                        print("AdPieSample InterstitialAd - onAdClicked");
                      },
                      onAdDismissed: (){
                        print("AdPieSample InterstitialAd - onAdDismissed");
                      })
                  );

                  AdPieSdk.loadInterstitial(slotId);
                },
                child: const Text('Load'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  bool isLoaded = (await AdPieSdk.isInterstitialLoaded(slotId))!;
                  if (isLoaded) {
                    AdPieSdk.showInterstitial(slotId);
                  }
                },
                child: const Text('Show'),
              ),
            ],
          )
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    AdPieSdk.destroyInterstitial(slotId);
  }
}