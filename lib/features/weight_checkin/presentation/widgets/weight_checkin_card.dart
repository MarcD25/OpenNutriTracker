import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_trend_entity.dart';

class WeightCheckinCard extends StatefulWidget {
  final Function(double weight, String? notes) onWeightSubmitted;
  final WeightEntryEntity? lastEntry;
  final WeightTrend? trend;
  final bool showTrend;
  final String weightUnit; // 'kg' or 'lbs'

  const WeightCheckinCard({
    Key? key,
    required this.onWeightSubmitted,
    this.lastEntry,
    this.trend,
    this.showTrend = true,
    this.weightUnit = 'kg',
  }) : super(key: key);

  @override
  State<WeightCheckinCard> createState() => _WeightCheckinCardState();
}

class _WeightCheckinCardState extends State<WeightCheckinCard> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _validationError;

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            if (widget.showTrend && widget.trend != null) ...[
              _buildTrendIndicator(),
              const SizedBox(height: 16),
            ],
            _buildWeightInput(),
            const SizedBox(height: 12),
            _buildNotesInput(),
            if (_validationError != null) ...[
              const SizedBox(height: 8),
              _buildValidationError(),
            ],
            const SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.monitor_weight,
          color: Colors.blue,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Text(
          'Weight Check-in',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (widget.lastEntry != null)
          Text(
            'Last: ${_formatWeight(widget.lastEntry!.weightKG)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildTrendIndicator() {
    final trend = widget.trend!;
    Color trendColor;
    IconData trendIcon;

    switch (trend.trendDirection) {
      case WeightTrendDirection.increasing:
        trendColor = Colors.red;
        trendIcon = Icons.trending_up;
        break;
      case WeightTrendDirection.decreasing:
        trendColor = Colors.green;
        trendIcon = Icons.trending_down;
        break;
      case WeightTrendDirection.stable:
        trendColor = Colors.orange;
        trendIcon = Icons.trending_flat;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: trendColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(trendIcon, color: trendColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trend.description,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: trendColor,
                  ),
                ),
                if (trend.isSignificant)
                  Text(
                    '${trend.weeklyChangeText} • ${trend.confidenceText}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInput() {
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: _weightController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          labelText: 'Weight (${widget.weightUnit})',
          hintText: 'Enter your current weight',
          suffixText: widget.weightUnit,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.monitor_weight_outlined),
        ),
        validator: _validateWeight,
        onChanged: (value) {
          setState(() {
            _validationError = null;
          });
        },
      ),
    );
  }

  Widget _buildNotesInput() {
    return TextFormField(
      controller: _notesController,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Notes (optional)',
        hintText: 'Any notes about your weight today...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note_outlined),
      ),
    );
  }

  Widget _buildValidationError() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _validationError!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitWeight,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Record Weight'),
      ),
    );
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your weight';
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number';
    }

    // Validate weight range based on unit
    bool isValid;
    if (widget.weightUnit == 'kg') {
      isValid = weight >= 20.0 && weight <= 300.0;
    } else {
      isValid = weight >= 44.0 && weight <= 661.0;
    }

    if (!isValid) {
      final unit = widget.weightUnit;
      final min = unit == 'kg' ? '20' : '44';
      final max = unit == 'kg' ? '300' : '661';
      return 'Weight must be between $min and $max $unit';
    }

    return null;
  }

  void _submitWeight() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final weightText = _weightController.text.trim();
    final weight = double.parse(weightText);
    
    // Convert to kg if needed
    final weightInKg = widget.weightUnit == 'lbs' ? weight / 2.20462 : weight;
    
    // Additional validation for realistic weight changes
    if (widget.lastEntry != null) {
      final lastWeight = widget.lastEntry!.weightKG;
      final change = (weightInKg - lastWeight).abs();
      final daysSinceLastEntry = DateTime.now()
          .difference(widget.lastEntry!.timestamp)
          .inDays;
      
      // Flag unrealistic changes (more than 2kg per day)
      if (daysSinceLastEntry > 0 && change / daysSinceLastEntry > 2.0) {
        setState(() {
          _validationError = 'This seems like a large change from your last entry. Please double-check.';
        });
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
      _validationError = null;
    });

    try {
      final notes = _notesController.text.trim();
      await widget.onWeightSubmitted(
        weightInKg,
        notes.isEmpty ? null : notes,
      );
      
      // Clear form after successful submission
      _weightController.clear();
      _notesController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weight recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _validationError = 'Failed to record weight. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatWeight(double weightKg) {
    if (widget.weightUnit == 'lbs') {
      final weightLbs = weightKg * 2.20462;
      return '${weightLbs.toStringAsFixed(1)} lbs';
    } else {
      return '${weightKg.toStringAsFixed(1)} kg';
    }
  }
}