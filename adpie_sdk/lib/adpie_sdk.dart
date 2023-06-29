import 'package:flutter/services.dart';
import 'package:adpie_sdk/src/adpie_sdk_listener.dart';
import 'package:adpie_sdk/src/adpie_sdk_common.dart';

export 'package:adpie_sdk/src/adpie_sdk_listener.dart';
export 'package:adpie_sdk/src/adpie_sdk_common.dart';

class AdPieSdk {
  static const version = "0.0.2";

  static const channel = MethodChannel('adpie_sdk');

  static AdViewListener? _adViewListener;
  static InterstitialAdListener? _interstitialAdListener;
  static RewardedAdListener? _rewardedAdListener;

  AdPieSdk();

  static void initialize(String appId) {

    channel.setMethodCallHandler((MethodCall call) async {
      var method = call.method;
      var arguments = call.arguments;
      print("method : " + method);

      if (method == "AdView_onAdLoaded") {
        _adViewListener?.onAdLoaded();
      } else if (method == "AdView_onAdFailedToLoad") {
        _adViewListener?.onAdFailedToLoad(arguments['error_code']);
      } else if (method == "AdView_onAdClicked") {
        _adViewListener?.onAdClicked();
      }

      if (method == "Interstitial_onAdLoaded") {
        _interstitialAdListener?.onAdLoaded();
      } else if (method == "Interstitial_onAdFailedToLoad") {
        _interstitialAdListener?.onAdFailedToLoad(arguments['error_code']);
      } else if (method == "Interstitial_onAdShown") {
        _interstitialAdListener?.onAdShown();
      } else if (method == "Interstitial_onAdClicked") {
        _interstitialAdListener?.onAdClicked();
      } else if (method == "Interstitial_onAdDismissed") {
        _interstitialAdListener?.onAdDismissed();
      }

      if (method == "RewardedAd_onAdLoaded") {
        _rewardedAdListener?.onAdLoaded();
      } else if (method == "RewardedAd_onAdFailedToLoad") {
        _rewardedAdListener?.onAdFailedToLoad(arguments['error_code']);
      } else if (method == "RewardedAd_onAdShown") {
        _rewardedAdListener?.onAdShown();
      } else if (method == "RewardedAd_onAdClicked") {
        _rewardedAdListener?.onAdClicked();
      } else if (method == "RewardedAd_onAdRewarded") {
        _rewardedAdListener?.onAdRewarded();
      } else if (method == "RewardedAd_onAdDismissed") {
        _rewardedAdListener?.onAdDismissed();
      }
    });

    channel.invokeMethod('initialize', {
      'plugin_version': version,
      'media_id': appId,
    });
  }

  static Future<bool?> isInitialized() {
    return channel.invokeMethod('isInitialized');
  }

  static void setAdViewPosition(String slotId, String position) {
    channel.invokeMethod('setAdViewPosition', {
      'slot_id': slotId,
      'position': position
    });
  }

  static void loadAdView(String slotId, String size) {
    channel.invokeMethod('loadAdView', {
      'slot_id': slotId,
      'size': size
    });
  }

  static void destroyAdView(String slotId) {
    channel.invokeMethod('destroyAdView', {
      'slot_id': slotId,
    });
  }

  static void loadInterstitial(String slotId) {
    channel.invokeMethod('loadInterstitial', {
      'slot_id': slotId,
    });
  }

  static void showInterstitial(String slotId) {
    channel.invokeMethod('showInterstitial', {
      'slot_id': slotId,
    });
  }

  static void destroyInterstitial(String slotId) {
    channel.invokeMethod('destroyInterstitial', {
      'slot_id': slotId,
    });
  }

  static Future<bool?> isInterstitialLoaded(String slotId) {
    return channel.invokeMethod('isInterstitialLoaded', {
      'slot_id': slotId,
    });
  }

  static void loadRewardedAd(String slotId) {
    channel.invokeMethod('loadRewardedAd', {
      'slot_id': slotId,
    });
  }

  static void showRewardedAd(String slotId) {
    channel.invokeMethod('showRewardedAd', {
      'slot_id': slotId,
    });
  }

  static Future<bool?> isRewardedAdLoaded(String slotId) {
    return channel.invokeMethod('isRewardedAdLoaded', {
      'slot_id': slotId,
    });
  }

  static void setAdViewListener(AdViewListener adViewListener) {
    _adViewListener = adViewListener;
  }

  static void setInterstitialListener(InterstitialAdListener interstitialAdListener) {
    _interstitialAdListener = interstitialAdListener;
  }

  static void setRewardedAdListener(RewardedAdListener rewardedAdListener) {
    _rewardedAdListener = rewardedAdListener;
  }
}