import 'package:flutter/material.dart';
import 'package:vms/features/dashboard/models/visitor_model.dart';

class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (category) {
      case VisitorCategory.vendor:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case VisitorCategory.other:
        bg = const Color(0xFFE2E8F0);
        fg = const Color(0xFF475569);
        break;
      case VisitorCategory.customer:
      default:
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF4338CA);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
