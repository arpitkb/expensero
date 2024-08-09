import 'package:flutter/material.dart';

class MyDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T?> onChanged;
  final String Function(T) getLabel;
  final String hintText;

  const MyDropdown({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.getLabel,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300)),
        child: DropdownButton<T>(
          hint: Text(hintText),
          value: selectedItem,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          isExpanded: true,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
          items: items.map<DropdownMenuItem<T>>((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(getLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
