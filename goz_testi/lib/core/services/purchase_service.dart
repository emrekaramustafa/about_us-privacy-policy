import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint, defaultTargetPlatform;
import 'package:flutter/material.dart' show TargetPlatform;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
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

  // Product IDs (replace with real IDs in production)
  static const String _premiumProductId = 'premium_lifetime';
  
  // For testing, use these IDs:
  // Android: android.test.purchased
  // iOS: com.example.premium

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

  /// Get products
  Future<List<ProductDetails>> getProducts() async {
    if (!_isAvailable) return [];

    final Set<String> productIds = {_premiumProductId};
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds);

    if (response.error != null) {
      debugPrint('Error querying products: ${response.error}');
      return [];
    }

    return response.productDetails;
  }

  /// Purchase premium
  /// TEST MODE: Directly grants premium without actual payment
  /// NOTE: In test mode, premium status is NOT persisted - it resets on app restart
  Future<bool> purchasePremium() async {
    // TEST MODE: Directly grant premium for testing (session only, not persisted)
    debugPrint('TEST MODE: Granting premium without payment (session only)');
    // Don't save to SharedPreferences - premium will reset on app restart
    // This allows testing the purchase flow repeatedly
    return true;
    
    // Original payment code (commented out for testing)
    /*
    if (!_isAvailable) return false;

    final products = await getProducts();
    if (products.isEmpty) {
      debugPrint('No products available');
      return false;
    }

    final productDetails = products.first;
    final purchaseParam = PurchaseParam(productDetails: productDetails);

    // Platform-specific purchase
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }

    return true;
    */
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
    // In production, verify purchase with backend server
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
    // This will be accessed by the provider
    // For now, we'll use a simple approach
    // In production, use a proper storage service
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
    final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
        _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
    
    if (iosPlatformAddition != null) {
      // iOS: Check restore purchases
      await restorePurchases();
    }

    // Check again after restore
    return prefs.getBool('is_premium') ?? false;
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
  }
}
