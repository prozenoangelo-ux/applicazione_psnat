import 'package:flutter/material.dart';


class MultiTagSelector extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selected;
  final Function(List<String>) onChanged;

  const MultiTagSelector({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final bool isSelected = selected.contains(opt);

            return GestureDetector(
              onTap: () {
                final newList = List<String>.from(selected);
                if (isSelected) {
                  newList.remove(opt);
                } else {
                  newList.add(opt);
                }
                onChanged(newList);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade400,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
