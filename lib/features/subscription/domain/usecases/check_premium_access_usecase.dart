import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/premium_feature.dart';
import '../repositories/subscription_repository.dart';

class CheckPremiumAccessUseCase implements UseCase<bool, PremiumFeature> {
  final SubscriptionRepository repository;

  CheckPremiumAccessUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(PremiumFeature feature) async {
    return await repository.checkFeatureAccess(feature);
  }
}
