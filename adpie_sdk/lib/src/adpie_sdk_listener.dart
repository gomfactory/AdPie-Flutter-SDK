class AdViewListener {
  void Function() onAdLoaded;
  void Function(int errorCode) onAdFailedToLoad;
  void Function() onAdClicked;

  AdViewListener({
    required this.onAdLoaded,
    required this.onAdFailedToLoad,
    required this.onAdClicked
  });
}

class InterstitialAdListener {

  void Function() onAdLoaded;
  void Function(int errorCode) onAdFailedToLoad;
  void Function() onAdShown;
  void Function() onAdClicked;
  void Function() onAdDismissed;
  void Function() onAdFailedToShow;

  InterstitialAdListener({
      required this.onAdLoaded,
      required this.onAdFailedToLoad,
      required this.onAdShown,
      required this.onAdClicked,
      required this.onAdDismissed,
      required this.onAdFailedToShow
  });
}

class RewardedAdListener {
  void Function() onAdLoaded;
  void Function(int errorCode) onAdFailedToLoad;
  void Function() onAdShown;
  void Function() onAdClicked;
  void Function() onAdRewarded;
  void Function() onAdDismissed;
  void Function() onAdFailedToShow;

  RewardedAdListener({
    required this.onAdLoaded,
    required this.onAdFailedToLoad,
    required this.onAdShown,
    required this.onAdClicked,
    required this.onAdRewarded,
    required this.onAdDismissed,
    required this.onAdFailedToShow
  });
}