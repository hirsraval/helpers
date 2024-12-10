export 'in_app_purchase_helper.dart';
export 'payment_queue_delegate.dart';

class InAppPurchasePlans {
  const InAppPurchasePlans({
    this.androidPlans = const [],
    this.iosPlans = const [],
  });

  final List<String> androidPlans;
  final List<String> iosPlans;
}
