import 'package:equatable/equatable.dart';

class SubscriptionEntity extends Equatable {
  final bool isPremium;
  final String? activePlanId;
  final DateTime? expirationDate;

  const SubscriptionEntity({
    required this.isPremium,
    this.activePlanId,
    this.expirationDate,
  });

  @override
  List<Object?> get props => [isPremium, activePlanId, expirationDate];
}
