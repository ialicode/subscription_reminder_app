import 'package:equatable/equatable.dart';
import '../../../data/models/subscription.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscriptions extends SubscriptionEvent {
  final String userId;

  const LoadSubscriptions(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddSubscription extends SubscriptionEvent {
  final Subscription subscription;

  const AddSubscription(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class UpdateSubscription extends SubscriptionEvent {
  final Subscription subscription;

  const UpdateSubscription(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class DeleteSubscription extends SubscriptionEvent {
  final String id;
  final String userId;

  const DeleteSubscription(this.id, this.userId);

  @override
  List<Object?> get props => [id, userId];
}

class FilterSubscriptions extends SubscriptionEvent {
  final String filter; // 'All', 'Active', 'Expiring soon', 'Expired'
  final String userId;

  const FilterSubscriptions(this.filter, this.userId);

  @override
  List<Object?> get props => [filter, userId];
}
