import 'package:equatable/equatable.dart';
import '../../../data/models/subscription.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();
  
  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionsLoaded extends SubscriptionState {
  final List<Subscription> subscriptions;
  final String filter;

  const SubscriptionsLoaded(this.subscriptions, {this.filter = 'All'});

  @override
  List<Object?> get props => [subscriptions, filter];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}
