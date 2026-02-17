import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/sdk_keys.dart';
import '../services/logger_service.dart';

/// A reusable banner ad widget. Loads and displays an adaptive banner ad.
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    final width = MediaQuery.of(context).size.width.truncate();
    final adSize = AdSize(width: width, height: 60);

    final bannerAd = BannerAd(
      adUnitId: SdkKeys.admobBannerUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
          AppLogger.info('Banner ad loaded', source: 'AdMob');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          AppLogger.error('Banner ad failed to load: ${error.message}', source: 'AdMob');
        },
      ),
    );

    bannerAd.load();
    _bannerAd = bannerAd;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
