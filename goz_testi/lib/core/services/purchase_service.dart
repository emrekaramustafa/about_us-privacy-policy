import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint, defaultTargetPlatform;
import 'package:flutter/material.dart' show TargetPlatform;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Purchase Service
/// Manages in-app purchases for premium subscription
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;

  // Product ID for premium lifetime purchase
  static const String _premiumProductId = 'premium_lifetime';

  /// Initialize purchase service
  Future<void> initialize() async {
    // In-App Purchase doesn't work on web
    if (kIsWeb) {
      debugPrint('In-App Purchase is not supported on web platform');
      _isAvailable = false;
      return;
    }
    
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      
      if (_isAvailable) {
        // Listen to purchase updates
        _subscription = _inAppPurchase.purchaseStream.listen(
          _onPurchaseUpdate,
          onDone: () => _subscription?.cancel(),
          onError: (error) => debugPrint('Purchase stream error: $error'),
        );
      }
    } catch (e) {
      debugPrint('Purchase service initialization failed: $e');
      _isAvailable = false;
    }
  }

  /// Get premium product details
  Future<ProductDetails?> getPremiumProduct() async {
    if (!_isAvailable) {
      await initialize();
      if (!_isAvailable) return null;
    }

    try {
      final Set<String> productIds = {_premiumProductId};
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        debugPrint('Error querying products: ${response.error}');
        return null;
      }

      if (response.productDetails.isEmpty) {
        debugPrint('Product not found: $_premiumProductId');
        return null;
      }

      return response.productDetails.first;
    } catch (e) {
      debugPrint('Error fetching premium product: $e');
      return null;
    }
  }

  /// Purchase premium
  Future<bool> purchasePremium() async {
    if (!_isAvailable) return false;

    final products = await getPremiumProduct();
    if (products == null) {
      debugPrint('Premium product not found');
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: products);

    // Platform-specific purchase
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }

    // The result will be handled in _onPurchaseUpdate listener
    // We return true here to indicate the request was sent successfully
    // The UI should show a loading state until the stream updates
    return true;
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    await _inAppPurchase.restorePurchases();
  }

  /// Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
        debugPrint('Purchase pending');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Verify purchase and grant premium
          _verifyPurchase(purchaseDetails);
        }

        // Complete the purchase
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  /// Verify and grant premium access
  void _verifyPurchase(PurchaseDetails purchaseDetails) {
    // Verify purchase - in production, verify with backend server for security
    // For now, grant premium if product ID matches
    if (purchaseDetails.productID == _premiumProductId) {
      // Premium granted - save to SharedPreferences
      // The provider will read this on next access
      _savePremiumStatus(true);
      debugPrint('Premium purchase verified: ${purchaseDetails.productID}');
    }
  }

  /// Save premium status to SharedPreferences
  Future<void> _savePremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', isPremium);
  }

  /// Check if user has active premium purchase
  Future<bool> hasActivePurchase() async {
    // Check SharedPreferences first (set by _verifyPurchase)
    final prefs = await SharedPreferences.getInstance();
    final savedPremium = prefs.getBool('is_premium') ?? false;
    
    if (savedPremium) return true;

    if (!_isAvailable) return false;

    // Query past purchases
    try {
      final InAppPurchaseStoreKitPlatformAddition? iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      
      if (iosPlatformAddition != null) {
        // iOS: Check restore purchases
        await restorePurchases();
      }
    } catch (e) {
      debugPrint('Error checking iOS platform addition: $e');
    }

    // Check again after restore
    return prefs.getBool('is_premium') ?? false;
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
  }
}
