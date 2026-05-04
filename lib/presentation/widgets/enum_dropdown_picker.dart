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
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: value,
                  isExpanded: true,
                  dropdownColor: Theme.of(context).colorScheme.secondary,
                  style: context.textStyles.bodyMedium,
                  items: values.map((v) {
                    return DropdownMenuItem<T>(
                      value: v,
                      child: Text(
                        displayNameBuilder(v),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      onChanged(newValue);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}