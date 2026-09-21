import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/entities/premium_feature.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/revenue_cat_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final RevenueCatDataSource dataSource;

  SubscriptionRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, SubscriptionEntity>> getSubscriptionStatus() async {
    try {
      final status = await dataSource.getSubscriptionStatus();
      return Right(status);
    } catch (e) {
      return Left(SubscriptionFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> purchaseSubscription(String planId) async {
    try {
      final status = await dataSource.purchaseSubscription(planId);
      return Right(status);
    } catch (e) {
      return Left(SubscriptionFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> restorePurchases() async {
    try {
      final status = await dataSource.restorePurchases();
      return Right(status);
    } catch (e) {
      return Left(SubscriptionFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkFeatureAccess(PremiumFeature feature) async {
    try {
      final access = await dataSource.checkFeatureAccess(feature);
      return Right(access);
    } catch (e) {
      return Left(SubscriptionFailure(message: e.toString()));
    }
  }
}
