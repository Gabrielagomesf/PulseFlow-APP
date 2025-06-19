import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MultiSelectDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;

  const MultiSelectDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showDialog<List<String>>(
          context: context,
          builder: (context) => _MultiSelectDialog(
            title: label,
            options: options,
            initialSelected: selectedValues,
          ),
        );
        if (result != null) {
          onChanged(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryBlue, width: 1.2),
        ),
        child: Row(
          children: [
            Expanded(
              child: selectedValues.isEmpty
                  ? Text(label, style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryBlue))
                  : Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      children: selectedValues.map((v) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(v, style: const TextStyle(color: Colors.white, fontSize: 13)),
                      )).toList(),
                    ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }
}

class _MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<String> initialSelected;

  const _MultiSelectDialog({
    required this.title,
    required this.options,
    required this.initialSelected,
  });

  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  late List<String> selected;

  @override
  void initState() {
    super.initState();
    selected = List<String>.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(widget.title, style: AppTheme.titleMedium.copyWith(color: AppTheme.primaryBlue)),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: widget.options.map((option) => CheckboxListTile(
            value: selected.contains(option),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  selected.add(option);
                } else {
                  selected.remove(option);
                }
              });
            },
            activeColor: AppTheme.primaryBlue,
            title: Text(option, style: TextStyle(color: AppTheme.primaryBlue)),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            contentPadding: EdgeInsets.zero,
          )).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: AppTheme.primaryBlue)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.of(context).pop(selected),
          child: const Text('OK'),
        ),
      ],
    );
  }
} 