#import "AdpieSdkPlugin.h"

@interface AdpieSdkPlugin()<APAdViewDelegate, APInterstitialDelegate, APRewardedAdDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSString *, APAdView *> *adViews;
@property (nonatomic, strong) NSMutableDictionary<NSString *, APInterstitial *> *interstitials;
@property (nonatomic, strong) NSMutableDictionary<NSString *, APRewardedAd *> *rewardedAds;

@property (nonatomic, strong) UIView *safeAreaBackground;

@end

@implementation AdpieSdkPlugin

static FlutterMethodChannel *adpieSdkChannel;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.adViews = [NSMutableDictionary dictionaryWithCapacity: 2];
        self.interstitials = [NSMutableDictionary dictionaryWithCapacity: 2];
        self.rewardedAds = [NSMutableDictionary dictionaryWithCapacity: 2];
        
        self.safeAreaBackground = [[UIView alloc] init];
        self.safeAreaBackground.hidden = YES;
        self.safeAreaBackground.backgroundColor = UIColor.clearColor;
        self.safeAreaBackground.translatesAutoresizingMaskIntoConstraints = NO;
        self.safeAreaBackground.userInteractionEnabled = NO;
        
        [[self topViewController].view addSubview:self.safeAreaBackground];
    }
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    adpieSdkChannel = [FlutterMethodChannel
      methodChannelWithName:@"adpie_sdk"
            binaryMessenger:[registrar messenger]];
  AdpieSdkPlugin* instance = [[AdpieSdkPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:adpieSdkChannel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"call.method : %@", call.method);
    
  if ([@"initialize" isEqualToString: call.method]) {
      NSString *pluginVersion = call.arguments[@"plugin_version"];
      NSString *mediaId = call.arguments[@"media_id"];

      NSLog(@"AdPie Flutter Version : %@, AdPie SDK Version : %@, Media ID : %@", pluginVersion, [AdPieSDK sdkVersion], mediaId);

      [[AdPieSDK sharedInstance] initWithMediaId:mediaId];
  } else if ([@"isInitialized" isEqualToString: call.method]) {
      BOOL isInitialized = [[AdPieSDK sharedInstance] isInitialized];
      
      result(@(isInitialized));
  } else if ([@"loadAdView" isEqualToString: call.method]) {
      APAdView *adView = [self retrieveAdViewForSlotId:call.arguments[@"slot_id"]];
      adView.delegate = self;
      [adView load];
      result(nil);
  } else if ([@"destroyAdView" isEqualToString: call.method]) {
      NSString *slotId = call.arguments[@"slot_id"];
      APAdView *adView = [self retrieveAdViewForSlotId:slotId];
      adView.delegate = nil;
      [adView removeFromSuperview];
      [self.adViews removeObjectForKey: slotId];
      result(nil);
  } else if ([@"loadInterstitial" isEqualToString: call.method]) {
      APInterstitial *interstitial = [self retrieveInterstitialForSlotId:call.arguments[@"slot_id"]];
      interstitial.delegate = self;
      [interstitial load];
      result(nil);
  } else if ([@"isInterstitialLoaded" isEqualToString: call.method]) {
      APInterstitial *interstitial = [self retrieveInterstitialForSlotId:call.arguments[@"slot_id"]];
      if (interstitial && interstitial.isReady) {
          result(@(YES));
      } else {
          result(@(NO));
      }
  } else if ([@"showInterstitial" isEqualToString: call.method]) {
      APInterstitial *interstitial = [self retrieveInterstitialForSlotId:call.arguments[@"slot_id"]];
      if (interstitial.isReady) {
          [interstitial presentFromRootViewController: [self topViewController]];
      }
      result(nil);
  } else if ([@"loadRewardedAd" isEqualToString: call.method]) {
      APRewardedAd *rewardedAd = [self retrieveRewardedAdForSlotId:call.arguments[@"slot_id"]];
      rewardedAd.delegate = self;
      [rewardedAd load];
      result(nil);
  } else if ([@"isRewardedAdLoaded" isEqualToString: call.method]) {
      APRewardedAd *rewardedAd = [self retrieveRewardedAdForSlotId:call.arguments[@"slot_id"]];
      if (rewardedAd && rewardedAd.isReady) {
          result(@(YES));
      } else {
          result(@(NO));
      }
  } else if ([@"showRewardedAd" isEqualToString: call.method]) {
      APRewardedAd *rewardedAd = [self retrieveRewardedAdForSlotId:call.arguments[@"slot_id"]];
      if (rewardedAd.isReady) {
          [rewardedAd presentFromRootViewController: [self topViewController]];
      }
      result(nil);
  }
}

- (APAdView *)retrieveAdViewForSlotId:(NSString *)slotId {
    APAdView *result = self.adViews[slotId];
    if (!result) {
        CGSize bannerSize = CGSizeMake(320, 50);
        result = [[APAdView alloc] init];
        
        result.userInteractionEnabled = NO;
        result.translatesAutoresizingMaskIntoConstraints = NO;
        
        CGFloat originX = (self.safeAreaBackground.bounds.size.width - bannerSize.width) / 2;
        CGFloat originY = self.safeAreaBackground.bounds.size.height - bannerSize.height;

        result.frame = CGRectMake(originX, originY, bannerSize.width, bannerSize.height);
        [result setSlotId:slotId];
        
        self.adViews[slotId] = result;
        
        result.rootViewController = [self topViewController];
        [result.rootViewController.view addSubview:result];
    }
    
    return result;
}

- (APInterstitial *)retrieveInterstitialForSlotId:(NSString *)slotId {
    APInterstitial *result = self.interstitials[slotId];
    if (!result) {
        result = [[APInterstitial alloc] initWithSlotId:slotId];
        self.interstitials[slotId] = result;
    }
    
    return result;
}

- (APRewardedAd *)retrieveRewardedAdForSlotId:(NSString *)slotId {
    APRewardedAd *result = self.rewardedAds[slotId];
    if (!result) {
        result = [[APRewardedAd alloc] initWithSlotId:slotId];
        self.rewardedAds[slotId] = result;
    }
    
    return result;
}

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

- (void)positionAdView:(APAdView *)adView {
    UIView *superview = adView.superview;
    if (!superview) return;
    
    if (![superview.subviews containsObject: self.safeAreaBackground]) {
        [self.safeAreaBackground removeFromSuperview];
        [superview insertSubview: self.safeAreaBackground belowSubview: adView];
    }
    
    [NSLayoutConstraint deactivateConstraints: self.safeAreaBackground.constraints];
    self.safeAreaBackground.hidden = NO;
    
    CGSize adViewSize = [self adViewSize:@"320x50"];
    
    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray arrayWithObject:
                                                         [adView.heightAnchor constraintEqualToConstant: adViewSize.height]];
    
    UILayoutGuide *layoutGuide;
    if (@available(iOS 11.0, *)) {
        layoutGuide = superview.safeAreaLayoutGuide;
    } else {
        layoutGuide = superview.layoutMarginsGuide;
    }
    
    [constraints addObjectsFromArray: @[[self.safeAreaBackground.leftAnchor constraintEqualToAnchor: superview.leftAnchor],
                                        [self.safeAreaBackground.rightAnchor constraintEqualToAnchor: superview.rightAnchor]]];
    
    [constraints addObjectsFromArray: @[[adView.bottomAnchor constraintEqualToAnchor: layoutGuide.bottomAnchor],
                                        [adView.leftAnchor constraintEqualToAnchor: superview.leftAnchor],
                                        [adView.rightAnchor constraintEqualToAnchor: superview.rightAnchor]]];
    [constraints addObjectsFromArray: @[[self.safeAreaBackground.topAnchor constraintEqualToAnchor: adView.bottomAnchor],
                                        [self.safeAreaBackground.bottomAnchor constraintEqualToAnchor: superview.bottomAnchor]]];
    
    [NSLayoutConstraint activateConstraints: constraints];
}

- (CGSize)adViewSize:(NSString *)adSize {
    if ([@"320x50" isEqualToString:adSize]) {
        return CGSizeMake(320.0f, 50.0f);
    } else {
        [NSException raise: NSInvalidArgumentException format: @"Invalid ad format"];
        return CGSizeZero;
    }
}

#pragma mark - APAdViewDelegate

- (void)adViewDidLoadAd:(APAdView *)view {
    [self positionAdView:view];
    view.userInteractionEnabled = YES;
    
    [adpieSdkChannel invokeMethod: @"AdView_onAdLoaded" arguments: nil];
}

- (void)adViewDidFailToLoadAd:(APAdView *)view withError:(NSError *)error {
    NSDictionary *args = @{@"error_code" : [NSNumber numberWithLong:error.code]};
    
    [adpieSdkChannel invokeMethod: @"AdView_onAdFailedToLoad" arguments: args];
}

- (void)adViewWillLeaveApplication:(APAdView *)view {
    [adpieSdkChannel invokeMethod: @"AdView_onAdClicked" arguments: nil];
}

#pragma mark - APInterstitialDelegate

- (void)interstitialDidLoadAd:(APInterstitial *)interstitial {
    [adpieSdkChannel invokeMethod: @"Interstitial_onAdLoaded" arguments: nil];
}

- (void)interstitialDidFailToLoadAd:(APInterstitial *)interstitial withError:(NSError *)error {
    NSDictionary *args = @{@"error_code" : [NSNumber numberWithLong:error.code]};
    
    [adpieSdkChannel invokeMethod: @"Interstitial_onAdFailedToLoad" arguments: args];
}

- (void)interstitialWillPresentScreen:(APInterstitial *)interstitial {
    [adpieSdkChannel invokeMethod: @"Interstitial_onAdShown" arguments: nil];
}

- (void)interstitialWillDismissScreen:(APInterstitial *)interstitial {
}

- (void)interstitialDidDismissScreen:(APInterstitial *)interstitial {
    [adpieSdkChannel invokeMethod: @"Interstitial_onAdDismissed" arguments: nil];
    
}

- (void)interstitialWillLeaveApplication:(APInterstitial *)interstitial {
    [adpieSdkChannel invokeMethod: @"Interstitial_onAdClicked" arguments: nil];
    
}


#pragma mark - APRewardedAdDelegate

- (void)rewardedAdDidLoadAd:(APRewardedAd *)rewardedAd {
    [adpieSdkChannel invokeMethod: @"RewardedAd_onAdLoaded" arguments: nil];
}

- (void)rewardedAdDidFailToLoadAd:(APRewardedAd *)rewardedAd withError:(NSError *)error {
    NSDictionary *args = @{@"error_code" : [NSNumber numberWithLong:error.code]};
    
    [adpieSdkChannel invokeMethod: @"RewardedAd_onAdFailedToLoad" arguments: args];
}

- (void)rewardedAdWillPresentScreen:(APRewardedAd *)rewardedAd {
    [adpieSdkChannel invokeMethod: @"RewardedAd_onAdShown" arguments: nil];
}

- (void)rewardedAdWillDismissScreen:(APRewardedAd *)rewardedAd {
    
}

- (void)rewardedAdDidDismissScreen:(APRewardedAd *)rewardedAd {
    [adpieSdkChannel invokeMethod: @"RewardedAd_onAdDismissed" arguments: nil];
}

- (void)rewardedAdWillLeaveApplication:(APRewardedAd *)rewardedAd {
    [adpieSdkChannel invokeMethod: @"RewardedAd_onAdClicked" arguments: nil];
}

- (void)rewardedAdDidEarnReward:(APRewardedAd *)rewardedAd {
    [adpieSdkChannel invokeMethod: @"RewardedAd_onAdRewarded" arguments: nil];
}

@end
