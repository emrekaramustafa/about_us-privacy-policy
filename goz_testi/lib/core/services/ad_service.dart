import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Ad Service
/// Manages Google AdMob rewarded ads
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  // Test Ad Unit IDs (development only)
  // Android Test: ca-app-pub-3940256099942544/5224354917
  // iOS Test: ca-app-pub-3940256099942544/1712485313

  String get _rewardedAdUnitId {
    if (kDebugMode) {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return 'ca-app-pub-3940256099942544/1712485313';
      }
      return 'ca-app-pub-3940256099942544/5224354917';
    }
    // Production
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-6401639781794250/4036226500';
    }
    return 'ca-app-pub-6401639781794250/5699009570';
  }

  /// Initialize AdMob
  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('AdMob is not supported on web platform');
      return;
    }
    try {
      await MobileAds.instance.initialize();
      debugPrint('AdMob initialized successfully');
      // Preload ad
      loadRewardedAd();
    } catch (e) {
      debugPrint('AdMob initialization failed: $e');
    }
  }

  /// Load rewarded ad
  Future<void> loadRewardedAd({
    VoidCallback? onAdLoaded,
    VoidCallback? onAdFailedToLoad,
  }) async {
    if (kIsWeb) {
      // Web'de reklam yüklenmiş gibi davran
      _isRewardedAdReady = true;
      onAdLoaded?.call();
      return;
    }
    
    try {
      debugPrint('Loading rewarded ad with ID: $_rewardedAdUnitId');
      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdReady = true;
            _setFullScreenContentCallback();
            debugPrint('Rewarded ad loaded successfully');
            onAdLoaded?.call();
          },
          onAdFailedToLoad: (error) {
            _isRewardedAdReady = false;
            debugPrint('Rewarded ad failed to load: ${error.code} - ${error.message}');
            debugPrint('Domain: ${error.domain}');
            onAdFailedToLoad?.call();
          },
        ),
      );
    } catch (e) {
      _isRewardedAdReady = false;
      debugPrint('Exception loading rewarded ad: $e');
      onAdFailedToLoad?.call();
    }
  }

  /// Set full screen content callbacks
  void _setFullScreenContentCallback() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isRewardedAdReady = false;
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isRewardedAdReady = false;
        ad.dispose();
        _rewardedAd = null;
        debugPrint('Rewarded ad failed to show: $error');
        loadRewardedAd();
      },
    );
  }

  /// Show rewarded ad
  Future<bool> showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onAdDismissed,
    BuildContext? context,
  }) async {
    // Web için simüle edilmiş reklam dialog'u
    if (kIsWeb && context != null) {
      return await _showWebSimulatedAd(context, onRewarded, onAdDismissed);
    } else if (kIsWeb) {
      // Context yoksa direkt ödül ver
      onRewarded();
      return true;
    }
    
    // Mobil için gerçek AdMob
    if (!_isRewardedAdReady || _rewardedAd == null) {
      debugPrint('Rewarded ad not ready, loading...');
      await loadRewardedAd();
      // Wait a bit for ad to load
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_isRewardedAdReady || _rewardedAd == null) {
        debugPrint('Rewarded ad still not ready after loading attempt');
        onAdDismissed?.call();
        return false;
      }
    }

    bool rewardGranted = false;

    try {
      _rewardedAd?.setImmersiveMode(true);
      await _rewardedAd?.show(
        onUserEarnedReward: (ad, reward) {
          rewardGranted = true;
          onRewarded();
        },
      );
    } catch (e) {
      debugPrint('Error showing rewarded ad: $e');
      _isRewardedAdReady = false;
      _rewardedAd?.dispose();
      _rewardedAd = null;
      onAdDismissed?.call();
      return false;
    }

    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          _isRewardedAdReady = false;
          ad.dispose();
          _rewardedAd = null;
          onAdDismissed?.call();
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _isRewardedAdReady = false;
          ad.dispose();
          _rewardedAd = null;
          debugPrint('Rewarded ad failed to show: $error');
          onAdDismissed?.call();
          loadRewardedAd();
        },
      );
    }

    return rewardGranted;
  }

  /// Web için simüle edilmiş reklam dialog'u
  Future<bool> _showWebSimulatedAd(
    BuildContext context,
    VoidCallback onRewarded,
    VoidCallback? onAdDismissed,
  ) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _WebAdDialog(
        onRewarded: onRewarded,
        onDismissed: onAdDismissed,
      ),
    ) ?? false;
  }

  /// Check if rewarded ad is ready
  bool get isRewardedAdReady => _isRewardedAdReady;

  /// Dispose resources
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdReady = false;
  }
}

/// Web için simüle edilmiş reklam dialog widget'ı
class _WebAdDialog extends StatefulWidget {
  final VoidCallback onRewarded;
  final VoidCallback? onDismissed;

  const _WebAdDialog({
    required this.onRewarded,
    this.onDismissed,
  });

  @override
  State<_WebAdDialog> createState() => _WebAdDialogState();
}

class _WebAdDialogState extends State<_WebAdDialog> {
  int _countdown = 5;
  bool _canComplete = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _countdown--;
          if (_countdown <= 0) {
            _canComplete = true;
          } else {
            _startCountdown();
          }
        });
      }
    });
  }

  void _onComplete() {
    widget.onRewarded();
    Navigator.of(context).pop(true);
  }

  void _onSkip() {
    widget.onDismissed?.call();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            const Text(
              'TEST REKLAMI',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu bir test reklamıdır',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            if (!_canComplete)
              Text(
                '$_countdown saniye bekleyin...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _canComplete ? _onSkip : null,
                    child: Text(
                      'Kapat',
                      style: TextStyle(
                        color: _canComplete ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _canComplete ? _onComplete : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canComplete ? Colors.blue : Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _canComplete ? 'Ödülü Al' : 'Bekleyin...',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
