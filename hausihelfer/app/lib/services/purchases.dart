import 'dart:io';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config.dart';

enum PurchaseOutcome { success, cancelled, failed }

/// Thin wrapper around RevenueCat, which handles App Store and Google Play subscriptions.
class PurchaseService {
  bool _ready = false;
  bool get available => _ready;

  Future<void> init(String userId) async {
    final key = Platform.isIOS ? AppConfig.revenueCatIosKey : AppConfig.revenueCatAndroidKey;
    if (key.isEmpty) return; // not configured yet (development)
    final config = PurchasesConfiguration(key)..appUserID = userId;
    await Purchases.configure(config);
    _ready = true;
  }

  bool _hasPremium(CustomerInfo info) =>
      info.entitlements.active.containsKey(AppConfig.premiumEntitlement);

  Future<bool> isPremium() async {
    if (!_ready) return false;
    try {
      return _hasPremium(await Purchases.getCustomerInfo());
    } on PlatformException {
      return false;
    }
  }

  Future<List<Package>> packages() async {
    if (!_ready) return const [];
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? const [];
    } on PlatformException {
      return const [];
    }
  }

  Future<PurchaseOutcome> buy(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return _hasPremium(result.customerInfo) ? PurchaseOutcome.success : PurchaseOutcome.failed;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      return code == PurchasesErrorCode.purchaseCancelledError
          ? PurchaseOutcome.cancelled
          : PurchaseOutcome.failed;
    }
  }

  /// Returns true if an active premium subscription was found.
  Future<bool> restore() async {
    if (!_ready) return false;
    try {
      return _hasPremium(await Purchases.restorePurchases());
    } on PlatformException {
      return false;
    }
  }
}
