import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/sdk_keys.dart';
import '../services/logger_service.dart';

/// Shows a banner ad immediately after splash. If it fails — straight to home.
class AdWelcomeScreen extends StatefulWidget {
  final Widget nextScreen;

  const AdWelcomeScreen({super.key, required this.nextScreen});

  @override
  State<AdWelcomeScreen> createState() => _AdWelcomeScreenState();
}

class _AdWelcomeScreenState extends State<AdWelcomeScreen> {
  BannerAd? _bannerAd;
  bool _adLoaded = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    final timeout = Timer(const Duration(seconds: 4), _goToMainScreen);

    _bannerAd = BannerAd(
      adUnitId: SdkKeys.admobBannerUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          timeout.cancel();
          AppLogger.info('Banner ad loaded', source: 'AdMob');
          if (mounted) setState(() => _adLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          timeout.cancel();
          ad.dispose();
          AppLogger.error('Banner failed: ${error.message}', source: 'AdMob');
          _goToMainScreen();
        },
      ),
    )..load();
  }

  void _goToMainScreen() {
    if (_navigated) return;
    _navigated = true;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => widget.nextScreen),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _adLoaded && _bannerAd != null
          ? SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: _goToMainScreen,
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
