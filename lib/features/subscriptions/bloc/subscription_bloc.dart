import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/local_storage_repository.dart';
import '../../../data/models/subscription.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final LocalStorageRepository _repository;
  List<Subscription> _allSubscriptions = [];
  String _currentFilter = 'All';

  SubscriptionBloc(this._repository) : super(SubscriptionInitial()) {
    on<LoadSubscriptions>(_onLoadSubscriptions);
    on<AddSubscription>(_onAddSubscription);
    on<UpdateSubscription>(_onUpdateSubscription);
    on<DeleteSubscription>(_onDeleteSubscription);
    on<FilterSubscriptions>(_onFilterSubscriptions);
  }

  void _emitFiltered(Emitter<SubscriptionState> emit) {
    List<Subscription> filtered = [];
    switch (_currentFilter) {
      case 'Active':
        filtered = _allSubscriptions
            .where((s) => s.status == SubscriptionStatus.active)
            .toList();
        break;
      case 'Expiring soon':
        filtered = _allSubscriptions
            .where((s) => s.status == SubscriptionStatus.expiringSoon)
            .toList();
        break;
      case 'Expired':
        filtered = _allSubscriptions
            .where((s) => s.status == SubscriptionStatus.expired)
            .toList();
        break;
      case 'All':
      default:
        filtered = List.from(_allSubscriptions);
        break;
    }
    emit(SubscriptionsLoaded(filtered, filter: _currentFilter));
  }

  Future<void> _onLoadSubscriptions(
      LoadSubscriptions event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      _allSubscriptions = await _repository.getUserSubscriptions(event.userId);
      _emitFiltered(emit);
    } catch (e) {
      emit(const SubscriptionError('Failed to load subscriptions'));
    }
  }

  Future<void> _onAddSubscription(
      AddSubscription event, Emitter<SubscriptionState> emit) async {
    try {
      await _repository.saveSubscription(event.subscription);
      add(LoadSubscriptions(event.subscription.userId));
    } catch (e) {
      emit(const SubscriptionError('Failed to add subscription'));
    }
  }

  Future<void> _onUpdateSubscription(
      UpdateSubscription event, Emitter<SubscriptionState> emit) async {
    try {
      await _repository.saveSubscription(event.subscription);
      add(LoadSubscriptions(event.subscription.userId));
    } catch (e) {
      emit(const SubscriptionError('Failed to update subscription'));
    }
  }

  Future<void> _onDeleteSubscription(
      DeleteSubscription event, Emitter<SubscriptionState> emit) async {
    try {
      await _repository.deleteSubscription(event.id);
      add(LoadSubscriptions(event.userId));
    } catch (e) {
      emit(const SubscriptionError('Failed to delete subscription'));
    }
  }

  void _onFilterSubscriptions(
      FilterSubscriptions event, Emitter<SubscriptionState> emit) {
    _currentFilter = event.filter;
    _emitFiltered(emit);
  }
}
