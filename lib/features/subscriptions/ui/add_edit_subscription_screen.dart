import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants.dart';
import '../../../data/models/subscription.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';

class AddEditSubscriptionScreen extends StatefulWidget {
  final String userId;
  final Subscription? subscription;

  const AddEditSubscriptionScreen({
    super.key,
    required this.userId,
    this.subscription,
  });

  @override
  State<AddEditSubscriptionScreen> createState() => _AddEditSubscriptionScreenState();
}

class _AddEditSubscriptionScreenState extends State<AddEditSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _customCategoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedCategory = AppConstants.defaultCategories.first;
  DateTime _startDate = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    if (widget.subscription != null) {
      final sub = widget.subscription!;
      _nameController.text = sub.name;
      if (AppConstants.defaultCategories.contains(sub.category)) {
        _selectedCategory = sub.category;
      } else {
        _selectedCategory = 'Other';
        _customCategoryController.text = sub.customCategory ?? '';
      }
      _amountController.text = sub.amount?.toString() ?? '';
      _notesController.text = sub.notes ?? '';
      _startDate = sub.startDate;
      _expiryDate = sub.expiryOrRenewalDate;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _expiryDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subscription != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Subscription' : 'Add Subscription'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Subscription Name *'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category *'),
                  items: AppConstants.defaultCategories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                ),
                if (_selectedCategory == 'Other') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _customCategoryController,
                    decoration: const InputDecoration(labelText: 'Custom Category'),
                  ),
                ],
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Start Date *'),
                  subtitle: Text(DateFormat.yMMMd().format(_startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, true),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Expiry/Renewal Date *'),
                  subtitle: Text(DateFormat.yMMMd().format(_expiryDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount (Optional)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final amount = double.tryParse(value);
                      if (amount == null || amount < 0) {
                        return 'Enter a valid positive number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Date validation
                      final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
                      final expiry = DateTime(_expiryDate.year, _expiryDate.month, _expiryDate.day);
                      if (expiry.isBefore(start)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Expiry date cannot be before start date')),
                        );
                        return;
                      }

                      final newSub = Subscription(
                        id: widget.subscription?.id ?? const Uuid().v4(),
                        userId: widget.userId,
                        name: _nameController.text,
                        category: _selectedCategory,
                        customCategory: _selectedCategory == 'Other' ? _customCategoryController.text : null,
                        startDate: _startDate,
                        expiryOrRenewalDate: _expiryDate,
                        amount: _amountController.text.isNotEmpty ? double.tryParse(_amountController.text) : null,
                        notes: _notesController.text,
                        isInactive: widget.subscription?.isInactive ?? false,
                        createdAt: widget.subscription?.createdAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      );

                      if (isEditing) {
                        context.read<SubscriptionBloc>().add(UpdateSubscription(newSub));
                      } else {
                        context.read<SubscriptionBloc>().add(AddSubscription(newSub));
                      }
                      
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isEditing ? 'Update Subscription' : 'Add Subscription'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
