import '../../domain/entities/subscription_entity.dart';
import '../../domain/entities/premium_feature.dart';

abstract class RevenueCatDataSource {
  Future<SubscriptionEntity> getSubscriptionStatus();
  Future<SubscriptionEntity> purchaseSubscription(String planId);
  Future<SubscriptionEntity> restorePurchases();
  Future<bool> checkFeatureAccess(PremiumFeature feature);
}

class RevenueCatDataSourceImpl implements RevenueCatDataSource {
  @override
  Future<SubscriptionEntity> getSubscriptionStatus() async {
    return const SubscriptionEntity(isPremium: false);
  }

  @override
  Future<SubscriptionEntity> purchaseSubscription(String planId) async {
    throw UnimplementedError();
  }

  @override
  Future<SubscriptionEntity> restorePurchases() async {
    throw UnimplementedError();
  }

  @override
  Future<bool> checkFeatureAccess(PremiumFeature feature) async {
    return false;
  }
}
