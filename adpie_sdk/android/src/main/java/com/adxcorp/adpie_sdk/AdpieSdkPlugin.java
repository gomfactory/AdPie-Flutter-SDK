package com.adxcorp.adpie_sdk;

import static com.gomfactory.adpie.sdk.videoads.FinishState.*;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;

import com.gomfactory.adpie.sdk.AdPieSDK;
import com.gomfactory.adpie.sdk.AdView;
import com.gomfactory.adpie.sdk.InterstitialAd;
import com.gomfactory.adpie.sdk.RewardedVideoAd;
import com.gomfactory.adpie.sdk.util.AdPieLog;
import com.gomfactory.adpie.sdk.util.DisplayUtil;
import com.gomfactory.adpie.sdk.videoads.FinishState;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** AdpieSdkPlugin */
public class AdpieSdkPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel defaultChannel;

  private static String TAG = "AdPieFlutter";
  private Context context;
  private ActivityPluginBinding lastActivityPluginBinding;

  private final Map<String, AdView> mAdViews= new HashMap<>( 2 );
  private final Map<String, String> mAdViewPositions = new HashMap<>( 2 );
  private final Map<String, InterstitialAd> mInterstitials = new HashMap<>( 2 );
  private final Map<String, RewardedVideoAd> mRewardedAds   = new HashMap<>( 2 );

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    defaultChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "adpie_sdk");
    defaultChannel.setMethodCallHandler(this);

    context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("initialize")) {

      AdPieLog.setLogEnable(true);
      String mediaId = call.argument("media_id");
      String pluginVersion = call.argument("plugin_version");

      Log.d(TAG, "AdPie Flutter Version : " + pluginVersion
              + ", AdPie SDK Version : " + AdPieSDK.getInstance().getVersion()
              + ", Media ID : " + mediaId);

      AdPieSDK.getInstance().initialize(context, mediaId);

    } else if (call.method.equals("isInitialized")) {

      result.success(AdPieSDK.getInstance().isInitialized());

    } else if (call.method.equals("setAdViewPosition")) {

      String slotId = call.argument("slot_id");
      String position = call.argument("position");

      mAdViewPositions.put(slotId, position);
      updatePositionAdView(slotId);

      result.success(null);

    } else if (call.method.equals("loadAdView")) {

      String slotId = call.argument("slot_id");
      String size = call.argument("size");

      AdView adView = retrieveAdView(slotId, size);

      if (adView.getParent() == null) {
        Activity currentActivity = getCurrentActivity();
        RelativeLayout relativeLayout = new RelativeLayout(currentActivity);
        currentActivity.addContentView(relativeLayout, new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT));

        relativeLayout.addView(adView);
      }

      updatePositionAdView(slotId);

      adView.load();

      result.success(null);

    } else if (call.method.equals("destroyAdView")) {

      String slotId = call.argument("slot_id");

      if (mAdViews.containsKey(slotId)) {
        AdView adView = mAdViews.get(slotId);

        if (adView != null) {
          ViewParent parent = adView.getParent();
          if (parent instanceof ViewGroup) {
            ((ViewGroup) parent).removeView(adView);
          }

          adView.destroy();
          adView = null;
        }

        mAdViews.remove(slotId);
      }

      mAdViewPositions.remove(slotId);

      result.success(null);

    } else if (call.method.equals("loadInterstitial")) {

      String slotId = call.argument("slot_id");

      InterstitialAd interstitial = retrieveInterstitial(slotId);
      interstitial.load();

      result.success(null);

    } else if (call.method.equals("isInterstitialLoaded")) {

      String slotId = call.argument("slot_id");

      if (mInterstitials.containsKey(slotId)) {
        InterstitialAd interstitial = retrieveInterstitial(slotId);
        result.success(interstitial.isLoaded());
      } else {
        result.success(false);
      }

    } else if (call.method.equals("showInterstitial")) {

      String slotId = call.argument("slot_id");

      if (mInterstitials.containsKey(slotId)) {
        InterstitialAd interstitial = retrieveInterstitial(slotId);
        interstitial.show();
      }

      result.success(null);

    } else if (call.method.equals("destroyInterstitial")) {

      String slotId = call.argument("slot_id");

      if (mInterstitials.containsKey(slotId)) {
        InterstitialAd interstitial = retrieveInterstitial(slotId);
        if (interstitial != null) {
          interstitial.destroy();
          interstitial = null;
        }

        mInterstitials.remove(slotId);
      }

      result.success(null);

    } else if (call.method.equals("loadRewardedAd")) {

      String slotId = call.argument("slot_id");

      RewardedVideoAd rewardedVideoAd = retrieveRewardedAd(slotId);
      rewardedVideoAd.load();

      result.success(null);

    } else if (call.method.equals("isRewardedAdLoaded")) {

      String slotId = call.argument("slot_id");

      if (mRewardedAds.containsKey(slotId)) {
        RewardedVideoAd rewardedVideoAd = retrieveRewardedAd(slotId);

        result.success(rewardedVideoAd.isLoaded());
      } else {
        result.success(false);
      }

    } else if (call.method.equals("showRewardedAd")) {

      String slotId = call.argument("slot_id");

      if (mRewardedAds.containsKey(slotId)) {
        RewardedVideoAd rewardedVideoAd = retrieveRewardedAd(slotId);
        rewardedVideoAd.show();
      }

      result.success(null);

    } else if (call.method.equals("destroyRewardedAd")) {
      String slotId = call.argument("slot_id");

      if (mRewardedAds.containsKey(slotId)) {
        RewardedVideoAd rewardedVideoAd = retrieveRewardedAd(slotId);
        if (rewardedVideoAd != null) {
          rewardedVideoAd.destroy();
          rewardedVideoAd = null;
        }

        mRewardedAds.remove(slotId);
      }

      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  private void updatePositionAdView(String slotId) {
    AdView adView = mAdViews.get(slotId);
    String position = mAdViewPositions.get(slotId);

    if (adView == null) {
      return;
    }

    if (TextUtils.isEmpty(position)) {
      position = "bottom_center";
    }

    RelativeLayout.LayoutParams prelayoutParams = (RelativeLayout.LayoutParams) adView.getLayoutParams();

    RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(prelayoutParams.width,
            prelayoutParams.height);

    switch (position) {
      case "top_center" :
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
        break;
      case "top_left" :
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        break;
      case "top_right" :
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        break;
      case "center" :
        layoutParams.addRule(RelativeLayout.CENTER_IN_PARENT);
        break;
      case "center_left" :
        layoutParams.addRule(RelativeLayout.CENTER_VERTICAL);
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        break;
      case "center_right" :
        layoutParams.addRule(RelativeLayout.CENTER_VERTICAL);
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        break;
      case "bottom_center":
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        layoutParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
        break;
      case "bottom_left" :
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        break;
      case "bottom_right" :
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        break;
      default:
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        layoutParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
        break;
    }

    adView.setLayoutParams(layoutParams);
  }

  private AdView retrieveAdView(String slotId, String size) {
    AdView adView = mAdViews.get(slotId);
    if (adView == null) {
      adView = new AdView(getCurrentActivity());

      RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(
              ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);

      switch (size) {
        case "320x50":
          layoutParams = new RelativeLayout.LayoutParams(DisplayUtil.dpToPx(context, 320),
                  DisplayUtil.dpToPx(context, 50));
          break;
        case "320x100":
          layoutParams = new RelativeLayout.LayoutParams(DisplayUtil.dpToPx(context, 320),
                  DisplayUtil.dpToPx(context, 100));
          break;
        case "300x250":
          layoutParams = new RelativeLayout.LayoutParams(DisplayUtil.dpToPx(context, 300),
                  DisplayUtil.dpToPx(context, 250));
          break;
        case "320x480":
          layoutParams = new RelativeLayout.LayoutParams(DisplayUtil.dpToPx(context, 320),
                  DisplayUtil.dpToPx(context, 480));
          break;
      }
      adView.setLayoutParams(layoutParams);

      adView.setAdListener(new AdView.AdListener() {
        @Override
        public void onAdLoaded() {
          defaultChannel.invokeMethod("AdView_onAdLoaded", null);
        }

        @Override
        public void onAdFailedToLoad(int errorCode) {
          Map<String, Object> params = new HashMap<>();
          params.put("error_code", errorCode);
          defaultChannel.invokeMethod("AdView_onAdFailedToLoad", params);
        }

        @Override
        public void onAdClicked() {
          defaultChannel.invokeMethod("AdView_onAdClicked", null);
        }
      });
      adView.setSlotId(slotId);

      mAdViews.put(slotId, adView);
    }

    return adView;
  }

  private InterstitialAd retrieveInterstitial(String slotId)
  {
    InterstitialAd interstitialAd = mInterstitials.get(slotId);
    if ( interstitialAd == null )
    {
      interstitialAd = new InterstitialAd(getCurrentActivity(), slotId);
      interstitialAd.setAdListener(new InterstitialAd.InterstitialAdListener() {
        @Override
        public void onAdLoaded() {
          defaultChannel.invokeMethod("Interstitial_onAdLoaded", null);
        }

        @Override
        public void onAdFailedToLoad(int errorCode) {
          Map<String, Object> params = new HashMap<>();
          params.put("error_code", errorCode);
          defaultChannel.invokeMethod("Interstitial_onAdFailedToLoad", params);
        }

        @Override
        public void onAdShown() {
          defaultChannel.invokeMethod("Interstitial_onAdShown", null);
        }

        @Override
        public void onAdClicked() {
          defaultChannel.invokeMethod("Interstitial_onAdClicked", null);
        }

        @Override
        public void onAdDismissed() {
          defaultChannel.invokeMethod("Interstitial_onAdDismissed", null);
        }
      });

      mInterstitials.put(slotId, interstitialAd);
    }

    return interstitialAd;
  }

  private RewardedVideoAd retrieveRewardedAd(String slotId)
  {
    RewardedVideoAd rewardedVideoAd = mRewardedAds.get(slotId);
    if ( rewardedVideoAd == null )
    {
      rewardedVideoAd = new RewardedVideoAd(getCurrentActivity(), slotId);
      rewardedVideoAd.setAdListener(new RewardedVideoAd.RewardedVideoAdListener() {
        @Override
        public void onRewardedVideoLoaded() {
          defaultChannel.invokeMethod("RewardedAd_onAdLoaded", null);
        }

        @Override
        public void onRewardedVideoFailedToLoad(int errorCode) {
          Map<String, Object> params = new HashMap<>();
          params.put("error_code", errorCode);
          defaultChannel.invokeMethod("RewardedAd_onAdFailedToLoad", params);
        }

        @Override
        public void onRewardedVideoClicked() {
          defaultChannel.invokeMethod("RewardedAd_onAdClicked", null);
        }

        @Override
        public void onRewardedVideoStarted() {
          defaultChannel.invokeMethod("RewardedAd_onAdShown", null);
        }

        @Override
        public void onRewardedVideoFinished(FinishState finishState) {
          if (finishState == COMPLETED) {
            defaultChannel.invokeMethod("RewardedAd_onAdRewarded", null);
          }

          defaultChannel.invokeMethod("RewardedAd_onAdDismissed", null);
        }
      });

      mRewardedAds.put(slotId, rewardedVideoAd);
    }

    return rewardedVideoAd;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    defaultChannel.setMethodCallHandler(null);
    context = null;
  }

  private Activity getCurrentActivity()
  {
    return ( lastActivityPluginBinding != null ) ? lastActivityPluginBinding.getActivity() : null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    lastActivityPluginBinding = binding;
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }
}
