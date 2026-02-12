import 'package:flutter/material.dart';

class ExposureSummaryText extends StatelessWidget {
  const ExposureSummaryText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "How many hr extreme condition? (exposure) cum exp during the day move and stationery",
        maxLines: 1, // ✅ ONE LINE ONLY
        overflow: TextOverflow.ellipsis, // ✅ ...
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }
}
