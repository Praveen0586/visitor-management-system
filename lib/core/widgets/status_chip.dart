import 'package:flutter/material.dart';
import 'package:vms/core/configs/theme/app_theme.dart';
import 'package:vms/features/dashboard/models/visitor_model.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final bool showDot;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusChip({
    super.key,
    required this.status,
    this.showDot = true,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case VisitorStatus.checkedIn:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case VisitorStatus.checkedOut:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        break;
      case VisitorStatus.registered:
      default:
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            status,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
