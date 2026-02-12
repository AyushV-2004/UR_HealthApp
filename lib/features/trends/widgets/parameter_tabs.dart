import 'package:flutter/material.dart';
import '../trends_controller.dart';

class ParameterTabs extends StatelessWidget {
  final TrendsController controller;

  const ParameterTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.parameters.map((param) {
        final bool selected = param == controller.selectedParameter;

        return ChoiceChip(
          label: Text(
            param,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.black : Colors.grey[700],
            ),
          ),
          selected: selected,
          onSelected: (_) => controller.selectParameter(param),

          backgroundColor: const Color(0xFFF3F3F3),
          selectedColor: Colors.white,

          side: BorderSide(
            color: selected ? Colors.black12 : Colors.transparent,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
        );
      }).toList(),
    );
  }
}
