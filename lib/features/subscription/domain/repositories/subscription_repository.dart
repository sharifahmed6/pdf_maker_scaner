import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/subscription_entity.dart';
import '../entities/premium_feature.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, SubscriptionEntity>> getSubscriptionStatus();
  Future<Either<Failure, SubscriptionEntity>> purchaseSubscription(String planId);
  Future<Either<Failure, SubscriptionEntity>> restorePurchases();
  Future<Either<Failure, bool>> checkFeatureAccess(PremiumFeature feature);
}
