import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class SubscriptionCheckRequested extends SubscriptionEvent {}
class SubscriptionPurchaseRequested extends SubscriptionEvent {
  final String planId;
  const SubscriptionPurchaseRequested(this.planId);
  @override
  List<Object?> get props => [planId];
}
class SubscriptionRestoreRequested extends SubscriptionEvent {}
