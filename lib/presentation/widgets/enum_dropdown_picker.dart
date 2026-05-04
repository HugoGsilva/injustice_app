import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EnumDropdownPicker<T extends Enum> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> values;
  final String Function(T) displayNameBuilder;
  final ValueChanged<T> onChanged;

  const EnumDropdownPicker({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.displayNameBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: context.textStyles.labelMedium),
                ],
              ),
            ),
            DropdownButton<T>(
              value: value,
              underline: Container(
                height: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
              dropdownColor: Theme.of(context).colorScheme.secondary,
              items: values.map((v) {
                return DropdownMenuItem<T>(
                  value: v,
                  child: Text(displayNameBuilder(v)),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}