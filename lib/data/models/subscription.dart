import 'package:equatable/equatable.dart';

enum SubscriptionStatus { active, expiringSoon, expired, inactive }

class Subscription extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String category;
  final String? customCategory;
  final DateTime startDate;
  final DateTime expiryOrRenewalDate;
  final double? amount;
  final String? notes;
  final bool isInactive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.customCategory,
    required this.startDate,
    required this.expiryOrRenewalDate,
    this.amount,
    this.notes,
    this.isInactive = false,
    required this.createdAt,
    required this.updatedAt,
  });

  SubscriptionStatus get status {
    if (isInactive) return SubscriptionStatus.inactive;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryOrRenewalDate.year, expiryOrRenewalDate.month, expiryOrRenewalDate.day);
    
    if (expiry.isBefore(today)) {
      return SubscriptionStatus.expired;
    }
    
    final difference = expiry.difference(today).inDays;
    if (difference <= 3) {
      return SubscriptionStatus.expiringSoon;
    }
    
    return SubscriptionStatus.active;
  }

  Subscription copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? customCategory,
    DateTime? startDate,
    DateTime? expiryOrRenewalDate,
    double? amount,
    String? notes,
    bool? isInactive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      customCategory: customCategory ?? this.customCategory,
      startDate: startDate ?? this.startDate,
      expiryOrRenewalDate: expiryOrRenewalDate ?? this.expiryOrRenewalDate,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      isInactive: isInactive ?? this.isInactive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'category': category,
      'customCategory': customCategory,
      'startDate': startDate.toIso8601String(),
      'expiryOrRenewalDate': expiryOrRenewalDate.toIso8601String(),
      'amount': amount,
      'notes': notes,
      'isInactive': isInactive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      category: json['category'],
      customCategory: json['customCategory'],
      startDate: DateTime.parse(json['startDate']),
      expiryOrRenewalDate: DateTime.parse(json['expiryOrRenewalDate']),
      amount: json['amount']?.toDouble(),
      notes: json['notes'],
      isInactive: json['isInactive'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        category,
        customCategory,
        startDate,
        expiryOrRenewalDate,
        amount,
        notes,
        isInactive,
        createdAt,
        updatedAt,
      ];
}
