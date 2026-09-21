abstract class AdService {
  Future<void> initialize();
  void showBannerAd();
  void showInterstitialAd();
  void showRewardedAd();
}

class AdServiceImpl implements AdService {
  @override
  Future<void> initialize() async {
    // TODO: Initialize Google Mobile Ads SDK
  }

  @override
  void showBannerAd() {
    // TODO: Implement banner ad display
  }

  @override
  void showInterstitialAd() {
    // TODO: Implement interstitial ad display
  }

  @override
  void showRewardedAd() {
    // TODO: Implement rewarded ad display
  }
}
