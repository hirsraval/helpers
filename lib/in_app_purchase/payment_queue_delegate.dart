import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class PaymentQueueDelegate extends SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(transaction, storefront) => true;

  @override
  bool shouldShowPriceConsent() => false;
}
