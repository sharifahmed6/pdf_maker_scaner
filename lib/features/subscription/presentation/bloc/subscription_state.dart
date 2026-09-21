import 'package:equatable/equatable.dart';
import '../../domain/entities/subscription_entity.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}
class SubscriptionLoading extends SubscriptionState {}
class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionEntity subscription;
  const SubscriptionLoaded(this.subscription);
  @override
  List<Object?> get props => [subscription];
}
class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);
  @override
  List<Object?> get props => [message];
}
