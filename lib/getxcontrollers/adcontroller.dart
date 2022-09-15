import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdController extends GetxController{
  late BannerAd bannerAd;
  late InterstitialAd interstitialAd;
  late RewardedAd rewardedAd;
  bool isbanneradloaded = false;
  bool isrewardadloaded = false;

  //Need to add banner unit id
  void initializebanner() async {
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: BannerAd.testAdUnitId,
        listener:
        BannerAdListener(onAdLoaded: (ad) {}, onAdImpression: (ad) {}),
        request: AdRequest());
    bannerAd.load();
    isbanneradloaded = true;
    update();
  }

  void loadrewardedad() {
    RewardedAd.load(
        adUnitId: RewardedAd.testAdUnitId,
        request: AdRequest(),
        rewardedAdLoadCallback:
        RewardedAdLoadCallback(onAdFailedToLoad: (LoadAdError error) {
          //failedtoload
        }, onAdLoaded: (RewardedAd ad) {
          rewardedAd = ad;
        }));
  }
  void loadinterstitialad() {
    InterstitialAd.load(adUnitId: InterstitialAd.testAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: oninterstitialadloaded,
            onAdFailedToLoad: (LoadAdError error){
            }));
  }
  void oninterstitialadloaded(InterstitialAd ad){
    interstitialAd=ad;
    interstitialAd.fullScreenContentCallback=
        FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad){
              interstitialAd.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad,error){
              interstitialAd.dispose();
            }

        );
  }
  void showRewardedAd(){
    if(rewardedAd!=null){
      rewardedAd.fullScreenContentCallback=FullScreenContentCallback(
          onAdShowedFullScreenContent: (RewardedAd ad){

          },
          onAdDismissedFullScreenContent: (RewardedAd ad){
            ad.dispose();
            loadrewardedad();
          },
          onAdFailedToShowFullScreenContent: (RewardedAd ad,AdError error){
            ad.dispose();
            loadrewardedad();
          }
      );
      rewardedAd.setImmersiveMode(true);
      rewardedAd.show(onUserEarnedReward: (AdWithoutView ad,RewardItem item){

      });
    }
  }
  void showinterstitialad(){
    if(interstitialAd!=null){
      interstitialAd.fullScreenContentCallback=FullScreenContentCallback(
          onAdShowedFullScreenContent: (InterstitialAd ad){
          },
          onAdDismissedFullScreenContent: (InterstitialAd ad){
            ad.dispose();
            loadinterstitialad();
          },
          onAdFailedToShowFullScreenContent: (InterstitialAd ad,AdError error){
            ad.dispose();
            loadinterstitialad();
          }
      );
      interstitialAd.setImmersiveMode(true);
    }
  }
  void disposeads() async {
    bannerAd.dispose();
    interstitialAd.dispose();
    rewardedAd.dispose();
  }

}