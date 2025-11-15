import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Dialog to request holiday
class HolidayRequestDialog extends StatefulWidget {
  final Future<void> Function(
    DateTime startDate,
    DateTime endDate,
    String? reason,
  ) onRequest;

  const HolidayRequestDialog({
    super.key,
    required this.onRequest,
  });

  @override
  State<HolidayRequestDialog> createState() => _HolidayRequestDialogState();
}

class _HolidayRequestDialogState extends State<HolidayRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isRequesting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Row(
                  children: [
                    const Icon(Icons.beach_access, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Request Holiday',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Start date picker
                InkWell(
                  onTap: () => _selectStartDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _startDate != null
                          ? dateFormat.format(_startDate!)
                          : 'Select start date',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _startDate != null ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // End date picker
                InkWell(
                  onTap: _startDate != null ? () => _selectEndDate(context) : null,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                      enabled: _startDate != null,
                    ),
                    child: Text(
                      _endDate != null
                          ? dateFormat.format(_endDate!)
                          : 'Select end date',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _endDate != null ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Duration info
                if (_startDate != null && _endDate != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Duration: ${_endDate!.difference(_startDate!).inDays + 1} days',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_startDate != null && _endDate != null) const SizedBox(height: 16),

                // Reason field
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason (Optional)',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Vacation, Out of town',
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isRequesting ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isRequesting || _startDate == null || _endDate == null
                            ? null
                            : _requestHoliday,
                        child: _isRequesting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Request'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (selected != null) {
      setState(() {
        _startDate = selected;
        // Reset end date if it's before start date
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) return;

    final selected = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: _startDate!.add(const Duration(days: 90)),
    );

    if (selected != null) {
      setState(() {
        _endDate = selected;
      });
    }
  }

  Future<void> _requestHoliday() async {
    if (_startDate == null || _endDate == null) return;

    setState(() {
      _isRequesting = true;
    });

    try {
      await widget.onRequest(
        _startDate!,
        _endDate!,
        _reasonController.text.isNotEmpty ? _reasonController.text : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Holiday request submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to request holiday: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }
}
