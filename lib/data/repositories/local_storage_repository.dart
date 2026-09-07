import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../models/subscription.dart';
import '../models/user.dart';

class LocalStorageRepository {
  final SharedPreferences _prefs;

  LocalStorageRepository(this._prefs);

  // --- Auth & Users ---

  Future<bool> isEmailRegistered(String email) async {
    final users = await getUsers();
    return users.any((u) => u.email.toLowerCase() == email.toLowerCase());
  }

  Future<void> saveUser(User user) async {
    final users = await getUsers();
    if (users.any(
      (u) =>
          u.email.toLowerCase() == user.email.toLowerCase() && u.id != user.id,
    )) {
      throw Exception('Email already registered');
    }

    final existingIndex = users.indexWhere((u) => u.id == user.id);
    if (existingIndex >= 0) {
      users[existingIndex] = user;
    } else {
      users.add(user);
    }

    await _prefs.setString(
      AppConstants.usersKey,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
  }

  Future<List<User>> getUsers() async {
    final usersString = _prefs.getString(AppConstants.usersKey);
    if (usersString == null) return [];

    final List<dynamic> jsonList = jsonDecode(usersString);
    return jsonList.map((json) => User.fromJson(json)).toList();
  }

  Future<User?> login(String email, String password) async {
    final users = await getUsers();
    try {
      final user = users.firstWhere(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase() &&
            u.password == password,
      );
      await _prefs.setString(
        AppConstants.currentUserKey,
        jsonEncode(user.toJson()),
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _prefs.remove(AppConstants.currentUserKey);
  }

  Future<User?> getCurrentUser() async {
    final userString = _prefs.getString(AppConstants.currentUserKey);
    if (userString == null) return null;
    return User.fromJson(jsonDecode(userString));
  }

  // --- Subscriptions ---

  Future<List<Subscription>> getSubscriptions() async {
    final subsString = _prefs.getString(AppConstants.subscriptionsKey);
    if (subsString == null) return [];

    final List<dynamic> jsonList = jsonDecode(subsString);
    return jsonList.map((json) => Subscription.fromJson(json)).toList();
  }

  Future<List<Subscription>> getUserSubscriptions(String userId) async {
    final allSubs = await getSubscriptions();
    return allSubs.where((s) => s.userId == userId).toList();
  }

  Future<void> saveSubscription(Subscription subscription) async {
    final subs = await getSubscriptions();
    final index = subs.indexWhere((s) => s.id == subscription.id);

    if (index >= 0) {
      subs[index] = subscription;
    } else {
      subs.add(subscription);
    }

    await _prefs.setString(
      AppConstants.subscriptionsKey,
      jsonEncode(subs.map((s) => s.toJson()).toList()),
    );
  }

  Future<void> deleteSubscription(String id) async {
    final subs = await getSubscriptions();
    subs.removeWhere((s) => s.id == id);
    await _prefs.setString(
      AppConstants.subscriptionsKey,
      jsonEncode(subs.map((s) => s.toJson()).toList()),
    );
  }
}
