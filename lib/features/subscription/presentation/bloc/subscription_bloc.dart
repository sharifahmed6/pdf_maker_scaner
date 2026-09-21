import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository subscriptionRepository;

  SubscriptionBloc({required this.subscriptionRepository}) : super(SubscriptionInitial()) {
    on<SubscriptionCheckRequested>((event, emit) async {
      emit(SubscriptionLoading());
      final result = await subscriptionRepository.getSubscriptionStatus();
      result.fold(
        (failure) => emit(SubscriptionError(failure.message)),
        (subscription) => emit(SubscriptionLoaded(subscription)),
      );
    });
  }
}
