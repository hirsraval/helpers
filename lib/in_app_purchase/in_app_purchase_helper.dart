import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:helpers/helpers.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/src/billing_client_wrappers/billing_client_wrapper.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class InAppPurchaseHelper {
  InAppPurchaseHelper._internal({this.onPurchased, required this.platformPlans});

  static InAppPurchaseHelper? _instance;

  factory InAppPurchaseHelper({
    ValueChanged<PurchaseDetails>? onPurchased,
    required InAppPurchasePlans platformPlans,
  }) {
    return _instance ??= InAppPurchaseHelper._internal(
      onPurchased: onPurchased,
      platformPlans: platformPlans,
    );
  }

  final ValueChanged<PurchaseDetails>? onPurchased;
  final InAppPurchasePlans platformPlans;

  final List<PurchaseDetails> _purchases = [];
  bool _isAvailable = false;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  List<PurchaseDetails> get purchases => _purchases;

  bool get isAvailable => _isAvailable;

  late StreamSubscription<List<PurchaseDetails>> _subscription;

  Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    Log.debug("InAppPurchaseHelper.isAvailable -> $_isAvailable");
    _subscription = _inAppPurchase.purchaseStream.listen(
      _listenPurchaseStream,
      onDone: () => _subscription.cancel(),
      onError: (error) => Log.error(error),
    );
    _getStoreInfo();
  }

  Future<void> _getStoreInfo() async {
    var addition = _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
    await addition.setDelegate(PaymentQueueDelegate());
    final data = await addition.refreshPurchaseVerificationData();
    Log.debug("getStoreInfo.serverVerificationData");
    Log.debug(data?.serverVerificationData);
  }

  Future<void> _listenPurchaseStream(List<PurchaseDetails> items) async {
    for (var element in items) {
      final status = element.status;
      switch (status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.purchased:
          Log.debug("Purchased Details");
          Log.debug("productID - ${element.productID}");
          Log.debug("purchaseID - ${element.purchaseID}");
          Log.debug("transactionDate - ${element.transactionDate}");
          Log.debug("serverVerificationData - ${element.verificationData.serverVerificationData}");
          Log.debug("localVerificationData - ${element.verificationData.localVerificationData}");
          Log.debug("source - ${element.verificationData.source}");
          _purchases.add(element);
          onPurchased?.call(element);
          break;
        case PurchaseStatus.error:
          Log.error("PurchaseStream.error -> ${element.error?.message}");
          break;
        case PurchaseStatus.restored:
          Log.success("PurchaseStream.restored");
          _purchases.add(element);
          break;
        case PurchaseStatus.canceled:
          Log.error("PurchaseStream.canceled");
      }
      if (element.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(element);
      }
    }
  }

  Future<void> purchasePlan(ProductDetails details, {bool consumable = false}) async {
    try {
      PurchaseParam params;
      if (Platform.isAndroid) {
        final addition = _inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        final queryPastPurchases = await addition.queryPastPurchases();
        GooglePlayPurchaseDetails? existingPurchase;
        if (queryPastPurchases.pastPurchases.isNotEmpty) {
          existingPurchase = queryPastPurchases.pastPurchases.last;
        }
        params = GooglePlayPurchaseParam(
          productDetails: details,
          changeSubscriptionParam: existingPurchase != null
              ? ChangeSubscriptionParam(
                  oldPurchaseDetails: existingPurchase,
                  replacementMode: ReplacementMode.withTimeProration,
                )
              : null,
        );
      } else {
        params = PurchaseParam(
          productDetails: details,
          applicationUserName: null,
        );
        await clearTransactionsForIos();
      }
      if (consumable) {
        _inAppPurchase.buyConsumable(purchaseParam: params, autoConsume: true);
      } else {
        _inAppPurchase.buyNonConsumable(purchaseParam: params);
      }
    } catch (e) {
      Log.error("purchasePlan -> $e");
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } on InAppPurchaseException catch (e) {
      Log.error("InAppPurchaseException -> ${e.message}");
    }
  }

  void dispose() {
    _subscription.cancel();
  }

  Future<List<ProductDetails>> loadProducts() async {
    final query = Platform.isIOS ? platformPlans.iosPlans : platformPlans.androidPlans;
    final queryProducts = await _inAppPurchase.queryProductDetails(query.toSet());
    if (queryProducts.notFoundIDs.isNotEmpty) {
      Log.error("Not Founded Plans -> ${queryProducts.notFoundIDs}");
    }
    return queryProducts.productDetails;
  }

  Future<void> clearTransactionsForIos() async {
    if (Platform.isAndroid) return;
    try {
      final wrapper = SKPaymentQueueWrapper();
      final transactions = await wrapper.transactions();
      await Future.forEach(transactions, (element) async {
        if (element.transactionState != SKPaymentTransactionStateWrapper.purchasing) {
          await wrapper.finishTransaction(element);
        }
      });
    } catch (e) {
      Log.error("ClearTransactions -> $e");
    }
  }
}
