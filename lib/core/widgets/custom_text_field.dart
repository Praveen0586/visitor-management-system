import 'package:flutter/material.dart';
import 'package:vms/core/configs/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? badgeText;
  final Color? badgeColor;
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final String? errorText;
  final String? helperText;
  final TextInputType keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    this.badgeText,
    this.badgeColor,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.prefixWidget,
    this.errorText,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label + Right Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: hasError ? const Color(0xFFDC2626) : AppTheme.navy,
              ),
            ),
            if (badgeText != null)
              Text(
                badgeText!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: badgeColor ??
                      (hasError ? const Color(0xFFDC2626) : const Color(0xFF94A3B8)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Field Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError ? const Color(0xFFDC2626) : const Color(0xFFE2E8F0),
              width: hasError ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment:
                maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              if (prefixWidget != null) prefixWidget!,
              if (prefixIcon != null && prefixWidget == null)
                Padding(
                  padding: EdgeInsets.only(
                    left: 14,
                    right: 8,
                    top: maxLines > 1 ? 14 : 0,
                  ),
                  child: Icon(
                    prefixIcon,
                    size: 20,
                    color: hasError ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.navy,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: (prefixIcon == null && prefixWidget == null) ? 14 : 6,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: const Color(0xFFDC2626),
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                size: 14,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ],
    );
  }
}
