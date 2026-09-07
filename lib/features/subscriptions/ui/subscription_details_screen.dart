import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../data/models/subscription.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import 'add_edit_subscription_screen.dart';

class SubscriptionDetailsScreen extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionDetailsScreen({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditSubscriptionScreen(
                    userId: subscription.userId,
                    subscription: subscription,
                  ),
                ),
              ).then((_) {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              _buildDetailRow('Name', subscription.name),
              _buildDetailRow('Category', 
                subscription.category == 'Other' 
                  ? '${subscription.category} (${subscription.customCategory})' 
                  : subscription.category),
              _buildDetailRow('Status', subscription.status.name.toUpperCase()),
              _buildDetailRow('Start Date', DateFormat.yMMMd().format(subscription.startDate)),
              _buildDetailRow('Renewal Date', DateFormat.yMMMd().format(subscription.expiryOrRenewalDate)),
              if (subscription.amount != null) 
                _buildDetailRow('Amount', formatCurrency.format(subscription.amount)),
              if (subscription.notes != null && subscription.notes!.isNotEmpty)
                _buildDetailRow('Notes', subscription.notes!),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  final updated = subscription.copyWith(isInactive: !subscription.isInactive);
                  context.read<SubscriptionBloc>().add(UpdateSubscription(updated));
                  Navigator.pop(context);
                },
                child: Text(subscription.isInactive ? 'Mark as Active' : 'Mark as Inactive'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Subscription'),
                      content: const Text('Are you sure you want to permanently delete this subscription?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<SubscriptionBloc>().add(
                              DeleteSubscription(subscription.id, subscription.userId)
                            );
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Delete Permanently', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
          const Divider(),
        ],
      ),
    );
  }
}
